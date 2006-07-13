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
	if(multiItem) [multiItem release];
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
			PAResultsMultiItem *thisItem = [(PAResultsMultiItemMatrix *)anObject multiItem];
			if([multiItem isEqualTo:thisItem])
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
		[matrix setCellClass:[multiItem cellClass]];
		[matrix setMultiItem:multiItem];	
		[controlView addSubview:matrix];
	}
	else
	{
		[matrix setFrame:rect];
	}
	
	if(![self isHighlighted])
	{
		[matrix deselectAllCells];
	} else {
		// TODO: Ensure at least one item is selected
		/*if(![matrix selectedCell])
		{
			[matrix selectCellAtRow:0 column:0];
			[matrix highlightCell:YES atRow:0 column:0];
		}*/
	}
}

- (void)highlight:(BOOL)flag withFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
	[self drawInteriorWithFrame:cellFrame inView:controlView];
}


#pragma mark Accessors
- (id)objectValue
{
	return multiItem;
}

- (void)setObjectValue:(id <NSCopying>)object
{
	multiItem = (PAResultsMultiItem *)object;
}

@end
