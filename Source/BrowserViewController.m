//
//  BrowserViewController.m
//  punakea
//
//  Created by Johannes Hoffart on 27.06.06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "BrowserViewController.h"
#import "PATagCloud.h"

@interface BrowserViewController (PrivateAPI)

- (void)tagsHaveChanged;

- (NSMutableArray*)visibleTags;
- (void)setVisibleTags:(NSMutableArray*)otherTags;

- (PATag*)tagWithBestAbsoluteRating:(NSArray*)tagSet;

- (PATag*)currentBestTag;
- (void)setCurrentBestTag:(PATag*)otherTag;

- (void)showTypeAheadView;
- (void)hideTypeAheadView;

- (NSString*)buffer;
- (void)setBuffer:(NSString*)string;
- (void)resetBuffer;

- (void)setMainController:(PABrowserViewMainController*)aController;

- (PABrowserViewControllerState)state;
- (void)setState:(PABrowserViewControllerState)aState;

@end

@implementation BrowserViewController

#pragma mark init + dealloc
- (id)init
{
	if (self = [super init])
	{
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		tagCloudSettings = [[NSMutableDictionary alloc] initWithDictionary:[defaults objectForKey:@"TagCloud"]];
		
		[self setState:PABrowserViewControllerNormalState];
		
		tagger = [PATagger sharedInstance];
		tags = [tagger tags];
				
		typeAheadFind = [[PATypeAheadFind alloc] init];
		
		buffer = [[NSMutableString alloc] init];
		
		[self addObserver:self forKeyPath:@"buffer" options:nil context:NULL];
		
		[self setVisibleTags:[tags tags]];
		[typeAheadFind setActiveTags:[tags tags]];

		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(tagsHaveChanged:) 
													 name:@"PATagsHaveChanged" 
												   object:tags];
		
		[NSBundle loadNibNamed:@"BrowserView" owner:self];
	}
	return self;
}

- (void)awakeFromNib
{
	[searchField setEditable:NO];
	[self showResults];
	[[[self mainView] window] setInitialFirstResponder:tagCloud];
}	

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[visibleTags release];
	[buffer release];
	[typeAheadFind release];
	[tagCloudSettings release];
	[super dealloc];
}

#pragma mark KVO
- (void)observeValueForKeyPath:(NSString *)keyPath
					  ofObject:(id)object 
                        change:(NSDictionary *)change
                       context:(void *)context
{
	if ([keyPath isEqualToString:@"buffer"])
	{
		[self bufferHasChanged];
	}
}

#pragma mark accessors
- (PABrowserViewControllerState)state
{
	return state;
}

- (void)setState:(PABrowserViewControllerState)aState
{
	state = aState;
}

- (PATag*)currentBestTag
{
	return currentBestTag;
}

- (void)setCurrentBestTag:(PATag*)otherTag
{
	[otherTag retain];
	[currentBestTag release];
	currentBestTag = otherTag;
}

- (NSString*)buffer
{
	return buffer;
}

- (void)setBuffer:(NSString*)string
{
	if (!string)
		string = @"";
	
	[buffer release];
	buffer = [string mutableCopy];
}

- (PABrowserViewMainController*)mainController
{
	return mainController;
}

- (void)setMainController:(PABrowserViewMainController*)aController
{
	[aController retain];
	[mainController release];
	mainController = aController;
	
	[mainController setDelegate:self];
	[mainController setNextResponder:self];
	
	[controlledView addSubview:[mainController mainView]];
	[[mainController mainView] setFrameSize:[controlledView frame].size];
}

- (NSView*)controlledView
{
	return controlledView;
}

- (BOOL)isWorking
{
	if (!mainController || ![mainController isWorking])
		return NO;
	else
		return YES;
}

- (NSMutableArray*)visibleTags;
{
	return visibleTags;
}

- (void)setVisibleTags:(NSMutableArray*)otherTags
{
	if (visibleTags != otherTags)
	{
		[visibleTags release];
		
		NSSortDescriptor *sortDescriptor;
		
		// sort otherTags accorings to userDefaults
		if ([[tagCloudSettings objectForKey:@"sortKey"] isEqualToString:@"name"])
		{
			sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
		}
		else if ([[tagCloudSettings objectForKey:@"sortKey"] isEqualToString:@"rating"])
		{
			sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"absoluteRating" ascending:NO];
		}
		else
		{
			// default to name
			sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
		}
		
		NSArray *sortedArray = [otherTags sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
		visibleTags = [sortedArray mutableCopy];
		
		if ([visibleTags count] > 0)
			[self setCurrentBestTag:[self tagWithBestAbsoluteRating:visibleTags]];
	}
}

- (void)setDisplayTags:(NSMutableArray*)someTags
{
	if ([self state] == PABrowserViewControllerTypeAheadFindState)
		[self resetBuffer];
	
	[self setState:PABrowserViewControllerMainControllerState];
	[self setVisibleTags:someTags];
	[typeAheadFind setActiveTags:someTags];
}

- (void)resetDisplayTags
{
	if ([self state] == PABrowserViewControllerTypeAheadFindState)
		[self resetBuffer];
	
	[self setState:PABrowserViewControllerNormalState];
	[self setVisibleTags:[tags tags]];
	[typeAheadFind setActiveTags:[tags tags]];
}

#pragma mark tag stuff
- (IBAction)tagButtonClicked:(id)sender
{
	PATag *tag = [sender fileTag];
	[mainController handleTagActivation:tag];
}

- (IBAction)findFieldAction:(id)sender
{
	PATagButton *button = [tagCloud activeButton];
	
	if (button)
	{
		[self tagButtonClicked:button];
	}
}

- (PATag*)tagWithBestAbsoluteRating:(NSArray*)tagSet
{
	NSEnumerator *e = [tagSet objectEnumerator];
	PATag *tag;
	PATag *maxTag;
	
	if (tag = [e nextObject])
		maxTag = tag;
	
	while (tag = [e nextObject])
	{
		if ([tag absoluteRating] > [maxTag absoluteRating])
			maxTag = tag;
	}	
	
	return maxTag;
}

#pragma mark typeAheadFind
- (void)showTypeAheadView
{
	NSLog(@"show");
	
	float height = NSHeight([typeAheadView frame]);
	NSScrollView *sv = [tagCloud enclosingScrollView];
	// placed above
	[sv setFrame:NSMakeRect(0,NSMinY([sv frame]),NSWidth([sv frame]),NSHeight([sv frame])-height)];
	[tagCloud setNeedsDisplay:YES];
	
	[typeAheadView setHidden:NO];
	[self setState:PABrowserViewControllerTypeAheadFindState];
}

- (void)hideTypeAheadView
{
	NSLog(@"hide");
	
	float height = NSHeight([typeAheadView frame]);
	NSScrollView *sv = [tagCloud enclosingScrollView];
	// placed above
	[sv setFrame:NSMakeRect(0,NSMinY([sv frame]),NSWidth([sv frame]),NSHeight([sv frame])+height)];
	[tagCloud setNeedsDisplay:YES];
	
	[typeAheadView setHidden:YES];	
	[self setState:PABrowserViewControllerNormalState];
}

- (void)resetBuffer
{
	[self setBuffer:@""];
}

#pragma mark events
- (void)keyDown:(NSEvent*)event 
{
	// get the pressed key
	unichar key = [[event charactersIgnoringModifiers] characterAtIndex:0];
	NSLog(@"BVC keyDown: %x", [[event characters] characterAtIndex:0]);
	
	// create character set for testing
	NSCharacterSet *alphanumericCharacterSet = [NSCharacterSet alphanumericCharacterSet];
	
	if (key == NSDeleteCharacter) 
	{
		// if buffer has any content (i.e. user is using type-ahead-find), delete last char
		if ([buffer length] > 0)
		{
			NSString *tmpBuffer = [buffer substringToIndex:[buffer length]-1];
			[self setBuffer:tmpBuffer];
		}
		else if ([mainController isKindOfClass:[PAResultsViewController class]])
		// else delete the last selected tag (if resultsview is active)
		{
			[mainController removeLastTag];
		}
	}
	// handle escape key (27)
	else if (key == 27)
	{
		[self reset];
	}
	else if ([alphanumericCharacterSet characterIsMember:key]) 
	{
		// only add to buffer if there are any tags, otherwise do nothing
		NSMutableString *tmpBuffer = [buffer mutableCopy];
		[tmpBuffer appendString:[event charactersIgnoringModifiers]];
		
		// TODO check this for typeaheadfind bug!!!
		if ([typeAheadFind hasTagsForPrefix:tmpBuffer])
		{
			[self setBuffer:tmpBuffer];
		}
		else
		{
			//TODO give negative feedback
			return;
		}
		
		[tmpBuffer release];
	}
	else
	{
		// forward unhandled events
		[[self nextResponder] keyDown:event];
	}
}

- (void)bufferHasChanged
{
	// if buffer has any content, display tags with corresponding prefix
	// else display all tags
	if ([buffer length] > 0)
	{
		if ([typeAheadView isHidden])
		{
			[self showTypeAheadView];
		}
		[self setVisibleTags:[typeAheadFind tagsForPrefix:buffer]];
		[tagCloud selectUpperLeftButton];
	}
	else
	{
		if (![typeAheadView isHidden])
		{
			[self hideTypeAheadView];
			[self setVisibleTags:[typeAheadFind activeTags]];
			[[tagCloud window] makeFirstResponder:tagCloud];
		}
	}
}

- (void)tagsHaveChanged:(NSNotification*)notification
{
	if ([self state] == PABrowserViewControllerNormalState)
	{
		[self setVisibleTags:[tags tags]];
	}
}

#pragma mark actions
- (void)manageTags
{
	PATagManagementViewController *tmvController = [[PATagManagementViewController alloc] init];
	[self switchMainControllerTo:tmvController];
	[tmvController release];
}

- (void)showResults
{
	PAResultsViewController *rvController = [[PAResultsViewController alloc] init];
	[self switchMainControllerTo:rvController];
	[rvController release];
}

- (void)switchMainControllerTo:(PABrowserViewMainController*)controller
{
	if (mainController)
		[[mainController mainView] removeFromSuperview];

	[self setMainController:controller];
}

- (void)reset
{
	[self resetBuffer];
	[mainController reset];
}

- (void)controlTextDidChange:(NSNotification *)aNotification
{
	NSDictionary *userInfo = [aNotification userInfo];
	NSText *fieldEditor = [userInfo objectForKey:@"NSFieldEditor"];
	NSString *currentString = [fieldEditor string];
	
	if ([currentString isNotEqualTo:@""] && ![typeAheadFind hasTagsForPrefix:currentString])
	{
		NSString *newString = [currentString substringToIndex:[currentString length]-1];
		[fieldEditor setString:newString];
	}
}

@end
