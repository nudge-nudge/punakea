//
//  PAStatusBar.m
//  punakea
//
//  Created by Daniel on 25.04.07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "PAStatusBar.h"


@implementation PAStatusBar

#pragma mark Init + Dealloc
- (id)initWithFrame:(NSRect)frameRect
{
	self = [super initWithFrame:frameRect];
	if(self)
	{
		items = [[NSMutableArray alloc] init];
	}	
	return self;
}

- (void)dealloc
{
	[items release];
	[super dealloc];
}


#pragma mark Drawing
- (void)drawRect:(NSRect)aRect
{
	aRect = [self bounds];
	
	[[NSColor whiteColor] set];
	NSRectFill(aRect);
	
	// Draw background
	NSImage *image = [NSImage imageNamed:@"statusbar"];
	[image setFlipped:YES];
	[image setScalesWhenResized:YES];
	
	NSRect imageRect;
	imageRect.origin = NSZeroPoint;
	imageRect.size = [image size];
	
	NSRect destRect = aRect;
	destRect.origin.y = 1;
	destRect.size.height -= 1;
	
	[image drawInRect:aRect fromRect:imageRect operation:NSCompositeSourceOver fraction:1.0];
	
	// Draw top line
	NSBezierPath *path = [NSBezierPath bezierPath];
	[path moveToPoint:NSZeroPoint];
	[path lineToPoint:NSMakePoint(aRect.size.width, 0.0)];
	
	//[[NSColor colorWithDeviceRed:(202.0/255.0) green:(202.0/255.0) blue:(202.0/255.0) alpha:1.0] set];
	[[NSColor grayColor] set];
	[path stroke];
	
	// Draw grip if applicable
	if(resizableSplitView)
	{
		image = [NSImage imageNamed:@"statusbar-grip"];		
		[image setFlipped:YES];

		imageRect.size = [image size];		
		
		destRect = aRect;
		destRect.origin.x = destRect.size.width - imageRect.size.width;
		destRect.origin.y = 1;
		destRect.size = imageRect.size;
		
		// Save grip rect for later use and add some left padding
		gripRect = destRect;
		gripRect.origin.x -= 3.0;
		gripRect.size.width += 3.0;
		
		[image drawInRect:destRect fromRect:imageRect operation:NSCompositeSourceOver fraction:1.0];
	}
}


#pragma mark Grip
- (void)resetCursorRects
{
	[super resetCursorRects];
	
	if(resizableSplitView) 
	{		
		[self addCursorRect:gripRect cursor:[NSCursor resizeLeftRightCursor]];
	}
}

- (void)mouseDown:(NSEvent *)theEvent 
{
	NSPoint clickLocation = [theEvent locationInWindow];
	
	if(NSPointInRect(clickLocation, gripRect)) 
	{
		gripDragOffset = NSMakeSize([self frame].size.width - clickLocation.x, clickLocation.y);
		gripDragged = YES;	
	}
}

- (void)mouseUp:(NSEvent *)theEvent
{
	gripDragged = NO;
	
	NSView *view = [[resizableSplitView subviews] objectAtIndex:0];
	[view setNeedsDisplay:YES];
}

- (void)mouseDragged:(NSEvent *)theEvent 
{
	if(!gripDragged)
	{
		[super mouseDragged:theEvent];
		return;
	}
	
	[[NSCursor resizeLeftRightCursor] set];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:NSSplitViewWillResizeSubviewsNotification object:self];
	
	NSPoint clickLocation = [theEvent locationInWindow];	
	
	// TODO use constraints from splitView:constrainSplitPosition:ofSubviewAt:
	
	NSView *view = [[resizableSplitView subviews] objectAtIndex:0];
	
	NSRect newFrame = [view frame];
	newFrame.size.width = clickLocation.x + gripDragOffset.width;
	
	[view setFrame:newFrame];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:NSSplitViewDidResizeSubviewsNotification object:self];
}


#pragma mark Misc
- (void)addItem:(NSView *)anItem
{
	[items addObject:anItem];
	[self updateItems];
}

- (void)updateItems
{
	// TODO, temp
	NSView *view = [items objectAtIndex:0];
	[view setFrame:NSMakeRect(0,0,30,22)];
	[self addSubview:view];
}

- (BOOL)isFlipped
{
	return YES;
}


#pragma mark TEMP
/*- (void)mouseDown:(NSEvent *)theEvent
{
	NSView *view = [[resizableSplitView subviews] objectAtIndex:0];
	
	NSRect frame = [view frame];
	frame.size.width = 100.0;
	
	[view setFrame:frame];
	
	[resizableSplitView setNeedsDisplay:YES];
}*/


@end
