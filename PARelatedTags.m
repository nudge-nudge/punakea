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
/**
use this init if you want an encapsulated way to get related tags for the
 given selected tags
 @param otherTags all tags
 @param otherSelectedTags tags for which to find related tags
 */
- (id)initWithTags:(PATags*)otherTags selectedTags:(NSMutableArray*)otherSelectedTags 
{
	if (self = [super init])
	{
		[self setRelatedTags:[[NSMutableArray alloc] init]];
	
		[self setSelectedTags:otherSelectedTags];
		[self setTags:otherTags];
	
		//create appropriate query
		query = [[PAQuery alloc] initWithTags:otherSelectedTags];
		nf = [NSNotificationCenter defaultCenter];
		[nf addObserver:self selector:@selector(queryNote:) name:nil object:query];
	}
	return self;
}

/**
use this init if you want performance, it uses a query passed from the outside
 (i.e. from the browser)
 @param aQuery find related tags to the query result
 @param otherTags all tags
 */
- (id)initWithTags:(PATags*)otherTags query:(PAQuery*)aQuery;
{
	if (self = [super init])
	{
		[self setQuery:aQuery];
		[self setRelatedTags:[[NSMutableArray alloc] init]];
		
		//register with notificationcenter - listen for changes in the query results -- activeFiles is the query
		nf = [NSNotificationCenter defaultCenter];
		[nf addObserver:self selector:@selector(queryNote:) name:nil object:query];
		
		[self setTags:otherTags];
	}
	return self;
}

- (void)dealloc 
{
	[tags release];
	[nf removeObserver:self];
	[relatedTags release];
	[query release];
	[super dealloc];
}

#pragma mark accessors
- (void)setQuery:(PAQuery*)aQuery 
{
	[aQuery retain];
	[query release];
	query = aQuery;
}

- (void)setTags:(PATags*)otherTags
{
	[otherTags retain];
	[tags release];
	tags = otherTags;
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
}

- (void)insertObject:(PATag *)tag inRelatedTagsAtIndex:(unsigned int)i
{
	[relatedTags insertObject:tag atIndex:i];
}

- (void)removeObjectFromRelatedTagsAtIndex:(unsigned int)i
{
	[relatedTags removeObjectAtIndex:i];
}

- (void)removeAllObjectsFromRelatedTags
{
	[self setRelatedTags:[NSMutableArray array]];
}

- (NSMutableArray*)selectedTags
{
	return selectedTags;
}

- (void)setSelectedTags:(NSMutableArray*)otherTags
{
	[otherTags retain];
	[selectedTags release];
	selectedTags = otherTags;
	
	[query setTags:selectedTags];
}

- (void)insertObject:(PATag *)tag inSelectedTagsAtIndex:(unsigned int)i
{
	[selectedTags insertObject:tag atIndex:i];
	
	[query setTags:selectedTags];
}

- (void)removeObjectFromSelectedTagsAtIndex:(unsigned int)i
{
	[selectedTags removeObjectAtIndex:i];
	
	[query setTags:selectedTags];
}

#pragma mark logic
//act on query notifications -- relatedTags need to be kept in sync with files
- (void)queryNote:(NSNotification*)note 
{
	if ([[note name] isEqualToString:PAQueryDidFinishGatheringNotification] 
		|| [[note name] isEqualToString:PAQueryGatheringProgressNotification]
		|| [[note name] isEqualToString:PAQueryDidUpdateNotification]) 
	{
		[self updateRelatedTags];
	}
}

//TODO needs to be emptied
- (void)updateRelatedTags 
{
	[query disableUpdates];

	int i = [query resultCount];
	
	if (i > 0)
	//get the related tags to the current results
	{
		//TODO hack
		[self setRelatedTags:[NSMutableArray array]];
		//disable updates, parse files, continue -- TODO make more efficient, performance will SUCK
		while (i--) 
		{
			//get keywords for result
			NSMetadataItem *mditem =  [query resultAtIndex:i];
			NSArray *keywords = [[PATagger sharedInstance] keywordsForFile:[mditem valueForKey:@"kMDItemPath"]];
			
			int j = [keywords count];

			while (j--) 
			{
				PATag *tag = [tags simpleTagForName:[keywords objectAtIndex:j]];
				
				if (![relatedTags containsObject:tag])
				{
					[self insertObject:tag inRelatedTagsAtIndex:[relatedTags count]];
				}
			}
		}
	}
	
	[query enableUpdates];
}

@end
