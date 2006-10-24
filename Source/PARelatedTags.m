//
//  PARelatedTags.m
//  punakea
//
//  Created by Johannes Hoffart on 11.03.06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "PARelatedTags.h"

@interface PARelatedTags (PrivateAPI)

- (void)updateRelatedTags;
- (PATag*)getTagWithBestAbsoluteRating:(NSArray*)tags;

@end

@implementation PARelatedTags

#pragma mark init + dealloc

- (id)initWithSelectedTags:(PASelectedTags*)otherSelectedTags query:(PAQuery*)aQuery;
{
	if (self = [super init])
	{	
		tagger = [PATagger sharedInstance];
		tags = [tagger tags];
		
		[self setUpdating:NO];
		
		[self setQuery:aQuery];
		[self setRelatedTags:[[NSMutableArray alloc] init]];
		[self setSelectedTags:otherSelectedTags];
		
		//register with notificationcenter - listen for changes in the query results -- activeFiles is the query
		nc = [NSNotificationCenter defaultCenter];
		[nc addObserver:self selector:@selector(queryNote:) name:nil object:query];
	}
	return self;
}

- (void)dealloc 
{
	[nc removeObserver:self];
	[relatedTags release];
	[query release];
	[super dealloc];
}

#pragma mark accessors
- (void)addTag:(PATag*)aTag
{
	[relatedTags addObject:aTag];
	
	[nc postNotificationName:@"PARelatedTagsHaveChanged" object:self];
}

- (void)removeTag:(PATag*)aTag
{
	[relatedTags removeObject:aTag];
	
	[nc postNotificationName:@"PARelatedTagsHaveChanged" object:self];
}

- (BOOL)isUpdating
{
	return updating;
}

- (void)setUpdating:(BOOL)flag
{
	updating = flag;
}

- (BOOL)containsTag:(PATag*)aTag
{
	return [relatedTags containsObject:aTag];
}

- (void)setQuery:(PAQuery*)aQuery 
{
	[aQuery retain];
	[query release];
	query = aQuery;
}

- (NSArray*)relatedTagArray
{
	return relatedTags;
}

- (NSMutableArray*)relatedTags;
{
	return relatedTags;
}

- (void)setRelatedTags:(NSMutableArray*)otherTags
{
	[otherTags retain];
	[relatedTags release];
	relatedTags = otherTags;
	
	[nc postNotificationName:@"PARelatedTagsHaveChanged" object:self];
}

- (void)removeAllTags
{
	[relatedTags removeAllObjects];

	[nc postNotificationName:@"PARelatedTagsHaveChanged" object:self];
}

- (PASelectedTags*)selectedTags
{
	return selectedTags;
}

- (void)setSelectedTags:(PASelectedTags*)otherTags
{
	[otherTags retain];
	[selectedTags release];
	selectedTags = otherTags;
}

#pragma mark logic
//act on query notifications -- relatedTags need to be kept in sync with files
- (void)queryNote:(NSNotification*)note 
{
	if ([[note name] isEqualToString:PAQueryDidStartGatheringNotification])
	{
		[self setUpdating:YES];
	}
	else if ([[note name]isEqualToString:PAQueryGatheringProgressNotification]) 
	{
		[self updateRelatedTags];
	}
	else if ([[note name] isEqualToString:PAQueryDidFinishGatheringNotification])
	{
		[self updateRelatedTags];
		[self setUpdating:NO];
		
		// if no tags what so ever have been found, post notification so that tag cloud
		// can update its message
		if ([[query flatResults] count] == 0)
		{
			[nc postNotificationName:@"PARelatedTagsHaveChanged" object:self];
		}
	}
	else if ([[note name] isEqualToString:PAQueryDidResetNotification])
	{
		[self setRelatedTags:[NSMutableArray array]];
	}
}

- (void)updateRelatedTags
{
	[query disableUpdates];
	
	/* NOTE: [query results] or [query resultAtIndex:index] represent a tree structure!
	   not a flat list anymore!
	   Temporary solution: Ues [query flatResults]
	*/

	int i = [[query flatResults] count];
	
	if (i > 0)
	//get the related tags to the current results
	{
		//TODO hack
		[self removeAllTags];
		//disable updates, parse files, continue -- TODO make more efficient, performance will SUCK
		while (i--) 
		{
			//get keywords for result
			PAQueryItem *item = [[query flatResults] objectAtIndex:i];
			NSString *path = [item valueForAttribute:(id)kMDItemPath];
			NSArray *keywords = [[PATagger sharedInstance] keywordsForFile:[PAFile fileWithPath:path]];
			
			int j = [keywords count];

			while (j--) 
			{
				// tag may be nil if there is no simple tag for the given name
				// others apps may edit kMDItemKeywords as well!
				PATag *tag = [tagger tagForName:[keywords objectAtIndex:j]];
				
				if (![tag isKindOfClass:[PATempTag class]] && ![self containsTag:tag] && ![selectedTags containsTag:tag])
				{
					[self addTag:tag];
				}
			}
		}
	}
	
	[query enableUpdates];
}

@end
