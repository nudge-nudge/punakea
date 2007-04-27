//
//  PASimpleStatusBarButtonCell.m
//  punakea
//
//  Created by Daniel on 27.04.07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "PASimpleStatusBarButtonCell.h"


@implementation PASimpleStatusBarButtonCell

#pragma mark Init + Dealloc
- (id)initImageCell:(NSImage *)anImage
{	
	self = [super initImageCell:anImage];
	if(self)
	{
		[self setAction:@selector(action:)];
		
		// For mouse move events
		//[self setBordered:NO];
		//[self setShowsBorderOnlyWhileMouseInside:YES];
	}	
	return self;
}

- (id)initTextCell:(NSString *)aText
{	
	self = [self initImageCell:nil];
	if(self)
	{
		NSLog(@"Warning - PASimpleStatusBarButtonCell: Use initImageCell instead of initTextCell!");
	}
	return self;
}

- (void)dealloc
{
	[super dealloc];
}


#pragma mark Drawing
- (void)drawInteriorWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
	[[NSColor clearColor] set];
	NSBezierPath *path = [NSBezierPath bezierPathWithRect:cellFrame];
	[path fill];
	
	/*NSImage *image = [images objectForKey:[self stringForState:thisState]];
	
	NSRect imageRect;
	imageRect.origin = NSZeroPoint;
	imageRect.size = [image size];
	
	if([image scalesWhenResized])
		[image drawInRect:cellFrame fromRect:imageRect operation:NSCompositeSourceOver fraction:1.0];
	else
		[image drawAtPoint:cellFrame.origin
				  fromRect:imageRect
				 operation:NSCompositeSourceOver
				  fraction:1.0];
	*/
	
	NSString *str = @"aaa";
	
	if([self isHighlighted]) str = @"bbb";
	
	[str drawAtPoint:NSZeroPoint withAttributes:nil];
}

- (void)highlight:(BOOL)flag withFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
	[self drawInteriorWithFrame:cellFrame inView:controlView];
}


#pragma mark Mouse Tracking
- (void)mouseEntered:(NSEvent *)event
{
	[[self controlView] setNeedsDisplay:YES];
}

- (void)mouseExited:(NSEvent *)event
{
	[[self controlView] setNeedsDisplay:YES];	
}

- (BOOL)trackMouse:(NSEvent *)theEvent inRect:(NSRect)cellFrame ofView:(NSView *)controlView untilMouseUp:(BOOL)untilMouseUp
{
	return [super trackMouse:theEvent inRect:cellFrame ofView:controlView untilMouseUp:YES];
}

- (BOOL)startTrackingAt:(NSPoint)startPoint inView:(NSView *)controlView
{	
	[self setHighlighted:YES];
	[[self controlView] setNeedsDisplay:YES];	
	return YES;
}

- (BOOL)continueTracking:(NSPoint)lastPoint at:(NSPoint)currentPoint inView:(NSView *)controlView
{
	return YES;
}

- (void)stopTracking:(NSPoint)lastPoint at:(NSPoint)stopPoint inView:(NSView *)controlView mouseIsUp:(BOOL)flag
{
	[self setHighlighted:NO];
	[[self controlView] setNeedsDisplay:YES];
}


#pragma mark Accessors
- (NSImage *)image
{
	return image;
}

- (void)setImage:(NSImage *)anImage
{
	[image release];
	image = [anImage retain];
}

- (NSImage *)alternateImage
{
	return alternateImage;
}

- (void)setAlternateImage:(NSImage *)anImage
{
	[alternateImage release];
	alternateImage = [anImage retain];
}

@end
