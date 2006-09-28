//
//  PAResultsMultiItemMatrix.m
//  punakea
//
//  Created by Daniel on 17.04.06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "PAResultsMultiItemMatrix.h"


static unsigned int PAModifierKeyMask = NSShiftKeyMask | NSAlternateKeyMask | NSCommandKeyMask | NSControlKeyMask;

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
	}
    return self;
}

- (void)dealloc
{
	if(selectedCells) [selectedCells release];
	if(selectedIndexes) [selectedIndexes release];
	if(items) [items release];
	[super dealloc];
}


#pragma mark Notifications
- (void)frameDidChange:(NSNotification *)note
{
	// TODO: Performance!! :)
	
	if([self numberOfRows] <= 0) return;
	
	NSRect frame = [self frame];
	NSSize cellSize = [self cellSize];
	NSSize intercellSpacing = [self intercellSpacing];
	
	int numberOfItemsPerRow = frame.size.width / (cellSize.width + intercellSpacing.width);
	
	// Break if numberOfItemsPerRow hasn't changed
	if([self numberOfColumns] == numberOfItemsPerRow) return;
	
	NSMutableArray *cellArray = [NSMutableArray arrayWithCapacity:100];
	
	for(int row = 0; row < [self numberOfRows]; row++)
	{
		for(int column = 0; column < [self numberOfColumns]; column++)
		{
			NSTextFieldCell *cell = [self cellAtRow:row column:column];
			[cellArray addObject:[cell retain]];
		}
	}
	
	for(int i = 0; i < [self numberOfRows]; i++)
	{
		[self removeRow:i];
	}
	[self renewRows:1 columns:0];
	
	NSTextFieldCell *aCell;
	NSEnumerator *enumerator = [cellArray objectEnumerator];
	int row = 0;
	int column = 0;
	while(aCell = [enumerator nextObject])
	{					
		if(column == numberOfItemsPerRow) 
		{
			[self addRow];
			
			// Fill the new row with placeholder cells
			for(int i = 0; i < column; i++)
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
	
	[self deselectAllCells];
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
	
	[[self superview] scrollRectToVisible:rect];
}
*/

- (void)displayCellsForItems
{
	for(int i = 0; i < [self numberOfRows]; i++)
	{
		[self removeRow:i];
	}
	[self renewRows:1 columns:0];
	
	NSRect frame = [self frame];
	NSSize cellSize = [self cellSize];
	NSSize intercellSpacing = [self intercellSpacing];
	
	int numberOfItemsPerRow = frame.size.width / (cellSize.width + intercellSpacing.width);
	
	NSEnumerator *enumerator = [items objectEnumerator];
	PAQueryItem *anObject;
	
	int row = 0;
	int column = 0;
	while(anObject = [enumerator nextObject])
	{
		NSTextFieldCell *cell =
			[[[[self cellClass] alloc]
				initTextCell:anObject] autorelease];				
		
		if(column == numberOfItemsPerRow) 
		{
			[self addRow];
			
			// Fill the new row with placeholder cells
			for(int i = 0; i < column; i++)
			{
				NSTextFieldCell *cell = [[[PAResultsMultiItemPlaceholderCell alloc]
										   initTextCell] autorelease];
				[self putCell:cell atRow:row+1 column:i];
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
}

- (void)doubleAction
{	
	unsigned index = [selectedIndexes firstIndex];
		
	while (index != NSNotFound)
	{
		PAQueryItem *item = [items objectAtIndex:index];
		NSString *path = [item valueForAttribute:(id)kMDItemPath];
		[[NSWorkspace sharedWorkspace] openFile:path];		
		
		index = [selectedIndexes indexGreaterThanIndex:index];
	}
}

- (void)highlightCell:(BOOL)flag cell:(NSCell *)cell
{
	int row, column;
	[self getRow:&row column:&column ofCell:cell];
	
	[self highlightCell:flag atRow:row column:column];
}

- (void)highlightCell:(BOOL)flag atRow:(int)row column:(int)column
{
	NSCell *cell = [self cellAtRow:row column:column];
	[cell setHighlighted:flag];
	
	unsigned int index = row * [self numberOfColumns] + column;
	
	if(flag)
	{
		selectedCell = cell;
		[selectedIndexes addIndex:index];
		[selectedCells addObject:cell];
		
		[self scrollCellToVisibleAtRow:row column:column];
		
	} else {
		[selectedIndexes removeIndex:index];
		[selectedCells removeObject:cell];
	}
}

- (void)highlightOnlyCell:(NSCell *)cell
{
	[self deselectAllCellsButCell:cell];

	int row, column;
	[self getRow:&row column:&column ofCell:cell];

	[cell setEditable:NO];
	[self highlightCell:YES atRow:row column:column];
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
			int r, c;
			[self getRow:&r column:&c ofCell:aCell];
			[self highlightCell:NO atRow:r column:c];
		}
	}
}

- (void)moveSelectionUp:(NSEvent *)theEvent
{
	[self moveSelectionUp:theEvent byExtendingSelection:NO];
}

- (void)moveSelectionUp:(NSEvent *)theEvent byExtendingSelection:(BOOL)flag
{	
	NSCell *cell;
	int row = [self numberOfRows] - 1;
	int column = [self numberOfColumns] - 1;
	int r, c;
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
				int curRow, curCol;
				[self getRow:&curRow column:&curCol ofCell:cell];
				[self highlightCell:YES atRow:curRow column:curCol];
			}
		}

		[self highlightCell:YES atRow:row-1 column:column];
	} else {
		// If this is the topmost multi item cell, do nothing as we are at the topmost item
		// in our OutlineView

		NSOutlineView *outlineView = (NSOutlineView *)[self superview];
		int rowInOutlineView = [outlineView rowForItem:items];	
	
		if(rowInOutlineView > 1)
		{
			// Pass keyDown event back to OutlineView
			[[self superview] setResponder:nil];
			[[self superview] keyDown:theEvent];
		}
	}
}

- (void)moveSelectionDown:(NSEvent *)theEvent
{
	[self moveSelectionDown:theEvent byExtendingSelection:NO];
}

- (void)moveSelectionDown:(NSEvent *)theEvent byExtendingSelection:(BOOL)flag
{	
	NSCell *cell;
	int row = 0;
	int column = 0;
	int r, c;
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
		if([[[self cellAtRow:row+1 column:column] class] isEqualTo:[PAResultsMultiItemPlaceholderCell class]])
		{
			column = 0;
		}
	
		selCellsEnumerator = [[self selectedCells] objectEnumerator];
		[self deselectAllCells];
		
		if(flag)
		{
			while(cell = [selCellsEnumerator nextObject])
			{
				int curRow, curCol;
				[self getRow:&curRow column:&curCol ofCell:cell];
				[self highlightCell:YES atRow:curRow column:curCol];
			}
		}
		
		[self highlightCell:YES atRow:row+1 column:column];
	} else {
		// If this is the lowermost multi item cell, do nothing as we are at the lowermost item
		// in our OutlineView

		NSOutlineView *outlineView = (NSOutlineView *)[self superview];
		int rowInOutlineView = [outlineView rowForItem:items];	
	
		if(rowInOutlineView < [outlineView numberOfRows] - 1)
		{
			// Pass keyDown event back to OutlineView
			[[self superview] setResponder:nil];
			[[self superview] keyDown:theEvent];
		}
	}
}

- (void)moveSelectionRight:(NSEvent *)theEvent
{
	[self moveSelectionRight:theEvent byExtendingSelection:NO];
}

- (void)moveSelectionRight:(NSEvent *)theEvent byExtendingSelection:(BOOL)flag
{	
	NSCell *cell;
	int row = 0;
	int column = 0;
	int r, c;
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
		// Wrap selection into next line
		column--;
		row++;
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
				int curRow, curCol;
				[self getRow:&curRow column:&curCol ofCell:cell];
				[self highlightCell:YES atRow:curRow column:curCol];
			}
		}		
		
		[self highlightCell:YES atRow:row column:column];
	} else {		
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
	}
}

- (void)moveSelectionLeft:(NSEvent *)theEvent
{
	[self moveSelectionLeft:theEvent byExtendingSelection:NO];
}

- (void)moveSelectionLeft:(NSEvent *)theEvent byExtendingSelection:(BOOL)flag
{	
	NSCell *cell;
	int row = [self numberOfRows] - 1;
	int column = [self numberOfColumns] - 1;
	int r, c;
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
		// Wrap selection into next line
		column++;
		row--;
	}
	
	if(row != -1) 
	{
		selCellsEnumerator = [[self selectedCells] objectEnumerator];
		[self deselectAllCells];
		
		if(flag)
		{
			while(cell = [selCellsEnumerator nextObject])
			{
				int curRow, curCol;
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


#pragma mark Events
- (void)keyDown:(NSEvent *)theEvent
{
	if([theEvent type] == NSKeyDown)
	{			
		unichar key = [[theEvent charactersIgnoringModifiers] characterAtIndex:0];
		
		BOOL shiftKey = ([theEvent modifierFlags] & NSShiftKeyMask) != 0;
		
		// Respond to Command + Arrow-Down	
		if(key == NSDownArrowFunctionKey &&
		   ([theEvent modifierFlags] & NSCommandKeyMask) != 0)
		{
			[[self target] performSelector:@selector(doubleAction)];
			return;
		}
		
		// Begin editing on Return or Enter
		if(key == NSEnterCharacter || key == '\r')
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
		
		// TODO: Too slow, but we need to invalidate our visibleRect if key was pressed for a while
		//[[self superview] setNeedsDisplayInRect:[[self superview] visibleRect]];
	}
}

- (void)mouseDown:(NSEvent *)theEvent
{
	NSOutlineView *outlineView = (NSOutlineView *)[self superview];

	// Make sure the corresponding multiitemcell in our outlineView is highlighted
	NSPoint locationInOutlineView = [outlineView convertPoint:[theEvent locationInWindow] fromView:nil];
	int row = [outlineView rowAtPoint:locationInOutlineView];	
	BOOL byExtendingSelection = ([theEvent modifierFlags] & NSShiftKeyMask) ||
								([theEvent modifierFlags] & NSCommandKeyMask);	
	[outlineView selectRow:row byExtendingSelection:byExtendingSelection];
	[[self window] makeFirstResponder:outlineView];
	
	
	// Now, perform click action	
	static float doubleClickThreshold = 0.0;    
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
		
	int column;
	[self getRow:&row column:&column forPoint:location];
	
	NSCell *cell = [self cellAtRow:row column:column];
	[cell setEditable:NO];
    
    if (modifierDown == NO && doubleClick == NO)
    {
		int count = [selectedIndexes count];
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
			
			unsigned cellIndex = row * [self numberOfColumns] + column;			
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
			int firstRow = 0, firstColumn = 0;		
			
			if([self selectedCell])	
				[self getRow:&firstRow column:&firstColumn ofCell:[self selectedCell]];	
			
			// Maybe swap first and last indexes if the first cell has a greater index that the
			// last one
			if(firstRow > row ||
			   (firstRow == row && firstColumn > column))
			{
				int rTemp = firstRow, cTemp = firstColumn;
				firstRow = row;
				firstColumn = column;
				row = rTemp;
				column = cTemp;
			}
			
			int c = firstColumn;
			for(int r = firstRow; r <= row; r++)
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


#pragma mark Editing
- (void)beginEditing
{
	int row, column;
	[self getRow:&row column:&column ofCell:[self selectedCell]];

	[self deselectAllCellsButCell:[self selectedCell]];
	[[self selectedCell] setEditable:YES];
	[self selectCellAtRow:row column:column];
}

- (void)cancelOperation:(id)sender
{		
	NSText *textView = [[self window] fieldEditor:NO forObject:self];
	//[textView setString:[[self itemAtRow:[self selectedRow]] valueForAttribute:(id)kMDItemDisplayName]];
	[textView setTextColor:[NSColor textColor]];

	NSMutableDictionary *newUserInfo;
	newUserInfo = [[NSMutableDictionary alloc] init];
	[newUserInfo setObject:[NSNumber numberWithInt:NSIllegalTextMovement] forKey:@"NSTextMovement"];

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
	[super textDidChange:notification];
	
	int r, c;
	[self getRow:&r column:&c ofCell:[self selectedCell]];
	
	// Set text color to red if the new destination already exists
	int index = r * [self numberOfColumns] + c;
	PAQueryItem *item = [items objectAtIndex:index];
	PAFile *file = [PAFile fileWithPath:[item valueForAttribute:(id)kMDItemPath]];
	
	NSText *textView = [notification object];
	
	NSString *newDestination = [[file directory] stringByAppendingPathComponent:[textView string]];
	
	if([[NSFileManager defaultManager] fileExistsAtPath:newDestination] &&
	   [newDestination compare:[file path] options:NSCaseInsensitiveSearch] != NSOrderedSame)
	{
		[textView setTextColor:[NSColor redColor]];
	} else {
		[textView setTextColor:[NSColor textColor]];
	}
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
	
	int r, c;
	[self getRow:&r column:&c ofCell:[self selectedCell]];

	int textMovement = [[[notification userInfo] valueForKey:@"NSTextMovement"] intValue];

	if(textMovement == NSReturnTextMovement)
	{
		NSMutableDictionary *newUserInfo;
		newUserInfo = [[NSMutableDictionary alloc] initWithDictionary:[notification userInfo]];
		[newUserInfo setObject:[NSNumber numberWithInt:NSIllegalTextMovement] forKey:@"NSTextMovement"];

		notification = [NSNotification notificationWithName:[notification name]
													 object:[notification object]
												   userInfo:newUserInfo];
		
		[[self selectedCell] setEditable:NO];
		[textView removeFromSuperview];		

		[newUserInfo release];

		[[self window] makeFirstResponder:self];
		
		// Forward renaming request to our delegate's query (delegate is equal to the outlineView's delegate)		
		int				index = r * [self numberOfColumns] + c;
		PAQueryItem		*item = [items objectAtIndex:index];
		NSString		*newName = [[textView string] copy];
		
		BOOL wasMoved = [[[self superview] query] renameItem:item to:newName errorWindow:[self window]];
		
		if(wasMoved) [self setNeedsDisplayInRect:[self cellFrameAtRow:r column:c]];
	}
	else if(textMovement == NSIllegalTextMovement)
	{		
		[[self selectedCell] setEditable:NO];
		[textView removeFromSuperview];		
		[[self window] makeFirstResponder:self];
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
	[self displayCellsForItems];
}

- (NSCell *)selectedCell
{
	return selectedCell;
}

- (NSArray *)selectedCells
{
	return selectedCells;
}

- (void)setCellClass:(Class)aClass
{
	[super setCellClass:aClass];
	[self setCellSize:[[self cellClass] cellSize]];
	[self setIntercellSpacing:[[self cellClass] intercellSpacing]];
}

@end
