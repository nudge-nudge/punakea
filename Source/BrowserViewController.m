//
//  BrowserViewController.m
//  punakea
//
//  Created by Johannes Hoffart on 27.06.06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "BrowserViewController.h"

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
	if (self = [super initWithNibName:nibName])
	{
		tagger = [PATagger sharedInstance];
		tags = [tagger tags];
		
		selectedTags = [[PASelectedTags alloc] init];
		
		_query = [[PAQuery alloc] init];
		[_query setGroupingAttributes:[NSArray arrayWithObjects:(id)kMDItemContentType, nil]];
		[_query setSortDescriptors:[NSArray arrayWithObject:[[[NSSortDescriptor alloc] initWithKey:(id)kMDItemFSName ascending:YES] autorelease]]];
		
		relatedTags = [[PARelatedTags alloc] initWithQuery:_query];
		
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
	}
	return self;
}

- (void)dealloc
{
	[buffer release];
	[typeAheadFind release];
	[relatedTags release];
    [_query release];
	[selectedTags release];
	[super dealloc];
}

#pragma mark accessors
- (PAQuery*)query 
{
	return _query;
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
		visibleTags = [otherTags retain];
	}
	
	//TODO fix me!!
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
	[selectedTags removeAllObjects];
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
	if ([_query isStarted]) 
		[_query stopQuery];
	
	//the query is only started, if there are any tags to look for
	if ([selectedTags count] > 0)
	{
		[_query setTags:selectedTags];
		[_query startQuery];
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
	NSLog(@"keyDown: %x", [[event characters] characterAtIndex:0]);
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
		// TODO check if it is ok to append event instead of key
		[buffer appendString:[event charactersIgnoringModifiers]];
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
		
	NSLog(@"%@",buffer);
}

#pragma mark Temp
- (void)setGroupingAttributes:(id)sender;
{
	NSSegmentedControl *sc = sender;
	if([sc selectedSegment] == 0) {
		[_query setGroupingAttributes:[NSArray arrayWithObjects:(id)kMDItemContentType, nil]];
	}
	if([sc selectedSegment] == 1) {
		[_query setGroupingAttributes:[NSArray arrayWithObjects:nil]];
	}
}

@end
