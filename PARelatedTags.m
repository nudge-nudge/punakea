//
//  PARelatedTags.m
//  punakea
//
//  Created by Johannes Hoffart on 11.03.06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "PARelatedTags.h"

//will use nsarraycontroller for managing the content array
@implementation PARelatedTags

- (id)initWithQuery:(NSMetadataQuery*)aQuery 
			   tags:(NSMutableArray*)mainTags 
		relatedTagsController:(NSArrayController*)aRelatedTagsController
{
	if (self = [super init])
	{
		[self setQuery:aQuery];
		[self setTags:mainTags];
		controller = [aRelatedTagsController retain];
		
		//register with notificationcenter - listen for changes in the query results -- activeFiles is the query
		nf = [NSNotificationCenter defaultCenter];
		[nf addObserver:self selector:@selector(queryNote:) name:nil object:query];
		
		[self resetRelatedTags];
	}
	return self;
}

- (void)setQuery:(NSMetadataQuery*)aQuery 
{
	[aQuery retain];
	[query release];
	query = aQuery;
}

- (void)setTags:(NSMutableArray*)mainTags
{
	[mainTags retain];
	[tags release];
	tags = mainTags;
}

- (void)dealloc 
{
	[nf removeObserver:self];
	[controller release];
	[query release];
	[tags release];
	[super dealloc];
}

//receives notification from [selectedTags arrangedObjects]
- (void)observeValueForKeyPath:(NSString *)keyPath
					  ofObject:(id)object 
                        change:(NSDictionary *)change
                       context:(void *)context
{
	if ([keyPath isEqual:@"arrangedObjects"]) 
	{
		if ([[object arrangedObjects] count] == 0) 
		{
			[self resetRelatedTags];
		}
	}
}

- (void)resetRelatedTags
{
	[controller removeObjects:[controller arrangedObjects]];
	[controller addObjects:tags];
}

//act on query notifications -- relatedTags need to be kept in sync with files
- (void)queryNote:(NSNotification*)note 
{
	NSLog(@"received note");
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
		[controller removeObjects:[controller arrangedObjects]];
		
		while (i--) 
		{
			//get keywords for result
			NSMetadataItem *mditem =  [query resultAtIndex:i];
			NSArray *keywords = [[PATagger sharedInstance] getTagsForFile:[mditem valueForKey:@"kMDItemPath"]];
			
			int j = [keywords count];

			while (j--) 
			{
				PATag *tag = [keywords objectAtIndex:j];
				
				if (![[controller arrangedObjects] containsObject:tag]) 
					[controller addObject:tag];
			}
		}
	}
	
	[query enableUpdates];
}	

@end
