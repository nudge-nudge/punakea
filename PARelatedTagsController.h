/* PARelatedTagsController */

#import <Cocoa/Cocoa.h>
#import "PATagger.h"

@interface PARelatedTagsController : NSArrayController {
	NSNotificationCenter *nf;
	NSMetadataQuery *query;
	NSMutableArray *tags;
	NSMutableArray *relatedTags;
}

- (void)setupWithQuery:(NSMetadataQuery*)aQuery;
- (void)updateRelatedTags;

@end
