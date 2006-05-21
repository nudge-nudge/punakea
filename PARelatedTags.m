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

//will use nsarraycontroller for managing the relatedTags array
@implementation PARelatedTags

#pragma mark init + dealloc


- (id)initWithQuery:(NSMetadataQuery*)aQuery tags:(PATags*)otherTags;
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

#pragma mark accessors ( KVC - compliant )
- (void)setQuery:(NSMetadataQuery*)aQuery 
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

- (void)removeAllObjects
{
	[self setRelatedTags:[NSMutableArray array]];
}

#pragma mark logic
//act on query notifications -- relatedTags need to be kept in sync with files
- (void)queryNote:(NSNotification*)note 
{
	if ([[note name] isEqualToString:NSMetadataQueryDidFinishGatheringNotification] 
		|| [[note name] isEqualToString:NSMetadataQueryGatheringProgressNotification]
		|| [[note name] isEqualToString:NSMetadataQueryDidUpdateNotification]) 
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
