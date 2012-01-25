// Copyright (c) 2006-2012 nudge:nudge (Johannes Hoffart & Daniel Bär). All rights reserved.
// 
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "PAStatusBarButtonCell.h"


NSSize const STATUSBAR_BUTTON_PADDING = {10,5};
NSSize const STATUSBAR_BUTTON_MIN_SIZE = {30, 22};


@implementation PAStatusBarButtonCell

#pragma mark Init + Dealloc
- (id)initImageCell:(NSImage *)anImage
{	
	self = [super initImageCell:anImage];
	if(self)
	{
		[self setButtonType:NSMomentaryPushInButton];
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
		NSLog(@"Warning - PAStatusBarButtonCell: Use initImageCell instead of initTextCell!");
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
	destRect.origin.x = cellFrame.origin.x + STATUSBAR_BUTTON_PADDING.width;
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
	
	// Toggle state if this is a toggle button
	if(buttonType == NSToggleButton)
	{
		alternateState = alternateState ? NO : YES;
	}
	
	[[self controlView] setNeedsDisplay:YES];
}


#pragma mark Accessors
- (NSButtonType)buttonType
{
	return buttonType;
}

- (void)setButtonType:(NSButtonType)aType
{
	buttonType = aType;
}

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
		newSize.width = MAX(imageSize.width + 2 * STATUSBAR_BUTTON_PADDING.width, STATUSBAR_BUTTON_MIN_SIZE.width);
		newSize.height = 22;
		
		return newSize;
	}
	else
	{
		return STATUSBAR_BUTTON_MIN_SIZE;
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
