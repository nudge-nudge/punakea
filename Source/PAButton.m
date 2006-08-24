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
	trackingRect = [self bounds];
}

- (void)setFrame:(NSRect)frame
{
    [super setFrame:frame];
    [self removeTrackingRect:trackingRectTag];
    [self resetTrackingRect];
    trackingRectTag = [self addTrackingRect:trackingRect owner:self userData:NULL assumeInside:NO];
}

- (void)viewWillMoveToWindow:(NSWindow *)newWindow
{
    if ([self window] && trackingRectTag) {
        [self removeTrackingRect:trackingRectTag];
    }
}

- (void)viewDidMoveToWindow
{
	[self resetTrackingRect];
	trackingRectTag = [self addTrackingRect:trackingRect owner:self userData:NULL assumeInside:NO];
}

- (void)highlight:(BOOL)flag
{
	[[self cell] setHighlighted:flag];
}

- (void)sizeToFit
{
	NSRect frame = [self frame];
	frame.size = [[self cell] cellSize];
	
	[self setFrame:frame];
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

- (BOOL)isFlipped
{
	return YES;
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

- (NSColor *)bezelColor
{
	return [[self cell] bezelColor];
}

- (void)setBezelColor:(NSColor *)color
{
	[[self cell] setBezelColor:color];
}

- (NSColor *)selectedBezelColor
{
	return [[self cell] selectedBezelColor];
}

- (void)setSelectedBezelColor:(NSColor *)color
{
	[[self cell] setSelectedBezelColor:color];
}

- (PAButtonType)buttonType
{
	return [[self cell] buttonType];
}

- (void)setButtonType:(PAButtonType)buttonType
{
	[[self cell] setButtonType:buttonType];
}

- (int)fontSize
{
	return [[self cell] fontSize];
}

- (void)setFontSize:(int)size
{
	[[self cell] setFontSize:size];
}

- (BOOL)showsCloseIcon
{
	return [[self cell] showsCloseIcon];
}

- (void)setShowsCloseIcon:(BOOL)flag
{
	[[self cell] setShowsCloseIcon:flag];
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

- (SEL)closeAction
{
	return [[self cell] closeAction];
}

- (void)setCloseAction:(SEL)action
{
	[[self cell] setCloseAction:action];
}

- (id)target
{
	return [[self cell] target];
}

- (void)setTarget:(id)target
{
	[[self cell] setTarget:target];
}

@end
