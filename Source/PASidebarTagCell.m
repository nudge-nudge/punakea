//
//  PASidebarTagCell.m
//  punakea
//
//  Created by Johannes Hoffart on 26.05.06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "PASidebarTagCell.h"


@implementation PASidebarTagCell

- (id)initTextCell:(NSString*)name
{
	if (self = [super initTextCell:name])
	{
		//nothing yet
	}
	return self;
}

- (void)drawInteriorWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
	NSColor *bezelColor = [NSColor colorWithDeviceRed:(222.0/255.0) green:(231.0/255.0) blue:(248.0/255.0) alpha:1.0];
	NSColor *selectedBezelColor = [NSColor alternateSelectedControlColor];

	NSColor *outerBezelColor = [bezelColor blendedColorWithFraction:0.4 ofColor:selectedBezelColor];

	NSBezierPath *bezel = [NSBezierPath bezierPathWithRoundRectInRect:cellFrame radius:20.0];
	[bezel setLineWidth:1.1];
	[outerBezelColor set];
	[bezel fill];
	
	// Draw inner bezel
	NSColor *innerBezelColor = bezelColor;

	bezel = [NSBezierPath bezierPathWithRoundRectInRect:NSInsetRect(cellFrame, 1.0, 1.0) radius:20.0];
	[innerBezelColor set];
	[bezel fill];
	
	[super drawInteriorWithFrame:cellFrame inView:controlView];
}

@end
