// Copyright (c) 2006-2012 nudge:nudge (Johannes Hoffart & Daniel BŠr). All rights reserved.
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
#import "PAResultsGroupCell.h"
#import "PAResultsItemCell.h"
#import "PAResultsBookmarkCell.h"
#import "PAResultsMultiItemCell.h"
#import "PAResultsMultiItemThumbnailCell.h"
#import "NNTagging/NNQuery.h"
#import "QuickLook.h";


@class PAResultsMultiItemMatrix;


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
	NNQuery							*query;
	PAResultsDisplayMode			displayMode;
			
	// Stores the last up or down arrow function key to get the direction of key navigation
	NSUInteger						lastUpDownArrowFunctionKey;
	
	// If not nil, forward keyboard events to responder
	PAResultsMultiItemMatrix		*responder;
	
	// A collection of selected NNTaggableObjects. OutlineView stores them for various responders,
	// so that they are able to restore their selection if necessary.
	NSMutableArray					*selectedItems;
	
	BOOL							skipSaveSelection;				/**< Indicates that OutlineView should not save its selection. */
}

- (NNQuery *)query;
- (void)setQuery:(NNQuery *)aQuery;

- (NSUInteger)lastUpDownArrowFunctionKey;
- (void)setLastUpDownArrowFunctionKey:(NSUInteger)key;
- (NSResponder *)responder;
- (void)setResponder:(NSResponder *)aResponder;
- (PAResultsDisplayMode)displayMode;
- (void)setDisplayMode:(PAResultsDisplayMode)mode;

- (void)saveSelection;
- (void)restoreSelection;

- (void)addSelectedItem:(NNTaggableObject *)item;
- (void)removeSelectedItem:(NNTaggableObject *)item;

- (NSUInteger)numberOfSelectedItems;

- (void)toggleQuickLook;
- (void)openQuickLook;
- (void)closeQuickLook;
- (BOOL)quickLookIsOpen;
- (void)updateQuickLook;
- (void)selectNextPreviewItemInQuickLook;
- (void)selectPreviousPreviewItemInQuickLook;

- (NSArray *)selectedItems;
- (void)setSelectedItems:(NSArray *)theItems;

- (BOOL)isEditingRow:(NSInteger)row;

@end
