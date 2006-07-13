//
//  PAResultsMultiItemMatrix.m
//  punakea
//
//  Created by Daniel on 17.04.06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "PAResultsMultiItemMatrix.h"


@implementation PAResultsMultiItemMatrix

#pragma mark Init + Dealloc
- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
		[self setCellClass:[PAResultsMultiItemThumbnailCell class]];
		[self renewRows:1 columns:0];
		[self setIntercellSpacing:NSMakeSize(15,0)];
		[self setMode:NSHighlightModeMatrix];
		[self setTarget:self];
		[self setCellSize:[[self cellClass] cellSize]];
    }
    return self;
}

- (void)dealloc
{
	if(item) [item release];
	[super dealloc];
}


#pragma mark Actions
- (void)displayCellsForItems
{
	[self removeRow:0];
	[self renewRows:1 columns:0];
	
	NSEnumerator *enumerator = [[item items] objectEnumerator];
	NSMetadataItem *anObject;
	
	int column = 0;
	while(anObject = [enumerator nextObject])
	{
		PAResultsMultiItemThumbnailCell *cell = [[[PAResultsMultiItemThumbnailCell alloc] initTextCell:[anObject valueForAttribute:@"kMDItemDisplayName"]] autorelease];
		
		if([self numberOfColumns] == 3)	[self addRow];
		if(column == 2) column = 0;
		
		// Add columns when adding cells in first row
		if([self numberOfRows] == 1)
		{
			[self addColumnWithCells:[NSArray arrayWithObject:cell]];
		} else {
			[self putCell:cell atRow:[self numberOfRows]-1 column:column];
			column++;
		}
	}
}


#pragma mark TEMP
- (void)mouseDown:(NSEvent *)theEvent
{		
	NSPoint location = [theEvent locationInWindow];
	location = [self convertPoint:location fromView:nil];
	
	// Ensure the corresponding "supercell" is highlighted
	NSOutlineView *outlineView = [self superview];
	int row = [outlineView rowAtPoint:location];	
	BOOL byExtendingSelection = ([theEvent modifierFlags] & NSShiftKeyMask) ||
								([theEvent modifierFlags] & NSCommandKeyMask);	
	[outlineView selectRow:row byExtendingSelection:byExtendingSelection];
		
	int column;
	[self getRow:&row column:&column forPoint:location];
	
	NSCell *cell = [self cellAtRow:row column:column];
	NSRect cellFrame = [self cellFrameAtRow:row column:column];
	
	// Ask cell to track the mouse and highlight
	[cell trackMouse:theEvent inRect:cellFrame ofView:self untilMouseUp:YES];	
	[self selectCellAtRow:row column:column];
	[cell setHighlighted:YES];
	[self setNeedsDisplayInRect:cellFrame];
		
	// Keep track of selection
	if([theEvent modifierFlags] & NSCommandKeyMask)
	{
		// Extend selection to this cell
		
		// TODO: Deselect if the cell was already highlighted	
		
		// TODO: Support SHIFT key, only COMMAND works atm
	} else {
		// Clear all selections
		NSEnumerator *enumerator = [[self cells] objectEnumerator];
		NSCell *aCell;
		
		while(aCell = [enumerator nextObject])
			if(cell != aCell)
				[aCell setHighlighted:NO];
	}
	
	NSEnumerator *enumerator = [[self selectedCells] objectEnumerator];
	while(cell = [enumerator nextObject])
	{
		NSLog([cell value]);
	}
}


#pragma mark Accessors
- (PAResultsMultiItem *)item
{
	return item;
}

- (void)setItem:(PAResultsMultiItem *)anItem
{
	item = [anItem retain];
	[self displayCellsForItems];
}

- (NSCell *)multiItemCell
{
	return multiItemCell;
}

- (void)setMultiItemCell:(NSCell *)aCell
{
	multiItemCell = aCell;
}

- (void)highlightCell:(BOOL)flag atRow:(int)row column:(int)column
{
	NSCell *cell = [self cellAtRow:row column:column];
	[cell setHighlighted:flag];
}

@end
