//
//  PAResultsMultiItemMatrix.h
//  punakea
//
//  Created by Daniel on 17.04.06.
//  Copyright 2006 nudge:nudge. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PAResultsMultiItemPlaceholderCell.h"
#import "PAResultsMultiItemThumbnailCell.h"
#import "PATagging/PATaggableObject.h"
#import "PAThumbnailItem.h"


@interface PAResultsMultiItemMatrix : NSMatrix {

	NSOutlineView			*outlineView;

	NSMutableArray			*items;
	NSCell					*multiItemCell;
	
	NSCell					*selectedCell;
	NSMutableIndexSet		*selectedIndexes;
	NSMutableArray			*selectedCells;
	
	NSEvent					*mouseDownEvent;
	
}

- (void)doubleAction;
- (void)highlightCell:(BOOL)flag cell:(NSCell *)cell;
- (void)highlightCell:(BOOL)flag atRow:(int)row column:(int)column;
- (void)highlightOnlyCell:(NSCell *)cell;
- (void)deselectSelectedCell;
- (void)deselectAllCells;
- (void)deselectAllCellsButCell:(NSCell *)cell;

- (void)moveSelectionUp:(NSEvent *)theEvent;
- (void)moveSelectionDown:(NSEvent *)theEvent;
- (void)moveSelectionRight:(NSEvent *)theEvent;
- (void)moveSelectionLeft:(NSEvent *)theEvent;
- (void)moveSelectionUp:(NSEvent *)theEvent byExtendingSelection:(BOOL)flag;
- (void)moveSelectionDown:(NSEvent *)theEvent byExtendingSelection:(BOOL)flag;
- (void)moveSelectionRight:(NSEvent *)theEvent byExtendingSelection:(BOOL)flag;
- (void)moveSelectionLeft:(NSEvent *)theEvent byExtendingSelection:(BOOL)flag;

- (void)scrollToVisible;

- (NSArray *)items;
- (void)setItems:(NSArray *)theItems;
- (void)setSelectedQueryItems:(NSMutableArray *)theSelectedItems;
- (NSCell *)selectedCell;
- (NSArray *)selectedCells;
- (NSArray *)selectedItems;
- (void)setCellClass:(Class)aClass;

@end
