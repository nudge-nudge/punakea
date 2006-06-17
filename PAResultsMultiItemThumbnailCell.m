//
//  PAResultsMultiItemThumbnailCell.m
//  punakea
//
//  Created by Daniel on 17.06.06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "PAResultsMultiItemThumbnailCell.h"


@implementation PAResultsMultiItemThumbnailCell

#pragma mark Init + Dealloc
- (id)initTextCell:(NSString *)aText
{
	self = [super initTextCell:aText];
	//if (self) {}	
	return self;
}

- (void)dealloc
{
	[super dealloc];
}


#pragma mark Drawing
- (void)drawInteriorWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{	
	if([self isHighlighted])
		[[NSColor greenColor] set];
	else
		[[NSColor grayColor] set];
	NSRectFill(cellFrame);
}

@end
