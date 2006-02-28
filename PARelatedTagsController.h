/* PARelatedTagsController */

#import <Cocoa/Cocoa.h>
#import "PATagger.h"

@interface PARelatedTagsController : NSArrayController {
	NSNotificationCenter *nf;
	NSMetadataQuery *query;
}

- (void)setupWithQuery:(NSMetadataQuery*)aQuery;
- (void)updateRelatedTags;

@end
