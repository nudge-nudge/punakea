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
	if (self)
	{
		value = aText;
	}	
	return self;
}

- (void)dealloc
{
	if(value) [value release];
	[super dealloc];
}


#pragma mark Drawing
- (void)drawInteriorWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{	
	if([self isHighlighted])
		[[NSColor blueColor] set];
	else
		[[NSColor grayColor] set];
	NSRectFill(cellFrame);	
	
	[[NSColor blueColor] set];
	[value drawAtPoint:cellFrame.origin withAttributes:nil];
}

- (void)highlight:(BOOL)flag withFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
	// Not invoked for matrix mode NSTrackModeMatrix

	NSLog(@"thumbnail highlight");
	//[self drawInteriorWithFrame:cellFrame inView:controlView];
	[[NSColor greenColor] set];
	NSRectFill(cellFrame);	
	[[self controlView] setNeedsDisplay:YES];
}


#pragma mark Mouse Tracking
/*- (BOOL)trackMouse:(NSEvent *)theEvent inRect:(NSRect)cellFrame ofView:(NSView *)controlView untilMouseUp:(BOOL)untilMouseUp
{
	return [super trackMouse:theEvent inRect:cellFrame ofView:controlView untilMouseUp:YES];
}

- (BOOL)startTrackingAt:(NSPoint)startPoint inView:(NSView *)controlView
{	
	return YES;
}

- (BOOL)continueTracking:(NSPoint)lastPoint at:(NSPoint)currentPoint inView:(NSView *)controlView
{
	return YES;
}

- (void)stopTracking:(NSPoint)lastPoint at:(NSPoint)stopPoint inView:(NSView *)controlView mouseIsUp:(BOOL)flag
{
	
}*/


#pragma mark Accessors
- (NSString *)value
{
	return value;
}


#pragma mark Class methods
+ (NSSize)cellSize
{
	return NSMakeSize(80, 80);
}

@end
