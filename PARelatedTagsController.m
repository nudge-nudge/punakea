#import "PARelatedTagsController.h"

@implementation PARelatedTagsController

- (void)setupWithQuery:(NSMetadataQuery*)aQuery {
	[aQuery retain];
	[query release];
	query = aQuery;
	
	//register with notificationcenter - listen for changes in the query results -- activeFiles is the query
	nf = [NSNotificationCenter defaultCenter];
	[nf addObserver:self selector:@selector(queryNote:) name:nil object:query];
	
	//TODO add system Tags ... how?
}

- (void)dealloc {
	[nf removeObserver:self];
	[query release];
	[super dealloc];
}

//act on query notifications -- relatedTags need to be kept in sync with files
- (void)queryNote:(NSNotification*)note {
	NSLog(@"received note");
	if ([[note name] isEqualToString:NSMetadataQueryDidFinishGatheringNotification] 
		|| [[note name] isEqualToString:NSMetadataQueryGatheringProgressNotification]
		|| [[note name] isEqualToString:NSMetadataQueryDidUpdateNotification]) {
		[self updateRelatedTags];
	}
}

- (void)updateRelatedTags {
	//disable updates, parse files, continue -- TODO make more efficient, performance will SUCK
	[self removeObjects:[self arrangedObjects]];
	
	[query disableUpdates];
	
	int i = [query resultCount];
	while (i--) {
		//get keywords for result
		NSMetadataItem *mditem =  [query resultAtIndex:i];
		NSArray *keywords = [[PATaggerInterface sharedInstance] getTagsForFile:[mditem valueForKey:@"kMDItemPath"]];
		
		int j = [keywords count];
		while (j--) {
			if (![[self arrangedObjects] containsObject:[keywords objectAtIndex:j]]) {
				[self addObject:[keywords objectAtIndex:j]];
			}
		}
	}
	
	[query enableUpdates];
}

@end
