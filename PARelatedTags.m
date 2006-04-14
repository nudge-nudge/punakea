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

//will use nsarraycontroller for managing the content array
@implementation PARelatedTags

#pragma mark init + dealloc
- (id)initWithQuery:(NSMetadataQuery*)aQuery
{
	if (self = [super init])
	{
		[self setQuery:aQuery];
		content = [[NSMutableArray alloc] init];
		
		//register with notificationcenter - listen for changes in the query results -- activeFiles is the query
		nf = [NSNotificationCenter defaultCenter];
		[nf addObserver:self selector:@selector(queryNote:) name:nil object:query];
	}
	return self;
}

- (void)dealloc 
{
	[nf removeObserver:self];
	[content release];
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

- (NSMutableArray*)content;
{
	return content;
}

- (void)setContent:(NSMutableArray*)otherTags
{
	[otherTags retain];
	[content release];
	content = otherTags;
}

- (void)insertObject:(PATag *)tag
       inContentAtIndex:(unsigned int)i
{
	[content insertObject:tag atIndex:i];
}

- (void)removeObjectFromContentAtIndex:(unsigned int)i
{
	[content removeObjectAtIndex:i];
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
		//disable updates, parse files, continue -- TODO make more efficient, performance will SUCK
		while (i--) 
		{
			//get keywords for result
			NSMetadataItem *mditem =  [query resultAtIndex:i];
			NSArray *keywords = [[PATagger sharedInstance] getTagsForFile:[mditem valueForKey:@"kMDItemPath"]];
			
			int j = [keywords count];

			while (j--) 
			{
				PATag *tag = [keywords objectAtIndex:j];
				
				if (![content containsObject:tag])
				{
					[self insertObject:tag inContentAtIndex:[content count]];
				}
			}
		}
	}
	
	[query enableUpdates];
}

@end
