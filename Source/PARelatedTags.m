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
		
		[self setQuery:aQuery];
		[self setRelatedTags:[[NSMutableArray alloc] init]];
		[self setSelectedTags:otherSelectedTags];
		
		//register with notificationcenter - listen for changes in the query results -- activeFiles is the query
		nf = [NSNotificationCenter defaultCenter];
		[nf addObserver:self selector:@selector(queryNote:) name:nil object:query];
	}
	return self;
}

- (void)dealloc 
{
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
	for (int i=0;i<[relatedTags count];i++)
	{
		[self removeObjectFromRelatedTagsAtIndex:i];
	}
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
				PATag *tag = [tagger simpleTagForName:[keywords objectAtIndex:j]];
				
				if (![relatedTags containsObject:tag] && ![selectedTags containsObject:tag])
				{
					[self insertObject:tag inRelatedTagsAtIndex:[relatedTags count]];
				}
			}
		}
	}
	
	[query enableUpdates];
}

@end
