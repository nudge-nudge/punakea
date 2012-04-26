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

#import "PAResultsMultiItemMatrix.h"


@interface PAResultsMultiItemMatrix (PrivateAPI)

- (void)displayCellsForItems;

- (CGFloat)distanceFromPoint:(NSPoint)sourcePoint to:(NSPoint)destPoint;
- (void)startDrag:(NSEvent *)event;
- (NSImage *)dragImageForMouseDownAtPoint:(NSPoint)point offsetX:(CGFloat *)offsetX y:(CGFloat *)offsetY;

@end


static NSUInteger PAModifierKeyMask = NSShiftKeyMask | NSAlternateKeyMask | NSCommandKeyMask | NSControlKeyMask;


@implementation PAResultsMultiItemMatrix

#pragma mark Init + Dealloc
- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
		[self setCellClass:[PAResultsMultiItemPlaceholderCell class]];
		[self renewRows:1 columns:0];
		[self setIntercellSpacing:NSMakeSize(3, 3)];
		[self setMode:NSHighlightModeMatrix];
		[self setTarget:self];
		
		selectedIndexes = [[NSMutableIndexSet alloc] init];
		selectedCells = [[NSMutableArray alloc] init];
		
		// Get notification frameDidChange
		[self setPostsFrameChangedNotifications:YES];
		
		NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
		
		[nc addObserver:self
			   selector:@selector(frameDidChange:)
		           name:(id)NSViewFrameDidChangeNotification
			     object:self];
		
		[nc addObserver:self
			   selector:@selector(thumbnailWasGenerated:)
				   name:@"PAThumbnailManagerDidFinishGeneratingItemNotification"
				 object:nil];
	}
    return self;
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	if(selectedCells) [selectedCells release];
	if(selectedIndexes) [selectedIndexes release];
	if(items) [items release];
	[super dealloc];
}


#pragma mark Notifications
- (void)viewDidMoveToSuperview
{
	outlineView = [self superview];
}

- (void)frameDidChange:(NSNotification *)note
{	
	if([self numberOfRows] <= 0) return;
	
	NSRect frame = [self frame];
	NSSize cellSize = [self cellSize];
	NSSize intercellSpacing = [self intercellSpacing];
	
	NSInteger numberOfItemsPerRow = frame.size.width / (cellSize.width + intercellSpacing.width);
	
	// Break if numberOfItemsPerRow hasn't changed
	if([self numberOfColumns] == numberOfItemsPerRow) return;
	
	NSMutableArray *cellArray = [NSMutableArray arrayWithCapacity:100];
	
	for(NSInteger row = 0; row < [self numberOfRows]; row++)
	{
		for(NSInteger column = 0; column < [self numberOfColumns]; column++)
		{
			NSTextFieldCell *cell = [self cellAtRow:row column:column];
			[cellArray addObject:[cell retain]];
		}
	}
	
	for(NSInteger i = 0; i < [self numberOfRows]; i++)
	{
		[self removeRow:i];
	}
	[self renewRows:1 columns:0];
	
	NSTextFieldCell *aCell;
	NSEnumerator *enumerator = [cellArray objectEnumerator];
	NSInteger row = 0;
	NSInteger column = 0;
	while(aCell = [enumerator nextObject])
	{				
		if(column == numberOfItemsPerRow) 
		{
			[self addRow];
			
			// Fill the new row with placeholder cells
			for(NSInteger i = 0; i < column; i++)
			{
				NSTextFieldCell *cell = [[[PAResultsMultiItemPlaceholderCell alloc]
										   initTextCell] autorelease];
				[self putCell:cell atRow:row+1 column:i];
			}
			
			row++;
			column = 0;
		}
		
		// Add columns when adding cells in first row
		if(row == 0)
		{
			[self addColumnWithCells:[NSArray arrayWithObject:aCell]];
		} else {
			[self putCell:aCell atRow:row column:column];
		}
		column++;
		[aCell release];
	}
	
	//[self deselectAllCells];
}


#pragma mark Actions
/* TODO
- (void)scrollCellToVisibleAtRow:(int)row column:(int)column
{	
	NSRect cellFrame = [self cellFrameAtRow:row column:column];	
	NSRect frame = [self frame];
	
	NSRect rect = NSMakeRect(frame.origin.x + cellFrame.origin.x,
							 frame.origin.y + cellFrame.origin.y - 40,
							 cellFrame.size.width,
							 cellFrame.size.height + 80);
		
	//if(cellFrame.origin.y < 0) cellFrame.origin.y = 0;
	
	[outlineView scrollRectToVisible:rect];
}
*/

- (void)displayCellsForItems
{
	for(NSInteger i = 0; i < [self numberOfRows]; i++)
	{
		[self removeRow:i];
	}
	[self renewRows:1 columns:0];
	
	NSRect frame = [self frame];
	NSSize cellSize = [self cellSize];
	NSSize intercellSpacing = [self intercellSpacing];
	
	NSInteger numberOfItemsPerRow = frame.size.width / (cellSize.width + intercellSpacing.width);
	
	NSEnumerator *enumerator = [items objectEnumerator];
	NNFile *anObject;
	
	NSInteger row = 0;
	NSInteger column = 0;
	while(anObject = [enumerator nextObject])
	{
		NSTextFieldCell *cell =
			[[[[self cellClass] alloc]
				initTextCell:anObject] autorelease];				
		
		if(column == numberOfItemsPerRow) 
		{
			[self addRow];
			
			// Fill the new row with placeholder cells
			for(NSInteger i = 0; i < column; i++)
			{
				NSTextFieldCell *thisCell = [[[PAResultsMultiItemPlaceholderCell alloc]
										   initTextCell] autorelease];
				[self putCell:thisCell atRow:row+1 column:i];
			}
			
			row++;
			column = 0;
		}
		
		// Add columns when adding cells in first row
		//NSLog(@"%d,%d,%d", row, column, numberOfItemsPerRow);
		if(row == 0)
		{
			[self addColumnWithCells:[NSArray arrayWithObject:cell]];
		} else {
			[self putCell:cell atRow:row column:column];
		}
		column++;
	}
	
	// Highlight cells if there are already some selected indexes
	NSUInteger idx = [selectedIndexes firstIndex];
	while(idx != NSNotFound)
	{
		row = idx / [self numberOfColumns];
		column = idx - row * [self numberOfColumns];
	
		[self highlightCell:YES atRow:row column:column];
		
		idx = [selectedIndexes indexGreaterThanIndex:idx];
	}
}

- (void)doubleAction
{	
	NSUInteger idx = [selectedIndexes firstIndex];
		
	while (idx != NSNotFound)
	{
		NNTaggableObject *item = [items objectAtIndex:idx];
		NSString *path = [item valueForAttribute:(id)kMDItemPath];
		[[NSWorkspace sharedWorkspace] openFile:path];		
		
		idx = [selectedIndexes indexGreaterThanIndex:idx];
	}
}

- (void)highlightCell:(BOOL)flag cell:(NSCell *)cell
{
	NSInteger row, column;
	[self getRow:&row column:&column ofCell:cell];
	
	[self highlightCell:flag atRow:row column:column];
}

- (void)highlightCell:(BOOL)flag atRow:(NSInteger)row column:(NSInteger)column
{
	if(row == -1 || column == -1)
	{
		if(flag) selectedCell = nil;
		return;
	}

	NSCell *cell = [self cellAtRow:row column:column];
	[cell setHighlighted:flag];
	
	// Return if this cell is a placeholder
	if([cell isMemberOfClass:[PAResultsMultiItemPlaceholderCell class]])
	{
		if(flag) selectedCell = nil;
		return;
	}
	
	NSUInteger idx = row * [self numberOfColumns] + column;
	
	if(flag)
	{
		selectedCell = cell;
		[selectedIndexes addIndex:idx];
		[selectedCells addObject:cell];
		
		[outlineView addSelectedItem:[items objectAtIndex:idx]];
		
		[self scrollCellToVisibleAtRow:row column:column];
		
	} else {
		[selectedIndexes removeIndex:idx];
		[selectedCells removeObject:cell];
		
		[outlineView removeSelectedItem:[items objectAtIndex:idx]];
	}
	
	// Post notification
	[[NSNotificationCenter defaultCenter] postNotificationName:NSOutlineViewSelectionDidChangeNotification
														object:outlineView];
}

- (void)highlightOnlyCell:(NSCell *)cell
{
	[self deselectAllCellsButCell:cell];

	NSInteger row, column;
	[self getRow:&row column:&column ofCell:cell];

	[cell setEditable:NO];
	[self highlightCell:YES atRow:row column:column];
}

- (void)deselectSelectedCell
{
	[self highlightCell:NO cell:[self selectedCell]];
}

- (void)deselectAllCells
{
	[self deselectAllCellsButCell:nil];
}

- (void)deselectAllCellsButCell:(NSCell *)cell
{
	NSEnumerator *enumerator = [[self cells] objectEnumerator];
	NSCell *aCell;
	
	while(aCell = [enumerator nextObject])
	{
		if(cell != aCell)
		{
			NSInteger r, c;
			[self getRow:&r column:&c ofCell:aCell];
			[self highlightCell:NO atRow:r column:c];
		}
	}
}

- (void)selectAll:(id)sender
{
	NSEnumerator *enumerator = [[self cells] objectEnumerator];
	NSCell *aCell;
	
	while(aCell = [enumerator nextObject])
	{
		[self highlightCell:YES cell:aCell];
	}
}

- (void)moveSelectionUp:(NSEvent *)theEvent
{
	[self moveSelectionUp:theEvent byExtendingSelection:NO];
}

- (void)moveSelectionUp:(NSEvent *)theEvent byExtendingSelection:(BOOL)flag
{	
	NSCell *cell;
	NSInteger row = [self numberOfRows];
	NSInteger column = 0;
	NSInteger r, c;
	NSEnumerator *selCellsEnumerator = [[self selectedCells] objectEnumerator];
	
	while(cell = [selCellsEnumerator nextObject])
	{
		[self getRow:&r column:&c ofCell:cell];
		if(r < row)
		{
			row = r;
			column = c;
		}
		if (r == row && c < column)
		{
			row = r;
			column = c;
		}
	}
	
	if(row != 0) 
	{
		selCellsEnumerator = [[self selectedCells] objectEnumerator];
		[self deselectAllCells];
		
		if(flag)
		{
			while(cell = [selCellsEnumerator nextObject])
			{
				NSInteger curRow, curCol;
				[self getRow:&curRow column:&curCol ofCell:cell];
				[self highlightCell:YES atRow:curRow column:curCol];
			}
		}

		[self highlightCell:YES atRow:row-1 column:column];
	} /*else {
		// If this is the topmost multi item cell, do nothing as we are at the topmost item
		// in our OutlineView

		int rowInOutlineView = [outlineView rowForItem:items];	
	
		if(rowInOutlineView > 1)
		{
			// Pass keyDown event back to OutlineView
			[outlineView setResponder:nil];
			[outlineView keyDown:theEvent];
		}
	}*/
}

- (void)moveSelectionDown:(NSEvent *)theEvent
{
	[self moveSelectionDown:theEvent byExtendingSelection:NO];
}

- (void)moveSelectionDown:(NSEvent *)theEvent byExtendingSelection:(BOOL)flag
{	
	NSCell *cell;
	NSInteger row = -1;
	NSInteger column = 0;
	NSInteger r, c;
	NSEnumerator *selCellsEnumerator = [[self selectedCells] objectEnumerator];
	
	while(cell = [selCellsEnumerator nextObject])
	{
		[self getRow:&r column:&c ofCell:cell];
		if(r > row)
		{
			row = r;
			column = c;
		}
		if (r == row && c > column)
		{
			row = r;
			column = c;
		}
	}
	
	if(row != [self numberOfRows] - 1) 
	{
		// If the cell that is to be selected represents a placeholder, we will ignore it
		while([[[self cellAtRow:row+1 column:column] class] isEqualTo:[PAResultsMultiItemPlaceholderCell class]])
		{
			column--;
		}
	
		selCellsEnumerator = [[self selectedCells] objectEnumerator];
		[self deselectAllCells];
		
		if(flag)
		{
			while(cell = [selCellsEnumerator nextObject])
			{
				NSInteger curRow, curCol;
				[self getRow:&curRow column:&curCol ofCell:cell];
				[self highlightCell:YES atRow:curRow column:curCol];
			}
		}
		
		[self highlightCell:YES atRow:row+1 column:column];
	} /*else {
		// If this is the lowermost multi item cell, do nothing as we are at the lowermost item
		// in our OutlineView

		int rowInOutlineView = [outlineView rowForItem:items];	
	
		if(rowInOutlineView < [outlineView numberOfRows] - 1)
		{
			// Pass keyDown event back to OutlineView
			[outlineView setResponder:nil];
			[outlineView keyDown:theEvent];
		}
	}*/
}

- (void)moveSelectionRight:(NSEvent *)theEvent
{
	[self moveSelectionRight:theEvent byExtendingSelection:NO];
}

- (void)moveSelectionRight:(NSEvent *)theEvent byExtendingSelection:(BOOL)flag
{	
	NSCell *cell;
	NSInteger row = 0;
	NSInteger column = -1;
	NSInteger r, c;
	NSEnumerator *selCellsEnumerator = [[self selectedCells] objectEnumerator];
	
	while(cell = [selCellsEnumerator nextObject])
	{
		[self getRow:&r column:&c ofCell:cell];
		if(r > row)
		{
			row = r;
			column = c;
		}
		if (r == row && c > column)
		{
			row = r;
			column = c;
		}
	}
	
	column++;
	if(column == [self numberOfColumns])
	{
		// Finder now just stops when we're at the right-most item.
		// We stick to this, too.
		return;
		
		// Wrap selection into next line
		//column--;
		//row++;
	}
	
	// If the cell that is to be selected represents a placeholder, we will ignore it
	// and directly send an arrow down event
	if([[[self cellAtRow:row column:column] class] isEqualTo:[PAResultsMultiItemPlaceholderCell class]])
	{
		row = [self numberOfRows];
	}
	
	if(row != [self numberOfRows]) 
	{
		selCellsEnumerator = [[self selectedCells] objectEnumerator];
		[self deselectAllCells];
		
		if(flag)
		{
			while(cell = [selCellsEnumerator nextObject])
			{
				NSInteger curRow, curCol;
				[self getRow:&curRow column:&curCol ofCell:cell];
				[self highlightCell:YES atRow:curRow column:curCol];
			}
		}		
		
		[self highlightCell:YES atRow:row column:column];
	}
	
	// The following snippet was the old behavior.
	// Finder now just stops when we're at the right-most item.
	// We stick to this, too.
	/*else {		
		// Modify event so that selection moves down instead of right (if possible)
		unichar downArrowChar = NSDownArrowFunctionKey;
		theEvent = [NSEvent keyEventWithType:[theEvent type]
		                            location:[self convertPoint:[theEvent locationInWindow] fromView:nil]
							   modifierFlags:[theEvent modifierFlags]
							       timestamp:[theEvent timestamp]
								windowNumber:[theEvent windowNumber]
							         context:[theEvent context]
								  characters:[NSString stringWithCharacters:&downArrowChar length:1]
				 charactersIgnoringModifiers:[NSString stringWithCharacters:&downArrowChar length:1]
								   isARepeat:[theEvent isARepeat]
								     keyCode:125];
		
		[self moveSelectionDown:theEvent byExtendingSelection:flag];
	}*/
}

- (void)moveSelectionLeft:(NSEvent *)theEvent
{
	[self moveSelectionLeft:theEvent byExtendingSelection:NO];
}

- (void)moveSelectionLeft:(NSEvent *)theEvent byExtendingSelection:(BOOL)flag
{	
	NSCell *cell;
	NSInteger row = [self numberOfRows] - 1;
	NSInteger column = [self numberOfColumns] - 1;
	NSInteger r, c;
	NSEnumerator *selCellsEnumerator = [[self selectedCells] objectEnumerator];
	
	while(cell = [selCellsEnumerator nextObject])
	{
		[self getRow:&r column:&c ofCell:cell];
		if(r < row)
		{
			row = r;
			column = c;
		}
		if (r == row && c < column)
		{
			row = r;
			column = c;
		}
	}
	
	column--;
	if(column == -1)
	{
		return;
		// Wrap selection into next line
		//column++;
		//row--;
	}
	
	if(row != -1) 
	{
		selCellsEnumerator = [[self selectedCells] objectEnumerator];
		[self deselectAllCells];
		
		if(flag)
		{
			while(cell = [selCellsEnumerator nextObject])
			{
				NSInteger curRow, curCol;
				[self getRow:&curRow column:&curCol ofCell:cell];
				[self highlightCell:YES atRow:curRow column:curCol];
			}
		}		
		
		[self highlightCell:YES atRow:row column:column];
	} else {		
		// Modify event so that selection moves up instead of left (if possible)
		unichar upArrowChar = NSUpArrowFunctionKey;
		theEvent = [NSEvent keyEventWithType:[theEvent type]
		                            location:[self convertPoint:[theEvent locationInWindow] fromView:nil]
							   modifierFlags:[theEvent modifierFlags]
							       timestamp:[theEvent timestamp]
								windowNumber:[theEvent windowNumber]
							         context:[theEvent context]
								  characters:[NSString stringWithCharacters:&upArrowChar length:1]
				 charactersIgnoringModifiers:[NSString stringWithCharacters:&upArrowChar length:1]
								   isARepeat:[theEvent isARepeat]
								     keyCode:126];
		
		[self moveSelectionUp:theEvent byExtendingSelection:flag];
	}
}

- (void)scrollToVisible
{
	// Scroll selected cell to visible
	if([self selectedCell])
	{
		NSInteger row, column;
		[self getRow:&row column:&column ofCell:[self selectedCell]];
	
		[self scrollRectToVisible:[self cellFrameAtRow:row column:column]];
	}
}


#pragma mark Events
- (void)keyDown:(NSEvent *)theEvent
{
	if([theEvent type] == NSKeyDown)
	{			
		unichar key = [[theEvent charactersIgnoringModifiers] characterAtIndex:0];
		
		BOOL shiftKey = ([theEvent modifierFlags] & NSShiftKeyMask) != 0;
		BOOL commandKey = ([theEvent modifierFlags] & NSCommandKeyMask) != 0;
		
		// Respond to Command+Arrow-Down
		if(key == NSDownArrowFunctionKey && commandKey)
		{
			[[self target] performSelector:@selector(doubleAction)];
			return;
		}
		
		// Begin editing on Return or Enter
		if((key == NSEnterCharacter || key == '\r') &&
		   [selectedIndexes count] == 1)
		{
			[self beginEditing];
			return;
		}
			
		switch(key)
		{
			case NSRightArrowFunctionKey: [self moveSelectionRight:theEvent byExtendingSelection:shiftKey];
				break;
			case NSLeftArrowFunctionKey: [self moveSelectionLeft:theEvent byExtendingSelection:shiftKey];
				break;
			case NSUpArrowFunctionKey: [self moveSelectionUp:theEvent byExtendingSelection:shiftKey];
				break;
			case NSDownArrowFunctionKey: [self moveSelectionDown:theEvent byExtendingSelection:shiftKey];
				break;
			default:
				break;
		}
		
		// Open/close Quick Look on Space
		if (key == 32)
		{			
			[outlineView toggleQuickLook];
		}
		
		// Close Quick Look on ESC
		if (key == 27)
		{
			[outlineView closeQuickLook];
		}
		
		// TODO: Too slow, but we need to invalidate our visibleRect if key was pressed for a while
		//[outlineView setNeedsDisplayInRect:[outlineView visibleRect]];
	}
	
	//[super keyDown:theEvent];
}

- (void)mouseDown:(NSEvent *)theEvent
{
	if(mouseDownEvent) [mouseDownEvent autorelease];
	mouseDownEvent = [theEvent retain];

	// Make sure the corresponding multiitemcell in our outlineView is highlighted
	NSPoint locationInOutlineView = [outlineView convertPoint:[theEvent locationInWindow] fromView:nil];
	NSInteger row = [outlineView rowAtPoint:locationInOutlineView];	
	BOOL byExtendingSelection = ([theEvent modifierFlags] & NSShiftKeyMask) ||
								([theEvent modifierFlags] & NSCommandKeyMask);	
	[outlineView selectRow:row byExtendingSelection:byExtendingSelection];
	[[self window] makeFirstResponder:outlineView];
	
	
	// Now, perform click action	
	static CGFloat doubleClickThreshold = 0.0;    
    if (doubleClickThreshold == 0.0)
    {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        doubleClickThreshold = [defaults floatForKey:@"com.apple.mouse.doubleClickThreshold"];
        
        // if we couldn't find the value in the user defaults, take a conservative estimate
        if (doubleClickThreshold == 0.0) doubleClickThreshold = 0.8;
    }

    BOOL    modifierDown    = ([theEvent modifierFlags] & PAModifierKeyMask) != 0;
    BOOL    doubleClick     = ([theEvent clickCount] == 2);
    
	NSPoint location = [theEvent locationInWindow];
	location = [self convertPoint:location fromView:nil];
		
	NSInteger column;
	[self getRow:&row column:&column forPoint:location];
	
	NSCell *cell = [self cellAtRow:row column:column];
	[cell setEditable:NO];
    
    if (modifierDown == NO && doubleClick == NO)
    {
		NSInteger count = [selectedIndexes count];
		if([self selectedCell] == cell && count <= 1)
		{
			// cancel any previous editing action
			[NSObject cancelPreviousPerformRequestsWithTarget:self
													 selector:@selector(beginEditing)
										               object:nil];
													   
			// Cancel any late highlighting
			[NSObject cancelPreviousPerformRequestsWithTarget:self
													 selector:@selector(highlightOnlyCell)
										               object:cell];
		
			// perform editing like finder
			[self performSelector:@selector(beginEditing)
			           withObject:nil
					   afterDelay:doubleClickThreshold];
		}
		else
		{	
			// cancel editing action
			[NSObject cancelPreviousPerformRequestsWithTarget:self
													 selector:@selector(beginEditing)
													   object:nil];
			
			NSUInteger cellIndex = row * [self numberOfColumns] + column;			
			if([selectedIndexes count] > 1 && [selectedIndexes containsIndex:cellIndex])
			{
				// Select only this cell if the click becomes no double click
				[self performSelector:@selector(highlightOnlyCell:)
			           withObject:cell
					   afterDelay:doubleClickThreshold];
			} else {
				// Select only this cell instantly
				[self deselectAllCellsButCell:cell];	
				[self highlightCell:YES atRow:row column:column];
			}
			
			// we still need to pass the event to super, to handle things like dragging, but 
			// we have disabled row deselection by overriding selectRowIndexes:byExtendingSelection:
			//[super mouseDown:theEvent]; 
		}
    }
    else if(doubleClick)
    {		
		// cancel editing action
		[NSObject cancelPreviousPerformRequestsWithTarget:self
										         selector:@selector(beginEditing)
										           object:nil];
												   
		// Cancel any late highlighting
		[NSObject cancelPreviousPerformRequestsWithTarget:self
												 selector:@selector(highlightOnlyCell:)
												   object:cell];

        // perform double action
		//if([[[self itemAtRow:mouseRow] class] isNotEqualTo:[NSMetadataQueryResultGroup class]])
		//	[[self target] performSelector:[self doubleAction]];
		[self doubleAction];
    }
	else if(modifierDown)
	{
		// Select a range of cells with SHIFT
		if([theEvent modifierFlags] & NSShiftKeyMask)
		{
			NSInteger firstRow = 0, firstColumn = 0;		
			
			if([self selectedCell])	
				[self getRow:&firstRow column:&firstColumn ofCell:[self selectedCell]];	
			
			// Maybe swap first and last indexes if the first cell has a greater index that the
			// last one
			if(firstRow > row ||
			   (firstRow == row && firstColumn > column))
			{
				NSInteger rTemp = firstRow, cTemp = firstColumn;
				firstRow = row;
				firstColumn = column;
				row = rTemp;
				column = cTemp;
			}
			
			NSInteger c = firstColumn;
			for(NSInteger r = firstRow; r <= row; r++)
			{
				while((r < row && c < [self numberOfColumns]) ||
					  (r == row && c <= column))
				{
					[self highlightCell:YES atRow:r column:c];
					c++;
				}
				c = 0;
			}
		}

		// Select multiple cells independently with COMMAND
		if([theEvent modifierFlags] & NSCommandKeyMask)
		{
			[self highlightCell:!([cell isHighlighted]) atRow:row column:column];
		}
	}
}

- (NSMenu *)menuForEvent:(NSEvent *)event
{
	// Make sure the corresponding multiitemcell in our outlineView is highlighted
	NSPoint locationInOutlineView = [outlineView convertPoint:[event locationInWindow] fromView:nil];
	NSInteger row = [outlineView rowAtPoint:locationInOutlineView];	
	BOOL byExtendingSelection = ([event modifierFlags] & NSShiftKeyMask) ||
	([event modifierFlags] & NSCommandKeyMask);	
	[outlineView selectRow:row byExtendingSelection:byExtendingSelection];	
	
	NSPoint location = [self convertPoint:[event locationInWindow] fromView:nil];
	
	NSInteger column;
	[self getRow:&row column:&column forPoint:location];
	
	NSCell *cell = [self cellAtRow:row column:column];
	
	// Item and cell indexes are aligned
	NSUInteger idx = row * [self numberOfColumns] + column;
	
	if (![selectedIndexes containsIndex:idx])
	{
		[self highlightOnlyCell:cell];
	}
	
	return [outlineView menu];
}


#pragma mark Notifications
-(void)thumbnailWasGenerated:(NSNotification *)notification
{
	PAThumbnailItem *thumbItem = (PAThumbnailItem *)[notification object];
	
	if([thumbItem view] == self)
	{
		[self displayRect:[thumbItem frame]];
	}
}


#pragma mark Editing
- (void)beginEditing
{
	// If multiple items are selected, discard editing
	if(![selectedIndexes count] == 1) return;

	NSInteger row, column;
	[self getRow:&row column:&column ofCell:[self selectedCell]];

	[self deselectAllCellsButCell:[self selectedCell]];
	[[self selectedCell] setEditable:YES];
	[self selectCellAtRow:row column:column];
	
	/*NSTextView *textView = [[self window] fieldEditor:NO forObject:self];
	[textView setHorizontallyResizable:NO];
	[textView setVerticallyResizable:YES];
	[[textView textContainer] setHeightTracksTextView:YES];*/
}

- (void)cancelOperation:(id)sender
{		
	NSText *textView = [[self window] fieldEditor:NO forObject:self];
	//[textView setString:[[self itemAtRow:[self selectedRow]] valueForAttribute:(id)kMDItemDisplayName]];
	[textView setTextColor:[NSColor textColor]];

	NSMutableDictionary *newUserInfo;
	newUserInfo = [[NSMutableDictionary alloc] init];
	[newUserInfo setObject:[NSNumber numberWithInteger:NSIllegalTextMovement] forKey:@"NSTextMovement"];

	NSNotification *notification;
	notification = [NSNotification notificationWithName:NSTextDidEndEditingNotification
												 object:textView
											   userInfo:newUserInfo];
		
	[self textDidEndEditing:notification];
	
	[newUserInfo release];
	
	[[self window] makeFirstResponder:self];
}

- (void)textDidChange:(NSNotification *)notification
{
	//[super textDidChange:notification];
	
	NSInteger r, c;
	[self getRow:&r column:&c ofCell:[self selectedCell]];
	
	// Set text color to red if the new destination already exists
	NSInteger idx = r * [self numberOfColumns] + c;
	NNTaggableObject *taggableObject = [items objectAtIndex:idx];
	
	NSText *textView = [notification object];
	NSString *newName = [textView string];
	
	if(![taggableObject validateNewName:newName])
		[textView setTextColor:[NSColor redColor]];
	else 
		[textView setTextColor:[NSColor textColor]];
	
	// Fix frame to resize vertically
	/*NSSize stringSize = [[self attributedStringValue] size];
	
	NSRect newFrame = [[textView superview] frame];
	
	if(stringSize.width - 7 > newFrame.size.width)
	{
		NSNumber *timesNumber = [NSNumber numberWithFloat:(stringSize.width / newFrame.size.width)];
		int times = [timesNumber intValue] + 1;
	
		newFrame.size.height = times * 16;
	
		[[textView superview] setFrame:newFrame];
		
		[[textView superview] setNeedsDisplay:YES];
		[textView setNeedsDisplay:YES];
	}*/
	
	// This causes to make keyboard highlight rect around field editor thicker - at least sometimes...
	//[self setNeedsDisplay:YES];
}

- (void)textDidEndEditing:(NSNotification *)notification
{
	NSText *textView = [notification object];

	// Force editing not to end if text color is red
	if([[textView textColor] isEqualTo:[NSColor redColor]])
	{
		[[self window] makeFirstResponder:textView];
		return;
	}

	// Force editing to end after pressing the Return key
	// See http://developer.apple.com/documentation/Cocoa/Conceptual/TextEditing/Tasks/BatchEditing.html
	
	NSInteger r, c;
	[self getRow:&r column:&c ofCell:[self selectedCell]];

	NSInteger textMovement = [[[notification userInfo] valueForKey:@"NSTextMovement"] integerValue];

	if(textMovement == NSReturnTextMovement)
	{
		NSMutableDictionary *newUserInfo;
		newUserInfo = [[NSMutableDictionary alloc] initWithDictionary:[notification userInfo]];
		[newUserInfo setObject:[NSNumber numberWithInteger:NSIllegalTextMovement] forKey:@"NSTextMovement"];

		notification = [NSNotification notificationWithName:[notification name]
													 object:[notification object]
												   userInfo:newUserInfo];
		
		[[self selectedCell] setEditable:NO];
		[textView removeFromSuperview];		

		[newUserInfo release];
		
		// Forward renaming request to our delegate's query (delegate is equal to the outlineView's delegate)		
		NSInteger					idx = r * [self numberOfColumns] + c;
		NNTaggableObject	*item = [items objectAtIndex:idx];
		NSString			*newName = [[textView string] copy];
		
		[item renameTo:newName errorWindow:[self window]];
		
		[self setNeedsDisplayInRect:[self cellFrameAtRow:r column:c]];
	}
	else if(textMovement == NSIllegalTextMovement)
	{		
		[[self selectedCell] setEditable:NO];
		[textView removeFromSuperview];		
	}
	
	[[self window] makeFirstResponder:self];
}


#pragma mark Drag'n'Drop Stuff
- (void)mouseDragged:(NSEvent *)event
{
	NSInteger row, column; 

    NSPoint point = [self convertPoint:[mouseDownEvent locationInWindow] fromView:nil];
	NSPoint curPoint = [self convertPoint:[event locationInWindow] fromView:nil];
	
	// Discard dragging if distance too short
	if([self distanceFromPoint:point to:curPoint] < 4.0) return;
	
	// cancel editing action
	[NSObject cancelPreviousPerformRequestsWithTarget:self
											 selector:@selector(beginEditing)
											   object:nil];
											   
	[self getRow:&row column:&column forPoint:point];	
	NSCell *cell = [self cellAtRow:row column:column];							   

	// Cancel any late highlighting
	[NSObject cancelPreviousPerformRequestsWithTarget:self
											 selector:@selector(highlightOnlyCell:)
											   object:cell];
	
    if(![cell isKindOfClass:[PAResultsMultiItemPlaceholderCell class]]) 
        [self startDrag:mouseDownEvent]; 
}

- (CGFloat)distanceFromPoint:(NSPoint)sourcePoint to:(NSPoint)destPoint
{
	CGFloat dx = sourcePoint.x - destPoint.x;
	CGFloat dy = sourcePoint.y - destPoint.y;
	return sqrt(dx * dx + dy * dy);
}

- (NSUInteger)draggingSourceOperationMaskForLocal:(BOOL)isLocal
{
	if(isLocal)
	{
		return NSDragOperationNone;
	} else {
		BOOL managingFiles = [[NSUserDefaults standardUserDefaults] boolForKey:@"ManageFiles.ManagedFolder.Enabled"];
		
		if(managingFiles)
			return NSDragOperationCopy | NSDragOperationDelete;
		else
			return NSDragOperationMove | NSDragOperationDelete;
	}
}

- (void)startDrag:(NSEvent *)event
{
	// Create pasteboard contents
	NSMutableArray *fileList = [NSMutableArray array];
	
	NSUInteger idx = [selectedIndexes firstIndex];	
	while (idx != NSNotFound)
	{
		NNTaggableObject *item = [items objectAtIndex:idx];
		
		[fileList addObject:[item valueForAttribute:(id)kMDItemPath]];
		
		idx = [selectedIndexes indexGreaterThanIndex:idx];
	}
	
	NSPasteboard *pboard = [NSPasteboard pasteboardWithName:NSDragPboard]; 
	[pboard declareTypes:[NSArray arrayWithObject:NSFilenamesPboardType] owner:nil];
	[pboard setPropertyList:fileList forType:NSFilenamesPboardType];
	
	// Click point
	NSPoint dragPoint = [self convertPoint:[event locationInWindow] fromView:nil];
	
	// Determine drag image
	CGFloat offsetX, offsetY;
	NSImage *image = [self dragImageForMouseDownAtPoint:dragPoint offsetX:&offsetX y:&offsetY];
	
	// Drag point
	dragPoint.x -= offsetX;
	dragPoint.y += offsetY;

	// we want to make the image a little bit transparent so the user can see where
    // they're dragging to
    NSImage *dragImage = [[[NSImage alloc] initWithSize:[image size]] autorelease]; 
    [dragImage lockFocus]; 
    [image dissolveToPoint:NSMakePoint(0,0) fraction:0.5]; 
    [dragImage unlockFocus];

    [self dragImage:dragImage 
                 at:dragPoint 
             offset:NSZeroSize
              event:event 
         pasteboard:pboard 
             source:self 
          slideBack:YES]; 
}

- (NSImage *)dragImageForMouseDownAtPoint:(NSPoint)point offsetX:(CGFloat *)offsetX y:(CGFloat *)offsetY
{
	// First, determine the topmost and lowermost selected items in the visible rect to 
	// calc the size of the image
	NSRect selectedItemsRect = NSMakeRect(0,0,0,0);
	NSSize intercellSpacing = [self intercellSpacing];
	NSInteger topRow = -1, bottomRow = -1, leftColumn = -1, rightColumn = -1;
	
	NSMutableArray *visibleCells = [NSMutableArray array];
	
	NSEnumerator *e = [selectedCells objectEnumerator];
	NSTextFieldCell *cell;
	while(cell = [e nextObject])
	{
		NSInteger row, column;
		[self getRow:&row column:&column ofCell:cell];
		
		NSRect cellFrame = [self cellFrameAtRow:row column:column];
		
		if(NSIntersectsRect(cellFrame,[self visibleRect]))
		{
			// This cell is visible, so we need to create a drag image for it
			[visibleCells addObject:cell];
			
			if(topRow == -1 || row < topRow)
			{
				topRow = row;
				selectedItemsRect.origin.y = cellFrame.origin.y;
				selectedItemsRect.size.height = (bottomRow - topRow + 1) * (cellFrame.size.height + intercellSpacing.height);
			}
			
			if(bottomRow == -1 || row > bottomRow)
			{
				bottomRow = row;
				selectedItemsRect.size.height = (bottomRow - topRow + 1) * (cellFrame.size.height + intercellSpacing.height);
			}
			
			if(leftColumn == -1 || column < leftColumn)
			{
				leftColumn = column;
				selectedItemsRect.size.width += selectedItemsRect.origin.x - cellFrame.origin.x;
				selectedItemsRect.origin.x = cellFrame.origin.x;
			}
			
			if(rightColumn == -1 || column > rightColumn)
			{
				rightColumn = column;
				selectedItemsRect.size.width = cellFrame.origin.x + cellFrame.size.width - selectedItemsRect.origin.x;
			}
		}
	}

	// Draw the image
	NSImage *image = [[NSImage alloc] initWithSize:selectedItemsRect.size];
	[image setFlipped:YES];
	
	[image lockFocus];
	
	//[[NSColor redColor] set];
	//[[NSBezierPath bezierPathWithRect:NSMakeRect(0, 0, selectedItemsRect.size.width, selectedItemsRect.size.height)] fill];
		
	e = [visibleCells objectEnumerator];
	while(cell = [e nextObject])
	{
		NSInteger row, column;
		[self getRow:&row column:&column ofCell:cell];
		
		NSRect cellFrame = [self cellFrameAtRow:row column:column];
		cellFrame.origin.x -= selectedItemsRect.origin.x;
		cellFrame.origin.y -= selectedItemsRect.origin.y;
		
		// Determine offset
		NSInteger r, c;
		[self getRow:&r column:&c forPoint:point];
		NSTextFieldCell *clickedCell = [self cellAtRow:r column:c];
		
		if([clickedCell isEqualTo:cell])
		{
			//NSLog(@"%@ %@", [[cell item] valueForAttribute:(id)kMDItemDisplayName], [[clickedCell item] valueForAttribute:(id)kMDItemDisplayName]);
			//NSLog(@"point.y=%f, selItemsRect.origin.y=%f, cellFrame.origin.y=%f", point.y, selectedItemsRect.origin.y, cellFrame.origin.y);
		
			*offsetX = point.x - selectedItemsRect.origin.x;
			*offsetY = selectedItemsRect.size.height - (point.y - selectedItemsRect.origin.y);
		}		
	
		// We want to draw the unhighlighted state of the cell
		[cell setHighlighted:NO];
		[cell drawWithFrame:cellFrame inView:nil];
		[cell setHighlighted:YES];
	}
	
	[image unlockFocus];
	
	return image;
}

/**
needed for supporting dragging to trash
 */
- (void)draggedImage:(NSImage *)anImage endedAt:(NSPoint)aPoint operation:(NSDragOperation)operation
{
	if (operation == NSDragOperationDelete)
	{
		id controller = [[self superview] delegate];
		
		[controller setDraggedItems:[self selectedItems]];
		
		[controller deleteDraggedItems];
	}
}


#pragma mark Accessors
- (NSArray *)items
{
	return items;
}

- (void)setItems:(NSArray *)theItems
{
	if(items) [items release];
	items = [theItems retain];
}

- (NSCell *)selectedCell
{
	return selectedCell;
}

- (NSArray *)selectedCells
{
	return selectedCells;
}

- (NSArray *)selectedItems
{
	NSMutableArray *selectedItems = [NSMutableArray array];
		
	NSUInteger idx = [selectedIndexes firstIndex];
	while(idx != NSNotFound)
	{
		[selectedItems addObject:[items objectAtIndex:idx]];
		idx = [selectedIndexes indexGreaterThanIndex:idx];
	}
	
	return selectedItems;
}

- (void)setSelectedItems:(NSArray *)theSelectedItems
{
	[selectedIndexes removeAllIndexes];
	
	for (NNTaggableObject *item in theSelectedItems)
	{
		NSUInteger idx = [items indexOfObjectIdenticalTo:item];
		if (idx != NSNotFound)
			[selectedIndexes addIndex:idx];
	}
	
	[self displayCellsForItems];
	
	[self scrollToVisible];
}

- (void)setCellClass:(Class)aClass
{
	[super setCellClass:aClass];
	[self setCellSize:[[self cellClass] cellSize]];
	[self setIntercellSpacing:[[self cellClass] intercellSpacing]];
}

- (BOOL)isOpaque
{
	return NO;
}

@end
