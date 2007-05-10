/* PAResultsOutlineView */

#import <Cocoa/Cocoa.h>
#import "PAResultsGroupCell.h"
#import "PAResultsItemCell.h"
#import "PAResultsBookmarkCell.h"
#import "PAResultsMultiItemCell.h"
#import "PAResultsMultiItemThumbnailCell.h"

#import "NNTagging/NNQuery.h"


/** Notification is posted when the selection changed.
	userInfo dictionary: Key "SelectedItems" contains the current selection */
extern NSString *PAResultsOutlineViewSelectionDidChangeNotification;


typedef enum _PAResultsDisplayMode
{
	PAListMode = 0,
	PAThumbnailMode = 1
} PAResultsDisplayMode;


@interface NSObject (PAResultsOutlineViewDelegate)

- (void)deleteDraggedItems;

@end


@interface PAResultsOutlineView : NSOutlineView
{
	NNQuery					*query;
	PAResultsDisplayMode	displayMode;
	
	// Stores the last up or down arrow function key to get the direction of key navigation
	unsigned int			lastUpDownArrowFunctionKey;
	
	// If not nil, forward keyboard events to responder
	NSView					*responder;
	
	// A collection of selected NNTaggableObjects. OutlineView stores them for various responders,
	// so that they are able to restore their selection if necessary.
	NSMutableArray			*selectedItems;
	
	// Collection of NNTaggableObjects that have been selected in a MultiItemMatrix. Workaround
	// as those matrixes are released on reloadData and lose their selectedItems.
	NSMutableArray			*selectedItemsOfMultiItem;
}

- (NNQuery *)query;
- (void)setQuery:(NNQuery *)aQuery;

- (unsigned int)lastUpDownArrowFunctionKey;
- (void)setLastUpDownArrowFunctionKey:(unsigned int)key;
- (NSResponder *)responder;
- (void)setResponder:(NSResponder *)aResponder;
- (PAResultsDisplayMode)displayMode;
- (void)setDisplayMode:(PAResultsDisplayMode)mode;

- (void)saveSelection;
- (void)restoreSelection;
- (NSArray *)visibleSelectedItems;

- (NSMutableArray *)selectedItems;
- (void)setSelectedItems:(NSMutableArray *)theItems;
- (NSMutableArray *)selectedItemsOfMultiItem;
- (void)setSelectedItemsOfMultiItem:(NSMutableArray *)theItems;

@end
