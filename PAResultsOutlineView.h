/* PAResultsOutlineView */

#import <Cocoa/Cocoa.h>
#import "PAResultsMultiItemCell.h"

@interface PAResultsOutlineView : NSOutlineView
{
	NSMetadataQuery *query;

}

- (NSMetadataQuery *)query;
- (void)setQuery:(NSMetadataQuery *)aQuery;

@end
