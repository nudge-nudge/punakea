/* PAResultsOutlineView */

#import <Cocoa/Cocoa.h>
#import "PAResultsMultiItemCell.h"
#import "PAResultsMultiItemThumbnailCell.h"
#import "PAQuery.h"

@interface PAResultsOutlineView : NSOutlineView
{
	PAQuery *query;
}

- (PAQuery *)query;
- (void)setQuery:(PAQuery *)aQuery;

@end
