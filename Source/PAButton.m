//
//  PAButton.m
//  punakea
//
//  Created by Daniel on 07.08.06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "PAButton.h"


@implementation PAButton

#pragma mark Init + Dealloc
- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
		PAButtonCell *cell = [[PAButtonCell alloc] initTextCell:@""];
		[self setCell:cell];
		[cell release];
		tag = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void)dealloc
{
	if(tag) [tag release];
	[super dealloc];
}


#pragma mark Actions
- (void)resetTrackingRect
{
	trackingRect = [self frame];
}

- (void)setFrame:(NSRect)frame
{
    [super setFrame:frame];
    [[self superview] removeTrackingRect:trackingRectTag];
    [self resetTrackingRect];
    trackingRectTag = [[self superview] addTrackingRect:trackingRect owner:self userData:NULL assumeInside:NO];
}

- (void)viewWillMoveToWindow:(NSWindow *)newWindow
{
    if ([self window] && trackingRectTag) {
        [[self superview] removeTrackingRect:trackingRectTag];
    }
}

- (void)viewDidMoveToWindow
{
	[self resetTrackingRect];
	trackingRectTag = [[self superview] addTrackingRect:trackingRect owner:self userData:NULL assumeInside:NO];
}

- (void)highlight:(BOOL)flag
{
	[[self cell] setHighlighted:flag];
}


#pragma mark Events
- (void)mouseEntered:(NSEvent *)theEvent
{
	[[self cell] setHovered:YES];
	[self setNeedsDisplay];
}

- (void)mouseExited:(NSEvent *)theEvent
{
	[[self cell] setHovered:NO];
	[self setNeedsDisplay];
}


#pragma mark Accessors
- (NSString *)title
{
	return [[self cell] title];
}

- (void)setTitle:(NSString *)title
{
	[[self cell] setTitle:title];
}

- (BOOL)isBordered
{
	return [[self cell] isBordered];
}

- (void)setBordered:(BOOL)flag
{
	[[self cell] setBordered:flag];
}

- (PAButtonState)state
{
	return [[self cell] state];
}

- (void)setState:(PAButtonState)aState
{
	[[self cell] setState:aState];
}

- (PABezelStyle)bezelStyle
{
	return [[self cell] bezelStyle];
}

- (void)setBezelStyle:(PABezelStyle)bezelStyle
{
	[[self cell] setBezelStyle:bezelStyle];
}

- (PAButtonType)buttonType
{
	return [[self cell] buttonType];
}

- (void)setButtonType:(PAButtonType)buttonType
{
	[[self cell] setButtonType:buttonType];
}

- (int)tag
{
	return [[self cell] tag];
}

- (void)setTag:(int)aTag
{
	[[self cell] setTag:aTag];
}

- (SEL)action
{
	return [[self cell] action];
}

- (void)setAction:(SEL)action
{
	[[self cell] setAction:action];
}

- (id)target
{
	return [[self cell] target];
}

- (void)setTarget:(id)target
{
	[[self cell] setTarget:target];
}

- (NSControlSize)controlSize
{
	return [[self cell] controlSize];
}

- (void)setControlSize:(NSControlSize)size
{
	[[self cell] setControlSize:size];
}

@end
