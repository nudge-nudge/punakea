//
//  PASimpleStatusBarButtonCell.m
//  punakea
//
//  Created by Daniel on 27.04.07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "PAStatusBarButtonCell.h"


NSSize const PADDING = {10,5};
NSSize const MIN_SIZE = {30, 22};


@implementation PAStatusBarButtonCell

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
	NSImage *img;
	if(alternateState && [self alternateImage])
	{
		img = [self alternateImage];
	} else {
		img = [self image];
	}
	
	NSRect imageRect;
	imageRect.origin = NSZeroPoint;
	imageRect.size = [img size];
	
	NSRect destRect;
	destRect.origin.x = cellFrame.origin.x + PADDING.width;
	destRect.origin.y = cellFrame.origin.y + (cellFrame.size.height - imageRect.size.height) / 2;
	destRect.size = imageRect.size;
	
	[img drawInRect:destRect fromRect:imageRect operation:NSCompositeSourceOver fraction:1.0];

	if([self isHighlighted])
	{
		[[NSColor colorWithCalibratedWhite:0.1 alpha:0.3] set];
		[NSBezierPath fillRect:cellFrame];
	}
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

- (NSSize)cellSize
{
	if([self image])
	{
		NSSize imageSize = [[self image] size];
		
		NSSize newSize;
		newSize.width = MAX(imageSize.width + 2 * PADDING.width, MIN_SIZE.width);
		newSize.height = 22;
		
		return newSize;
	}
	else
	{
		return MIN_SIZE;
	}
}

- (BOOL)alternateState
{
	return alternateState;
}

- (void)setAlternateState:(BOOL)flag
{
	alternateState = flag;
}

@end
