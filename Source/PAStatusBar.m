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
	[self removeCursorRect:gripRect cursor:[NSCursor resizeLeftRightCursor]];
	
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
	[[NSGraphicsContext currentContext] setShouldAntialias:NO];
	
	[[NSColor colorWithCalibratedWhite:0.6 alpha:1.0] set];
	
	[NSBezierPath strokeLineFromPoint:NSMakePoint(0.0, 1.0)
							  toPoint:NSMakePoint(aRect.size.width, 1.0)];
	
	[[NSGraphicsContext currentContext] setShouldAntialias:YES];
	
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

	// Draw separator lines	
	[[NSGraphicsContext currentContext] setShouldAntialias:NO];
	
	NSEnumerator *enumerator = [[self subviews] objectEnumerator];
	NSView *view;
	
	while(view = [enumerator nextObject])
	{
		NSRect frame = [view frame];
		
		//[[NSColor colorWithDeviceCyan:0.24 magenta:0.19 yellow:0.19 black:0.0 alpha:1.0] set];	
		[[NSColor colorWithCalibratedWhite:0.6 alpha:1.0] set];
		
		[NSBezierPath strokeLineFromPoint:NSMakePoint(frame.origin.x + frame.size.width, 1.0)
								  toPoint:NSMakePoint(frame.origin.x + frame.size.width, 23.0)];
	}
	
	[[NSGraphicsContext currentContext] setShouldAntialias:YES];
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
	NSPoint clickLocation = [self convertPoint:[theEvent locationInWindow] fromView:nil];
	
	if(NSPointInRect(clickLocation, gripRect)) 
	{
		gripDragOffset = NSMakeSize([self frame].size.width - clickLocation.x, clickLocation.y);
		[[self window] disableCursorRects];
		[[NSCursor resizeLeftRightCursor] set];
		
		gripDragged = YES;	
	}
}

- (void)mouseUp:(NSEvent *)theEvent
{
	gripDragged = NO;
	
	NSView *view = [[resizableSplitView subviews] objectAtIndex:0];
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
	
	NSPoint clickLocation = [self convertPoint:[theEvent locationInWindow] fromView:nil];
	
	NSView *view = [[resizableSplitView subviews] objectAtIndex:0];
	
	NSRect newFrame = [view frame];
	newFrame.size.width = clickLocation.x + gripDragOffset.width;
		
	// Check if there are any constraints for this subview's width
	id svDelegate = [resizableSplitView delegate];
	
	if(svDelegate && [svDelegate respondsToSelector:@selector(splitView:constrainSplitPosition:ofSubviewAt:)] )
	{
		float newWidth = [svDelegate splitView:resizableSplitView
						constrainSplitPosition:newFrame.size.width 
								   ofSubviewAt:0];
		newFrame.size.width = newWidth;
	}
	
	if(svDelegate && [svDelegate respondsToSelector:@selector(splitView:constrainMaxCoordinate:ofSubviewAt:)] )
	{
		float maxWidth = [svDelegate splitView:resizableSplitView
						constrainMaxCoordinate:0.0 
								   ofSubviewAt:0];
		newFrame.size.width = MIN(maxWidth, newFrame.size.width);
	}
	
	if(svDelegate && [svDelegate respondsToSelector:@selector(splitView:constrainMinCoordinate:ofSubviewAt:)] )
	{
		float minWidth = [svDelegate splitView:resizableSplitView
						constrainMinCoordinate:0.0 
								   ofSubviewAt:0];
		newFrame.size.width = MAX(minWidth, newFrame.size.width);
	}
	
	[view setFrame:newFrame];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:NSSplitViewDidResizeSubviewsNotification 
														object:resizableSplitView];
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
	
	for(int i = 0; i < [[self subviews] count]; i++)
	{
		[[[self subviews] objectAtIndex:i] removeFromSuperview];
	}
	
	NSEnumerator *enumerator = [items objectEnumerator];
	NSView *view;
	float current_x = 0.0;
	
	while(view = [enumerator nextObject])
	{		
		[view setFrameOrigin:NSMakePoint(current_x, 1.0)];
		
		[self addSubview:view];
		
		current_x += [view frame].size.width + 1.0;
	}
}


#pragma mark Accessors
- (void)setAlternateState:(BOOL)flag
{
	NSEnumerator *enumerator = [items objectEnumerator];
	NSView *view;
	
	while(view = [enumerator nextObject])
	{
		if([view isKindOfClass:[PAStatusBarButton class]] &&
		   [(PAStatusBarButton *)view buttonType] == NSMomentaryPushInButton)
		{
			[view setAlternateState:flag];
			[view setNeedsDisplay:YES];
		}
	}
}

- (BOOL)isFlipped
{
	return YES;
}

@end
