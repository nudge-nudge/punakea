//
//  PAImageButtonCell.m
//  punakea
//
//  Created by Daniel on 21.03.06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "PAImageButtonCell.h"


@interface PAImageButtonCell (PrivateAPI)

- (NSString*)stringForState:(PAImageButtonState)aState;

@end


@implementation PAImageButtonCell

- (id)initImageCell:(NSImage *)anImage
{	
	self = [super initImageCell:anImage];
	
	images = [[NSMutableDictionary alloc] init];
	if (anImage)
	{
		[self setImage:anImage forState:PAOffState];
	}
	state = PAOffState;
	type = PAMomentaryLightButton;
	
	return self;
}

- (void)setImage:(NSImage *)anImage forState:(PAImageButtonState)aState
{
	[images setObject:anImage forKey:[self stringForState:aState]];
}

- (void)drawInteriorWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
	NSLog([self stringForState:state]);
	NSImage *image = [images objectForKey:[self stringForState:state]];
	
	NSRect imageRect;
	imageRect.origin = NSZeroPoint;
	imageRect.size = [image size];
	
	[image drawAtPoint:NSZeroPoint fromRect:imageRect operation:NSCompositeSourceOver fraction:1.0];
}

- (BOOL)trackMouse:(NSEvent *)theEvent inRect:(NSRect)cellFrame ofView:(NSView *)controlView untilMouseUp:(BOOL)untilMouseUp
{
	return [super trackMouse:theEvent inRect:cellFrame ofView:controlView untilMouseUp:YES];
}

- (BOOL)startTrackingAt:(NSPoint)startPoint inView:(NSView *)controlView
{
	PAImageButtonState newHighlightedState;
	PAImageButtonState newState;
	
	if(type == PAMomentaryLightButton)
	{
		newHighlightedState = PAOffHighlightedState;
		newState = PAOnState;
	}
	else
	{
		if(state == PAOnState)
		{
			newHighlightedState = PAOnHighlightedState;
			newState = PAOffState;
		}
		else
		{
			newHighlightedState = PAOffHighlightedState;
			newState = PAOnState;
		}
	}
	
	if([images objectForKey:[self stringForState:newHighlightedState]])
	{
		[self setState:newHighlightedState];
	}
	else
	{
		[self setState:newState];
	}
	return YES;
}

- (BOOL)continueTracking:(NSPoint)lastPoint at:(NSPoint)currentPoint inView:(NSView *)controlView
{
	return YES;
}

- (void)stopTracking:(NSPoint)lastPoint at:(NSPoint)stopPoint inView:(NSView *)controlView mouseIsUp:(BOOL)flag
{
	// all following states need to be the inverse ones?
	
	if(type == PAMomentaryLightButton)
	{
		[self setState:PAOnState];
	}
	else
	{
		PAImageButtonState newState;
		if(state == PAOffState || state == PAOnHighlightedState) { newState = PAOnState; }
		if(state == PAOnState || state == PAOffHighlightedState) { newState = PAOffState; }
		[self setState:newState];
	}
}

- (void)setButtonType:(PAImageButtonType)aType
{
	type = aType;
}

- (NSString*)stringForState:(PAImageButtonState)aState
{
	NSString *name;
	switch(aState)
	{
		case PAOnState:
			name = @"PAOnState"; break;
		case PAOffState:
			name = @"PAOffState"; break;
		case PAOnPressedState:
			name = @"PAOnPressedState"; break;
		case PAOffPressedState:
			name = @"PAOffPressedState"; break;
		case PAOnHighlightedState:
			name = @"PAOnHighlightedState"; break;
		case PAOffHighlightedState:
			name = @"PAOffHighlightedState"; break;
		case PAOnDisabledState:
			name = @"PAOnDisabledState"; break;
		case PAOffDisabledState:
			name = @"PAOffDisabledState"; break;
	}	
	
	return name;
}

- (PAImageButtonState)state
{
	return state;
}

- (void)setState:(PAImageButtonState)aState
{
	state = aState;
	//[[self controlView] setNeedsDisplay];
}

/*- (NSView*)controlView
{
	return controlView;
}

- (void)setControlView:(NSView*)view
{
	controlView = [view retain];
}*/

- (void)dealloc
{
	if(images) { [images release]; }
	[super dealloc];
}

@end
