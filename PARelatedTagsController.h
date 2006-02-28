/* PARelatedTagsController */

#import <Cocoa/Cocoa.h>
#import "PATaggerInterface.h"

@interface PARelatedTagsController : NSArrayController {
	NSNotificationCenter *nf;
	NSMetadataQuery *query;
}

- (void)setupWithQuery:(NSMetadataQuery*)aQuery;
- (void)updateRelatedTags;

@end
