// Copyright (c) 2006-2011 nudge:nudge (Johannes Hoffart & Daniel BŠr). All rights reserved.
// 
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import <Cocoa/Cocoa.h>
#import "PAResultsMultiItemPlaceholderCell.h"
#import "PAResultsMultiItemThumbnailCell.h"
#import "NNTagging/NNFile.h"
#import "PAThumbnailItem.h"

@class PAResultsOutlineView;


@interface PAResultsMultiItemMatrix : NSMatrix {

	PAResultsOutlineView			*outlineView;

	NSMutableArray					*items;
	NSCell							*multiItemCell;
	
	NSCell							*selectedCell;
	NSMutableIndexSet				*selectedIndexes;
	NSMutableArray					*selectedCells;
	
	NSEvent							*mouseDownEvent;
	
}

- (void)doubleAction;
- (void)highlightCell:(BOOL)flag cell:(NSCell *)cell;
- (void)highlightCell:(BOOL)flag atRow:(NSInteger)row column:(NSInteger)column;
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
- (NSCell *)selectedCell;
- (NSArray *)selectedCells;
- (NSArray *)selectedItems;
- (void)setSelectedItems:(NSArray *)theSelectedItems;
- (void)setCellClass:(Class)aClass;

@end
