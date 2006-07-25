/* PAResultsOutlineView */

#import <Cocoa/Cocoa.h>
#import "PAResultsItemCell.h"
#import "PAResultsMultiItemCell.h"
#import "PAResultsMultiItemThumbnailCell.h"
#import "PAQuery.h"

@interface PAResultsOutlineView : NSOutlineView
{
	PAQuery *query;
	
	// Stores the last up or down arrow function key to get the direction of key navigation
	unsigned int lastUpDownArrowFunctionKey;
	
	// If not nil, forward keyboard events to responder
	NSResponder *responder;
}

- (PAQuery *)query;
- (void)setQuery:(PAQuery *)aQuery;

- (unsigned int)lastUpDownArrowFunctionKey;
- (void)setLastUpDownArrowFunctionKey:(unsigned int)key;

@end
