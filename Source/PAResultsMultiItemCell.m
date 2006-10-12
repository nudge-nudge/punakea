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
	if(items) [items release];
	[super dealloc];
}


#pragma mark Drawing
- (void)drawInteriorWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{	
	NSEnumerator *enumerator = [[controlView subviews] objectEnumerator];
	id anObject;
	
	while(anObject = [enumerator nextObject])
	{
		if([[anObject class] isEqualTo:[PAResultsMultiItemMatrix class]])
		{
			NSArray *theseItems = [(PAResultsMultiItemMatrix *)anObject items];
			if([items isEqualTo:theseItems])
				matrix = anObject;
		}
	}
	
	// Ensure matrix isn't hidden
	[matrix setHidden:NO];
	
	float offsetToRightBorder = 20;
	NSRect rect = NSMakeRect(cellFrame.origin.x + 15,
							 cellFrame.origin.y,
							 cellFrame.size.width - offsetToRightBorder,
							 cellFrame.size.height);
							 
	if([matrix superview] != controlView)
	{	
		matrix = [[PAResultsMultiItemMatrix alloc] initWithFrame:rect];
		
		Class cellClass = [PAResultsMultiItemThumbnailCell class];
		[matrix setCellClass:cellClass];
		[matrix setDelegate:[controlView delegate]];
		
		[matrix setItems:items];	
		[matrix setSelectedQueryItems:[controlView selectedQueryItems]];
		[controlView addSubview:matrix];
	}
	else
	{
		[matrix setFrame:rect];
	}
	
	if(![self isHighlighted])
	{
		// Buggy...
		//[matrix deselectAllCells];
		//[matrix deselectSelectedCell];
	} else {
		
		// Also buggy...
		/*if(![matrix selectedCell])
		{
			// Select one item on highlighting
			if([controlView lastUpDownArrowFunctionKey] == NSDownArrowFunctionKey ||
			   [controlView lastUpDownArrowFunctionKey] == NSUpArrowFunctionKey)
			{
				int row = 0;
				int column = 0;

				if([controlView lastUpDownArrowFunctionKey] == NSUpArrowFunctionKey)
					row = [matrix numberOfRows] - 1;
			
				// Select upper left item
				[matrix selectCellAtRow:row column:column];
				[matrix highlightCell:YES atRow:row column:column];
			}
		}
		[controlView setLastUpDownArrowFunctionKey:0];
		
		// Make matrix the first responder
		[controlView setResponder:matrix];*/
	}
	[controlView setResponder:matrix];
}

- (void)highlight:(BOOL)flag withFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
	[self drawInteriorWithFrame:cellFrame inView:controlView];
}


#pragma mark Accessors
- (id)objectValue
{
	return items;
}

- (void)setObjectValue:(id <NSCopying>)object
{
	if(items) [items release];
	items = [object retain];
}

@end
