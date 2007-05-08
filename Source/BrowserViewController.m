//
//  BrowserViewController.m
//  punakea
//
//  Created by Johannes Hoffart on 27.06.06.
//  Copyright 2006 nudge:nudge. All rights reserved.
//

#import "BrowserViewController.h"
#import "PATagCloud.h"


float const SPLITVIEW_PANEL_MIN_HEIGHT = 150.0;


@interface BrowserViewController (PrivateAPI)

- (void)tagsHaveChanged;

- (NSMutableArray*)visibleTags;
- (void)setVisibleTags:(NSMutableArray*)otherTags;

- (NNTag*)tagWithBestAbsoluteRating:(NSArray*)tagSet;

- (NNTag*)currentBestTag;
- (void)setCurrentBestTag:(NNTag*)otherTag;

- (void)showTypeAheadView;
- (void)hideTypeAheadView;

- (NSString*)searchFieldString;
- (void)resetSearchFieldString;
- (void)searchFieldStringHasChanged;

- (void)setMainController:(PABrowserViewMainController*)aController;

- (PABrowserViewControllerState)state;
- (void)setState:(PABrowserViewControllerState)aState;

- (void)setActivePrefixFilter:(NNStringPrefixFilter*)filter;
- (NNStringPrefixFilter*)activePrefixFilter;

- (void)setupFilterEngine;
- (void)filterTags;
- (void)setFilterEngineConnection:(NSConnection*)conn;
- (NSConnection*)filterEngineConnection;

- (void)updateSortDescriptor;

@end



@implementation BrowserViewController

#pragma mark init + dealloc
- (id)init
{
	if (self = [super init])
	{
 		[self setState:PABrowserViewControllerNormalState];
		
		tags = [NNTags sharedTags];
				
		// needs to be setup before tags can be displayed
		// cannot be done here or in awakeFromNib because of wrong
		// order, self needs to be available already
		filterEngine = nil;
		
		searchFieldString = [[NSMutableString alloc] init];
		
		[self addObserver:self forKeyPath:@"searchFieldString" options:nil context:NULL];
	
		sortKey = [[NSUserDefaults standardUserDefaults] integerForKey:@"TagCloud.SortKey"];
		[self updateSortDescriptor];
		
		[[NSUserDefaultsController sharedUserDefaultsController] addObserver:self 
																  forKeyPath:@"values.TagCloud.SortKey" 
																	 options:0 
																	 context:NULL];
		
		[[NSUserDefaultsController sharedUserDefaultsController] addObserver:self 
																  forKeyPath:@"values.TagCloud.ClickCountWeight" 
																	 options:0 
																	 context:NULL];
		
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(tagsHaveChanged:) 
													 name:NNTagsHaveChangedNotification
												   object:tags];
		
		[NSBundle loadNibNamed:@"BrowserView" owner:self];
		
		// tags will be displayed a little later,
		// so that filterEngine will be up and running
		[self performSelector:@selector(initFilterEngine)
				   withObject:nil
				   afterDelay:0.01];
	}
	return self;
}

- (void)awakeFromNib
{
	[searchField setEditable:NO];
	[self showResults];
	[[[self view] window] setInitialFirstResponder:tagCloud];
}	

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[[NSUserDefaultsController sharedUserDefaultsController] removeObserver:self
																 forKeyPath:@"values.TagCloud.SortKey"];
	[[NSUserDefaultsController sharedUserDefaultsController] removeObserver:self
																 forKeyPath:@"values.TagCloud.ClickCountWeight"];
	
	[sortDescriptor release];
	[mainController release];
	[visibleTags release];
	[activePrefixFilter release];
	[filterEngineConnection release];
	[filterEngine release];
	[searchFieldString release];
	[super dealloc];
}

#pragma mark KVO
- (void)observeValueForKeyPath:(NSString *)keyPath
					  ofObject:(id)object 
                        change:(NSDictionary *)change
                       context:(void *)context
{
	if ([keyPath isEqualToString:@"searchFieldString"])
	{
		[self searchFieldStringHasChanged];
	}
	else if ([keyPath isEqual:@"values.TagCloud.SortKey"])
	{
		sortKey = [[[NSUserDefaultsController sharedUserDefaultsController] valueForKeyPath:@"values.TagCloud.SortKey"] intValue];
		[self updateSortDescriptor];
		NSMutableArray *currentVisibleTags = [visibleTags mutableCopy];
		[self setVisibleTags:currentVisibleTags];
		[currentVisibleTags release];
	}
	else if ([keyPath isEqualToString:@"values.TagCloud.ClickCountWeight"])
	{
		[self reset];
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

- (NNTag*)currentBestTag
{
	return currentBestTag;
}

- (void)setCurrentBestTag:(NNTag*)otherTag
{
	[otherTag retain];
	[currentBestTag release];
	currentBestTag = otherTag;
}

- (NSString*)searchFieldString
{
	return searchFieldString;
}

- (void)setSearchFieldString:(NSString*)string
{
	if (!string)
		string = @"";
	
	[searchFieldString release];
	searchFieldString = [string mutableCopy];
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
	
	// remove all subviews
	NSArray *subviews = [controlledView subviews];
	NSEnumerator *e = [subviews objectEnumerator];
	NSView *subview;

	while (subview = [e nextObject])
	{
		[subview removeFromSuperview];
	}
	
	[controlledView addSubview:[mainController view]];
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

- (void)setActivePrefixFilter:(NNStringPrefixFilter*)filter
{
	[filter retain];
	[activePrefixFilter release];
	activePrefixFilter = filter;
}

- (NNStringPrefixFilter*)activePrefixFilter
{
	return activePrefixFilter;
}

- (NSMutableArray*)visibleTags;
{
	return visibleTags;
}

- (void)setVisibleTags:(NSMutableArray*)otherTags
{
	[visibleTags release];
			
	NSArray *sortedArray = [otherTags sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
	visibleTags = [sortedArray mutableCopy];
	
	if ([visibleTags count] > 0)
		[self setCurrentBestTag:[self tagWithBestAbsoluteRating:visibleTags]];
	
	[tagCloud reloadData];
}

- (void)setDisplayTags:(NSMutableArray*)someTags
{
	NSLog(@"setting display tags");
	
	// empty visibleTags
	[self setVisibleTags:[NSMutableArray array]];
	
	// start filtering
	[self filterTags:someTags];
}

- (void)resetDisplayTags
{
	[self setVisibleTags:[tags tags]];
	[filterEngine setObjects:[tags tags]];
	[[[self view] window] makeFirstResponder:tagCloud];
}

- (void)displaySelectedTag:(NNTag*)tag
{
	[tagCloud selectTag:tag];
}

- (void)removeActiveTagButton
{
	[tagCloud removeActiveTagButton];
}

- (NNTags *)tags
{
	return tags;
}

- (PATagCloud *)tagCloud
{
	return tagCloud;
}


#pragma mark tag stuff
- (IBAction)tagButtonClicked:(id)sender
{
	NNTag *tag = [sender genericTag];
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

- (NNTag*)tagWithBestAbsoluteRating:(NSArray*)tagSet
{
	NSEnumerator *e = [tagSet objectEnumerator];
	NNTag *tag;
	NNTag *maxTag;
	
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
	float height = NSHeight([typeAheadView frame]);
	NSScrollView *sv = [tagCloud enclosingScrollView];
	// placed above
	[sv setFrame:NSMakeRect(0,NSMinY([sv frame]),NSWidth([sv frame]),NSHeight([sv frame])+height)];
	[tagCloud setNeedsDisplay:YES];
	
	[typeAheadView setHidden:YES];	
	[self setState:PABrowserViewControllerNormalState];
}

- (void)resetSearchFieldString
{
	[self setSearchFieldString:@""];
}

#pragma mark events
/*- (void)keyDown:(NSEvent*)event 
{
	// get the pressed key
	unichar key = [[event charactersIgnoringModifiers] characterAtIndex:0];
	
	// create character set for testing
	NSCharacterSet *alphanumericCharacterSet = [NSCharacterSet alphanumericCharacterSet];
	
	if (key == NSDeleteCharacter) 
	{
		// if searchFieldString has any content (i.e. user is using type-ahead-find), delete last char
		if ([searchFieldString length] > 0)
		{
			NSString *tmpsearchFieldString = [searchFieldString substringToIndex:[searchFieldString length]-1];
			[self setSearchFieldString:tmpsearchFieldString];
		}
		else if ([mainController isKindOfClass:[PAResultsViewController class]])
		// else delete the last selected tag (if resultsview is active)
		{
			[(PAResultsViewController*)mainController removeLastTag];
		}
	}
	else if ([alphanumericCharacterSet characterIsMember:key]) 
	{
		// only add to searchFieldString if there are any tags, otherwise do nothing
		NSMutableString *tmpsearchFieldString = [searchFieldString mutableCopy];
		[tmpsearchFieldString appendString:[event charactersIgnoringModifiers]];
		
		// TODO replace by filterEngine
//		if ([typeAheadFind hasTagsForPrefix:tmpsearchFieldString])
//		{
			[self setSearchFieldString:tmpsearchFieldString];
//		}
//		else
//		{
//			[[self nextResponder] keyDown:event];
//		}
//		
		[tmpsearchFieldString release];
	}
	else
	{
		// forward unhandled events
		[[self nextResponder] keyDown:event];
	}
}*/

- (void)searchFieldStringHasChanged
{
	[self setVisibleTags:[NSMutableArray array]];
	
	// if searchFieldString has any content, display tags with corresponding prefix
	// else display all tags
	if ([searchFieldString length] > 0)
	{
		// remove old filter
		if (activePrefixFilter)
		{
			[filterEngine removeFilter:[self activePrefixFilter]];
		}
		NNStringPrefixFilter *newFilter = [[[NNStringPrefixFilter alloc] initWithFilterPrefix:searchFieldString] autorelease];
		[filterEngine addFilter:newFilter];
		[self setActivePrefixFilter:newFilter];
	}
	else
	{
		if (activePrefixFilter) 
		{
			[filterEngine removeFilter:[self activePrefixFilter]];
		}		
		[self setActivePrefixFilter:nil];
	}
}

- (void)tagsHaveChanged:(NSNotification*)notification
{
	NSString *changeOperation = [[notification userInfo] objectForKey:NNTagOperation];
	
	if ([self state] == PABrowserViewControllerNormalState)
	{
		if ([changeOperation isEqualToString:NNTagUseChangeOperation])
		{
			[NSObject cancelPreviousPerformRequestsWithTarget:self
													 selector:@selector(setVisibleTags:)
													   object:[tags tags]];
			[self performSelector:@selector(setVisibleTags:)
					   withObject:[tags tags]
					   afterDelay:0.2];
		}
		else
		{
			[self setDisplayTags:[tags tags]];
		}
	}
}

- (void)controlledViewHasChanged
{	
	// resize controlledView to content subview
	NSView *subview = [[controlledView subviews] objectAtIndex:0];
	NSRect subviewFrame = [subview frame];
	NSRect oldFrame = [controlledView frame];
	[subview setFrame:NSMakeRect(0.0,0.0,oldFrame.size.width,oldFrame.size.height)];
	[controlledView setFrame:NSMakeRect(0.0,0.0,oldFrame.size.width,subviewFrame.size.height)];
	[splitView adjustSubviews];
}

#pragma mark tag filtering
- (void)filterTags:(NSArray*)someTags
{
	[filterEngine setObjects:someTags];
	[filterEngine startWithServer:self];
}

- (void)initFilterEngine
{
	[self setupFilterEngine];
	[self setDisplayTags:[tags tags]];
}

- (void)setupFilterEngine
{
	filterEngine = [[NNFilterEngine alloc] init];
	activePrefixFilter = nil;
}

- (void)filteringStarted
{
	//NSLog(@"START");
	[activityIndicator performSelector:@selector(startAnimation:)
							withObject:self
							afterDelay:0.4];
}

- (void)filteringFinished
{
	//NSLog(@"FINISH");
	[NSObject cancelPreviousPerformRequestsWithTarget:activityIndicator
											 selector:@selector(startAnimation:)
											   object:self];
	[activityIndicator stopAnimation:self];
}

- (void)objectsFiltered
{
	//NSLog(@"objects filtered");
	
	[filterEngine lockFilteredObjects];
	[self setVisibleTags:[filterEngine filteredObjects]];
	[filterEngine unlockFilteredObjects];
}

#pragma mark actions
- (void)searchForTag:(NNTag*)aTag
{
	[[self mainController] handleTagActivation:aTag];
}

- (void)manageTags
{
	if ([[self mainController] isKindOfClass:[PATagManagementViewController class]])
	{
		return;
	}
	else
	{
		PATagManagementViewController *tmvController = [[PATagManagementViewController alloc] init];
		[self switchMainControllerTo:tmvController];
		[tmvController release];
	}
}

- (void)showResults
{
	if ([[self mainController] isKindOfClass:[PAResultsViewController class]])
	{
		return;
	}
	else
	{
		PAResultsViewController *rvController = [[PAResultsViewController alloc] init];
		[self switchMainControllerTo:rvController];
		[rvController release];
	}
}

- (void)switchMainControllerTo:(PABrowserViewMainController*)controller
{
	[self resetSearchFieldString];
	//[[[self view] window] makeFirstResponder:tagCloud];
	[self setMainController:controller];
}

- (void)reset
{
	[self showResults];
	[mainController reset];
}

- (void)unbindAll
{
	[self removeObserver:tagCloud forKeyPath:@"visibleTags"];
	[self removeObserver:self forKeyPath:@"searchFieldString"];
	[searchField unbind:@"value"];
}

- (void)makeControlledViewFirstResponder
{
	[[[self view] window] makeFirstResponder:[mainController dedicatedFirstResponder]];
}

- (void)controlTextDidChange:(NSNotification *)aNotification
{
	NSDictionary *userInfo = [aNotification userInfo];
	NSText *fieldEditor = [userInfo objectForKey:@"NSFieldEditor"];
	NSString *currentString = [fieldEditor string];
	
	// TODO this has to be handled by filter ...
	if ([currentString isNotEqualTo:@""]) //&& ![typeAheadFind hasTagsForPrefix:currentString])
	{
		NSString *newString = [currentString substringToIndex:[currentString length]-1];
		[fieldEditor setString:newString];
	}
}

- (void)reloadData
{
	sortKey = [[NSUserDefaults standardUserDefaults] integerForKey:@"TagCloud.SortKey"];
	[self updateSortDescriptor];
	NSMutableArray *currentVisibleTags = [visibleTags mutableCopy];
	[self setVisibleTags:currentVisibleTags];
	[currentVisibleTags release];
}


#pragma mark drag & drop stuff
- (void)taggableObjectsHaveBeenDropped:(NSArray*)objects
{
	TaggerController *taggerController = [[TaggerController alloc] init];
	[[NSApplication sharedApplication] activateIgnoringOtherApps:YES];
	NSWindow *taggerWindow = [taggerController window];
	[taggerWindow makeKeyAndOrderFront:nil];
	[taggerController addTaggableObjects:objects];
}


#pragma mark Split View
- (float)splitView:(NSSplitView *)sender constrainMinCoordinate:(float)proposedMin ofSubviewAt:(int)offset
{
	return SPLITVIEW_PANEL_MIN_HEIGHT;
}

- (float)splitView:(NSSplitView *)sender constrainMaxCoordinate:(float)proposedMax ofSubviewAt:(int)offset
{
	NSRect frame = [sender frame];
	return frame.size.height - SPLITVIEW_PANEL_MIN_HEIGHT;
}

#pragma mark sorting
- (void)updateSortDescriptor
{
	[sortDescriptor release];
	
	// sort otherTags accorings to userDefaults
	if (sortKey == PATagCloudNameSortKey)
	{
		sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES selector:@selector(caseInsensitiveCompare:)];
	}
	else if (sortKey == PATagCloudRatingSortKey)
	{
		sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"absoluteRating" ascending:NO];
	}
	else
	{
		// default to name
		sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES selector:@selector(caseInsensitiveCompare:)];
	}
}

@end
