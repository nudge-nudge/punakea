//
//  PAResultsMultiItemCell.m
//  punakea
//
//  Created by Daniel on 15.04.06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "PAResultsMultiItemCell.h"


@implementation PAResultsMultiItemCell

#pragma mark Init + Dealloc
- (id)initTextCell:(NSString *)aText
{
	self = [super initTextCell:aText];
	if (self)
	{
		// nothing
	}	
	return self;
}

- (void)dealloc
{
	if(cellDict) [cellDict release];
	if(multiItem) [multiItem release];
	[super dealloc];
}

- (void)initSubcells
{
	unsigned i;
	for(i = 0; i < [multiItem numberOfItems]; i++)
	{
		NSCell *cell = [[[multiItem cellClass] alloc] initTextCell:[[multiItem objectAtIndex:i] valueForAttribute:(id)kMDItemDisplayName]];
		[cellDict setValue:cell forKey:[[multiItem objectAtIndex:i] valueForAttribute:(id)kMDItemPath]];
	}
}


#pragma mark Drawing
/* - (void)drawInteriorWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{	
	NSEnumerator *enumerator = [[controlView subviews] objectEnumerator];
	id anObject;
	
	while(anObject = [enumerator nextObject])
	{
		if([[anObject class] isEqualTo:[PAResultsMultiItemMatrix class]])
		{
			PAResultsMultiItem *thisItem = [(PAResultsMultiItemMatrix *)anObject item];
			if([item isEqualTo:thisItem])
				matrix = anObject;
		}
	}
	
	NSRect rect = NSMakeRect(cellFrame.origin.x + 15,
							 cellFrame.origin.y,
							 cellFrame.size.width - 30,
							 cellFrame.size.height);

	if([matrix superview] != controlView)
	{	
		matrix = [[PAResultsMultiItemMatrix alloc] initWithFrame:rect];
		[matrix setItem:item];	
		[matrix deselectAllCells];	
		[controlView addSubview:matrix];
	}
	else
	{
		[matrix setFrame:rect];
	}
	
	// Ensure at least one item of matrix is selected if cell is highlighted
	if([self isHighlighted])
	{
		//NSLog(@"r %d", [matrix selectedColumn]);

		if([matrix selectedColumn] == -1)
		{
			[matrix selectCellAtRow:0 column:0];
			[matrix setNeedsDisplay];
			//NSLog(@"ja");
		}
		//NSLog(@"highlighted");
	} else {
		//NSLog(@"not high");
		[matrix deselectAllCells];
		//[matrix setNeedsDisplay];
	}
} */

- (void)drawInteriorWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
	// Init subcells if they necessary
	if(!cellDict) 
	{
		cellDict = [[NSMutableDictionary alloc] init];
		[self initSubcells];
		NSLog(@"init");
	}
	
	unsigned i;
	for(i = 0; i < [multiItem numberOfItems]; i++)
	{
		NSCell *subCell = [cellDict valueForKey:[(NSMetadataItem *)[multiItem objectAtIndex:i] valueForAttribute:(id)kMDItemPath]];
		
		NSRect subCellFrame = cellFrame;
		subCellFrame.origin.x += i*90;
		subCellFrame.size.width = 100;
		[subCell drawWithFrame:subCellFrame inView:controlView];	
	}
}

- (void)highlight:(BOOL)flag withFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
	NSLog(@"hightlighting");
	[self drawInteriorWithFrame:cellFrame inView:controlView];
}


#pragma mark Mouse Tracking
- (BOOL)trackMouse:(NSEvent *)theEvent inRect:(NSRect)cellFrame  
            ofView:(NSView *)controlView untilMouseUp:(BOOL)flag
{
	BOOL result = NO;

	NSPoint locationInCell = [theEvent locationInWindow];
	locationInCell = [controlView convertPoint:locationInCell fromView:nil];
	
	unsigned i;
	for(i = 0; i < [multiItem numberOfItems]; i++)
	{
		NSCell *subCell = [cellDict valueForKey:[(NSMetadataItem *)[multiItem objectAtIndex:i] valueForAttribute:(id)kMDItemPath]];
		
		NSRect subCellFrame = cellFrame;
		subCellFrame.origin.x += i*90;
		subCellFrame.size.width = 100;	
		
		if(NSPointInRect(locationInCell, subCellFrame))
		{
			NSLog([(NSMetadataItem *)[multiItem objectAtIndex:i] valueForAttribute:(id)kMDItemDisplayName]);
			
			[subCell highlight:YES withFrame:cellFrame inView:controlView];
			return [subCell trackMouse:theEvent inRect:subCellFrame ofView:controlView
							untilMouseUp:flag];
		}
	}
	return [super trackMouse:theEvent inRect:cellFrame ofView:controlView untilMouseUp:flag];
}


#pragma mark Accessors
/*- (PAResultsMultiItem *)item
{
	return item;
}

- (void)setItem:(PAResultsMultiItem *)anItem
{
	item = [anItem retain];
}*/
- (id)objectValue
{
	return multiItem;
}

- (void)setObjectValue:(id <NSCopying>)object
{
	multiItem = (PAResultsMultiItem *)object;
}

/*+ (NSSize)cellSize
{
	if([item numberOfItems] == 0) return NSMakeSize(0,0);
}*/

@end
