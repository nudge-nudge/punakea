//
//  PATagManagementViewTagView.m
//  punakea
//
//  Created by Johannes Hoffart on 29.09.06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "PATagManagementViewTagView.h"


@implementation PATagManagementViewTagView

- (void)drawRect:(NSRect)rect
{
	// Draw top border
	NSRect bounds = [self bounds];	
	
	NSBezierPath *path = [NSBezierPath bezierPath];
	[path moveToPoint:NSMakePoint(0, bounds.size.height)];
	[path lineToPoint:NSMakePoint(bounds.size.width, bounds.size.height)];
	[path closePath];
	[[NSColor grayColor] set];	
	[path stroke];
}

@end
