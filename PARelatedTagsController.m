#import "PARelatedTagsController.h"

@implementation PARelatedTagsController

- (void)setupWithQuery:(NSMetadataQuery*)aQuery tags:(NSMutableArray*)mainTags
{
	[aQuery retain];
	[query release];
	query = aQuery;
	
	[mainTags retain];
	[tags release];
	tags = mainTags;
	
	//register with notificationcenter - listen for changes in the query results -- activeFiles is the query
	nf = [NSNotificationCenter defaultCenter];
	[nf addObserver:self selector:@selector(queryNote:) name:nil object:query];
	
	[self updateRelatedTags];
}

- (void)dealloc 
{
	[nf removeObserver:self];
	[query release];
	[super dealloc];
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
	
	//with empty query, set to all tags
	if (i == 0) 
	{
		[self addObjects:tags];
	}
	//else get the related tags to the currently selected
	else 
	{
		//disable updates, parse files, continue -- TODO make more efficient, performance will SUCK
		[self removeObjects:[self arrangedObjects]];
		
		while (i--) 
		{
			//get keywords for result
			NSMetadataItem *mditem =  [query resultAtIndex:i];
			NSArray *keywords = [[PATagger sharedInstance] getTagsForFile:[mditem valueForKey:@"kMDItemPath"]];
			
			int j = [keywords count];
			while (j--) 
			{
				if (![[self arrangedObjects] containsObject:[keywords objectAtIndex:j]]) 
				{
					[self addObject:[keywords objectAtIndex:j]];
				}
			}
		}
	}
	
	[query enableUpdates];
}

@end
