//
//  PATaggerHeaderCell.m
//  punakea
//
//  Created by Daniel on 27.10.06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "PATaggerHeaderCell.h"


@implementation PATaggerHeaderCell

#pragma mark Drawing
- (void)drawInteriorWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
	// Fill background with gradient color
	CTGradient *gradient = [CTGradient unifiedSelectedGradient];
	[gradient fillRect:cellFrame angle:270.0];
	
	// Stroke top and bottom border
	[[NSColor grayColor] set];
	
	NSBezierPath *path = [NSBezierPath bezierPath];
	[path moveToPoint:NSZeroPoint];
	[path lineToPoint:NSMakePoint(cellFrame.size.width, 0)];
	[path moveToPoint:NSMakePoint(0, cellFrame.size.height)];
	[path lineToPoint:NSMakePoint(cellFrame.size.width, cellFrame.size.height)];
	
	[path stroke];
	
	// Draw title
	NSMutableDictionary *fontAttributes = [NSMutableDictionary dictionaryWithCapacity:3];
	[fontAttributes setObject:[NSColor textColor] forKey:NSForegroundColorAttributeName];		
	[fontAttributes setObject:[NSFont systemFontOfSize:11] forKey:NSFontAttributeName];	
	
	NSMutableParagraphStyle *paraStyle = [[[NSParagraphStyle defaultParagraphStyle] mutableCopy] autorelease];
	[paraStyle setLineBreakMode:NSLineBreakByTruncatingMiddle];
	[paraStyle setAlignment:NSCenterTextAlignment];
	
	[fontAttributes setObject:paraStyle forKey:NSParagraphStyleAttributeName];	

	NSRect stringRect = cellFrame;
	stringRect.origin.y += 1.0;

	[[self stringValue] drawInRect:stringRect withAttributes:fontAttributes];
}

- (void)highlight:(BOOL)flag withFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
	[self drawInteriorWithFrame:cellFrame inView:controlView];
}

@end
