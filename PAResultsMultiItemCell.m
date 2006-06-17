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
	//if (self) {}	
	return self;
}

- (void)dealloc
{
	if(item) [item release];
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
		[controlView addSubview:matrix];
	}
	else
	{
		[matrix setFrame:rect];
	}
	
	// Ensure at least one item of matrix is selected if cell is highlighted
	/*if([self isHighlighted])
	{
		if([[matrix selectedCells] count] == 0) 
		{
			[matrix selectCellAtRow:0 column:0];
			[matrix setNeedsDisplay];
		}
	}*/
}

- (void)highlight:(BOOL)flag withFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
	NSLog(@"hightlighting");
	[self drawInteriorWithFrame:cellFrame inView:controlView];
}


#pragma mark Accessors
- (PAResultsMultiItem *)item
{
	return item;
}

- (void)setItem:(PAResultsMultiItem *)anItem
{
	item = [anItem retain];
}

@end
