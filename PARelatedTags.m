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

- (id)initWithQuery:(NSMetadataQuery*)aQuery 
		relatedTagsController:(NSArrayController*)aRelatedTagsController
{
	if (self = [super init])
	{
		[self setQuery:aQuery];
		controller = [aRelatedTagsController retain];
		
		//register with notificationcenter - listen for changes in the query results -- activeFiles is the query
		nf = [NSNotificationCenter defaultCenter];
		[nf addObserver:self selector:@selector(queryNote:) name:nil object:query];
	}
	return self;
}

- (void)setQuery:(NSMetadataQuery*)aQuery 
{
	[aQuery retain];
	[query release];
	query = aQuery;
}

- (void)dealloc 
{
	[nf removeObserver:self];
	[controller release];
	[query release];
	[super dealloc];
}

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
			
			NSMutableArray *tmpTags = [[NSMutableArray alloc] init];
			
			int j = [keywords count];

			while (j--) 
			{
				PATag *tag = [keywords objectAtIndex:j];
				
				if (![tmpTags containsObject:tag])
					[tmpTags addObject:tag];
			}
			
			[controller removeObjects:[controller arrangedObjects]];
			[controller addObjects:tmpTags];
		}
	}
	
	[query enableUpdates];
}

@end
