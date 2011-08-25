// Copyright (c) 2006-2011 nudge:nudge (Johannes Hoffart & Daniel Bär). All rights reserved.
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

#import "PATabPanel.h"


@implementation PATabPanel

#pragma mark Init + Dealloc
- (id)initWithFrame:(NSRect)frameRect
{
	self = [super initWithFrame:frameRect];
	if(self)
	{
		// nothing yet
	}	
	return self;
}

- (void)dealloc
{
	[self removeCursorRect:gripRect cursor:[NSCursor resizeUpDownCursor]];
	
	[super dealloc];
}

#pragma mark Drawing
- (void)drawRect:(NSRect)rect
{
	rect = [self bounds];
	
	// Draw background color
	[[NSColor whiteColor] set];
	NSRectFill(rect);
	
	// Draw header
	NSImage *image = [NSImage imageNamed:@"tabpanel-header"];
	[image setFlipped:YES];
	
	NSRect imageRect;
	imageRect.origin = NSZeroPoint;
	imageRect.size = [image size];
	
	NSRect destRect = rect;
	destRect.size.height = imageRect.size.height;
	
	[image drawInRect:destRect fromRect:imageRect operation:NSCompositeSourceOver fraction:1.0];
	
	// Draw bottom header line
	[[NSColor colorWithCalibratedWhite:0.6 alpha:1.0] set];
	
	[[NSGraphicsContext currentContext] setShouldAntialias:NO];
	[NSBezierPath strokeLineFromPoint:NSMakePoint(0, imageRect.size.height + 1.0)
							  toPoint:NSMakePoint(rect.size.width, imageRect.size.height + 1.0)];
	[[NSGraphicsContext currentContext] setShouldAntialias:YES];
	
	// Draw grip if applicable
	if(resizableSplitView)
	{
		image = [NSImage imageNamed:@"tabpanel-header-grip"];		
		[image setFlipped:YES];
		
		imageRect.size = [image size];		
		
		destRect = rect;
		destRect.origin.x = destRect.size.width - imageRect.size.width;
		destRect.origin.y = 0.0;
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
		[self addCursorRect:gripRect cursor:[NSCursor resizeUpDownCursor]];
	}
}

- (void)mouseDown:(NSEvent *)theEvent 
{
	NSPoint clickLocation = [self convertPoint:[theEvent locationInWindow] fromView:nil];
	
	if(NSPointInRect(clickLocation, gripRect)) 
	{
		gripDragOffset = NSMakeSize([self frame].size.width - clickLocation.x, clickLocation.y);
		[[self window] disableCursorRects];
		[[NSCursor resizeUpDownCursor] set];
		
		gripDragged = YES;	
	}
}

- (void)mouseUp:(NSEvent *)theEvent
{
	gripDragged = NO;
	
	NSView *view = [[resizableSplitView subviews] objectAtIndex:1];
	[view setNeedsDisplay:YES];
	
	[resizableSplitView setNeedsDisplay:YES];	
	
	[[self window] enableCursorRects];
	
	[self setNeedsDisplay:YES];
}

- (void)mouseDragged:(NSEvent *)theEvent 
{
	if(!gripDragged)
	{
		[super mouseDragged:theEvent];
		return;
	}
	
	[[NSNotificationCenter defaultCenter] postNotificationName:NSSplitViewWillResizeSubviewsNotification 
														object:resizableSplitView];
	
	NSPoint clickLocation = [theEvent locationInWindow];	
	
	NSView *view = [[resizableSplitView subviews] objectAtIndex:1];
	
	NSRect newFrame = [view frame];
	newFrame.size.height = clickLocation.y - gripDragOffset.height;
	
	//NSLog(@"frame height: %f, clickLocation: %f, gripDragOffset: %f", [view frame].size.height, clickLocation.y, gripDragOffset.height);
	
	// Check if there are any constraints for this subview's height
	id svDelegate = [resizableSplitView delegate];
	
	if(svDelegate && [svDelegate respondsToSelector:@selector(splitView:constrainSplitPosition:ofSubviewAt:)] )
	{
		CGFloat newHeight = [svDelegate splitView:resizableSplitView
						 constrainSplitPosition:newFrame.size.height 
									ofSubviewAt:1];
		newFrame.size.height = newHeight;
	}
	
	if(svDelegate && [svDelegate respondsToSelector:@selector(splitView:constrainMaxCoordinate:ofSubviewAt:)] )
	{
		CGFloat maxHeight = [svDelegate splitView:resizableSplitView
						 constrainMaxCoordinate:0.0
									ofSubviewAt:1];
		newFrame.size.height = MIN(maxHeight, newFrame.size.height);
	}
	
	if(svDelegate && [svDelegate respondsToSelector:@selector(splitView:constrainMinCoordinate:ofSubviewAt:)] )
	{
		CGFloat minHeight = [svDelegate splitView:resizableSplitView
						 constrainMinCoordinate:0.0 
									ofSubviewAt:1];
		newFrame.size.height = MAX(minHeight, newFrame.size.height);
	}
	
	// We need to resize subview at index 0, so we'll map our new height
	NSView *topView = [[resizableSplitView subviews] objectAtIndex:0];
	NSRect topViewFrame = [topView frame];
	topViewFrame.size.height = [resizableSplitView frame].size.height - newFrame.size.height - [resizableSplitView dividerThickness];
	[topView setFrame:topViewFrame];
	
	[resizableSplitView adjustSubviews];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:NSSplitViewDidResizeSubviewsNotification 
														object:resizableSplitView];
}

@end
