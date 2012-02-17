//
//  PATitleBarButtonCell.m
//  punakea
//
//  Created by Daniel Bär on 04.12.11.
//  Copyright 2012 nudge:nudge. All rights reserved.
//

#import "PATitleBarButtonCell.h"

@interface PATitleBarButtonCell (PrivateAPI)
- (NSImage *)tintedImage:(NSImage *)img cellFrame:(NSRect)cellFrame;
@end


@implementation PATitleBarButtonCell

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
		NSLog(@"Warning - PATitleBarButtonCell: Use initImageCell instead of initTextCell!");
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
		img = [[[self alternateImage] copy] autorelease];
	} else {
		img = [[[self image] copy] autorelease];
	}
	
	NSRect imageRect;
	imageRect.origin = NSZeroPoint;
	imageRect.size = [img size];
	
	NSRect destRect;
	destRect.origin.x = cellFrame.origin.x;
	destRect.origin.y = cellFrame.origin.y + (cellFrame.size.height - imageRect.size.height) / 2;
	destRect.size = imageRect.size;
	
	img = [self tintedImage:img cellFrame:cellFrame];
	[img drawInRect:destRect fromRect:imageRect operation:NSCompositeSourceOver fraction:1.0];
	
	/*if(![self isHighlighted])
	{
		[[NSColor colorWithCalibratedWhite:0.1 alpha:0.3] set];
		[NSBezierPath fillRect:destRect];
	}*/
	
	// DEBUG
	// [[NSColor yellowColor] set];
	// [NSBezierPath fillRect:destRect];
}

- (NSImage *)tintedImage:(NSImage *)img cellFrame:(NSRect)cellFrame
{
	NSRect imageRect;
	imageRect.origin = NSZeroPoint;
	imageRect.size = [img size];	
	
	/*NSShadow * shadow = [NSShadow new];
	[shadow setShadowColor: [NSColor colorWithDeviceWhite: 1.0f alpha: 1.0f]];
	[shadow setShadowBlurRadius: 0.0f];
	[shadow setShadowOffset: NSMakeSize(0, -1)];
	[shadow set];*/
	
	// Tint image
	[img lockFocus];
	if (![self isHighlighted])		
		[[NSColor colorWithCalibratedWhite:1.0 alpha:0.475] set];
	else
		[[NSColor colorWithCalibratedWhite:1.0 alpha:0.3] set];
	NSRectFillUsingOperation(imageRect, NSCompositeSourceAtop);

	[img unlockFocus];
	
	return img;
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
		newSize.width = imageSize.width;
		newSize.height = 22;
		
		return newSize;
	}
	else
	{
		return NSZeroSize;
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
