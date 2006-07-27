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

- (void)selectedTagsHaveChanged;
- (void)relatedTagsHaveChanged;
- (void)allTagsHaveChanged;
- (PATag*)tagWithBestAbsoluteRating:(NSArray*)tagSet;

@end

@implementation BrowserViewController

#pragma mark init + dealloc
- (id)initWithNibName:(NSString*)nibName
{
	if (self = [super init])
	{
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		tagCloudSettings = [[NSMutableDictionary alloc] initWithDictionary:[defaults objectForKey:@"TagCloud"]];
		
		tagger = [PATagger sharedInstance];
		tags = [tagger tags];
				
		selectedTags = [[PASelectedTags alloc] init];
		
		query = [[PAQuery alloc] init];
		[query setGroupingAttributes:[NSArray arrayWithObjects:@"kMDItemContentTypeTree", nil]];
		[query setSortDescriptors:[NSArray arrayWithObject:[[[NSSortDescriptor alloc] initWithKey:(id)kMDItemFSName ascending:YES] autorelease]]];
		
		relatedTags = [[PARelatedTags alloc] initWithSelectedTags:selectedTags query:query];
		
		typeAheadFind = [[PATypeAheadFind alloc] init];
		
		buffer = [[NSMutableString alloc] init];
		
		[selectedTags addObserver:self
					   forKeyPath:@"selectedTags"
						  options:0
						  context:NULL];
		
		[relatedTags addObserver:self
					  forKeyPath:@"relatedTags"
						 options:0
						 context:NULL];
		
		[tags addObserver:self
				forKeyPath:@"tags"
				   options:0
				   context:NULL];
		
		[self setVisibleTags:[tags tags]];
			
		//TODO this stuff should be in the superclass!
		[NSBundle loadNibNamed:nibName owner:self];
	}
	return self;
}

- (void)awakeFromNib
{
	[[[self mainView] window] setInitialFirstResponder:tagCloud];
	[outlineView setQuery:query];
}	

- (void)dealloc
{
	[buffer release];
	[typeAheadFind release];
	[relatedTags release];
    [query release];
	[selectedTags release];
	[tagCloudSettings release];
	[super dealloc];
}


#pragma mark accessors
// This method returns a pointer to the view in the nib loaded.
-(NSView*)mainView
{
	return mainView;
}

- (PAQuery*)query 
{
	return query;
}

- (PARelatedTags*)relatedTags;
{
	return relatedTags;
}

- (void)setRelatedTags:(PARelatedTags*)otherRelatedTags
{
	[otherRelatedTags retain];
	[relatedTags release];
	relatedTags = otherRelatedTags;
}

- (PASelectedTags*)selectedTags;
{
	return selectedTags;
}

- (void)setSelectedTags:(PASelectedTags*)otherSelectedTags
{
	[otherSelectedTags retain];
	[selectedTags release];
	selectedTags = otherSelectedTags;
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
			NSLog(@"fatal error, could not sort, specify sortKey in UserDefaults/TagCloud");
		}
		
		NSArray *sortedArray = [otherTags sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
		visibleTags = [sortedArray mutableCopy];
	}
	
	// update type-ahead find
	[typeAheadFind setActiveTags:visibleTags];
	
	if ([visibleTags count] > 0)
		[self setCurrentBestTag:[self tagWithBestAbsoluteRating:visibleTags]];
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

- (NSMutableString*)buffer
{
	return buffer;
}

- (void)setBuffer:(NSMutableString*)string
{
	[string retain];
	[buffer release];
	buffer = string;
}

- (NSOutlineView *)outlineView
{
	return outlineView;
}

- (void)setOutlineView:(NSOutlineView *)anOutlineView
{
	outlineView = anOutlineView;
}

#pragma mark tag stuff
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

//TODO
- (IBAction)clearSelectedTags:(id)sender
{
	[selectedTags removeAllObjectsFromSelectedTags];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
					  ofObject:(id)object 
                        change:(NSDictionary *)change
                       context:(void *)context
{
	if ([keyPath isEqual:@"selectedTags"]) 
	{
		[self selectedTagsHaveChanged];
	}
	
	if ([keyPath isEqual:@"relatedTags"])
	{
		[self relatedTagsHaveChanged];
	}
	
	if ([keyPath isEqual:@"tags"]) 
	{
		[self allTagsHaveChanged];
	}
}

//needs to be called whenever the active tags have been changed
- (void)selectedTagsHaveChanged 
{
	//stop an active query
	if ([query isStarted]) 
		[query stopQuery];
	
	//the query is only started, if there are any tags to look for
	if ([selectedTags count] > 0)
	{
		[query setTags:selectedTags];
		[query startQuery];
	}
	else 
	{
		//there are no selected tags, reset all tags
		[self setVisibleTags:[tags tags]];
	}
}

- (void)relatedTagsHaveChanged
{
	[self setVisibleTags:[relatedTags relatedTags]];
}

- (void)allTagsHaveChanged
{
	/*only do something if there are no selected tags,
	because then the relatedTags are shown */
	if ([selectedTags count] == 0)
	{
		[self setVisibleTags:[tags tags]];
	}
}

#pragma mark events
- (void)keyDown:(NSEvent*)event 
{
	//TODO exclude everything with modifier keys pressed!
	// get the pressed key
	NSLog(@"BVC keyDown: %x", [[event characters] characterAtIndex:0]);
	unichar key = [[event charactersIgnoringModifiers] characterAtIndex:0];
	
	// create character set for testing
	NSCharacterSet *alphanumericCharacterSet = [NSCharacterSet alphanumericCharacterSet];
	
	if (key == NSDeleteCharacter) 
	{
		// if buffer has any content (i.e. user is using type-ahead-find), delete last char
		if ([buffer length] > 0)
		{
			NSRange range = NSMakeRange([buffer length] - 1,1);
			[buffer deleteCharactersInRange:range];
		}
		else if ([selectedTags count] > 0)
		// else delete the last selected tag
		{
			[selectedTags removeObjectFromSelectedTagsAtIndex:[selectedTags count]-1];
		}
	}
	else if ([alphanumericCharacterSet characterIsMember:key]) 
	{
		// only add to buffer if there are any tags, otherwise do nothing
		NSMutableString *tmpBuffer = [buffer mutableCopy];
		[tmpBuffer appendString:[event charactersIgnoringModifiers]];
		
		if ([typeAheadFind hasTagsForPrefix:tmpBuffer])
		{
			[buffer appendString:[event charactersIgnoringModifiers]];
		}
		else
		{
			// TODO give user negative feedback
		}
		
		[tmpBuffer release];
	}
	else
	{
		// forward unhandled events
		[[self nextResponder] keyDown:event];
	}
	
	// if buffer has any content, display tags with corresponding prefix
	// else display all tags
	if ([buffer length] > 0)
	{
		[typeAheadFind setPrefix:buffer];
		[self setVisibleTags:[typeAheadFind matchingTags]];
	}
	else
	{
		// only set if not already set
		if (!(visibleTags == [tags tags]))
		{
			[self setVisibleTags:[tags tags]];
		}
	}
		
	NSLog(@"buffer: %@",buffer);
}

#pragma mark Temp
- (void)setGroupingAttributes:(id)sender;
{
	NSSegmentedControl *sc = sender;
	if([sc selectedSegment] == 0) {
		[query setGroupingAttributes:[NSArray arrayWithObjects:@"kMDItemContentTypeTree", nil]];
	}
	if([sc selectedSegment] == 1) {
		[query setGroupingAttributes:[NSArray arrayWithObjects:nil]];
	}
}

@end
