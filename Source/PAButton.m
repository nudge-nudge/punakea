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

#import "PAButton.h"


@implementation PAButton

#pragma mark Init + Dealloc
- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
		PAButtonCell *cell = [[PAButtonCell alloc] initTextCell:@""];
		[self setCell:cell];
		[cell release];
		
		[[NSNotificationCenter defaultCenter] addObserver:self 
											     selector:@selector(frameDidChange:)
												     name:NSViewFrameDidChangeNotification
												   object:self];
    }
    return self;
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	[super dealloc];
}


#pragma mark Actions
- (void)resetCursorRects
{
	if(trackingRect) [self removeTrackingRect:trackingRect];

	NSRect clippedBounds = NSIntersectionRect([self visibleRect], [self bounds]);
	
	if (!NSIsEmptyRect(clippedBounds))
	{
		NSPoint localPoint = [self convertPoint:[[self window] convertScreenToBase:[NSEvent mouseLocation]]
									   fromView:nil];
		BOOL mouseInside = NSPointInRect(localPoint, clippedBounds);
	
		trackingRect = [self addTrackingRect:clippedBounds owner:self userData:NULL assumeInside:mouseInside];
		
		if(mouseInside) { [self mouseEntered:nil]; } else { [self mouseExited:nil]; }
	}
}

- (void)setFrame:(NSRect)frame
{
    [super setFrame:frame];
    [self resetCursorRects];
}

- (void)viewWillMoveToWindow:(NSWindow *)newWindow
{
    if ([self window] && trackingRect) {
        [self removeTrackingRect:trackingRect];
    }
}

- (void)viewDidMoveToWindow
{
	[self resetCursorRects];
}

- (void)sizeToFit
{
	NSRect frame = [self frame];
	frame.size = [[self cell] cellSize];
	
	[self setFrame:frame];
}


#pragma mark Notifications
- (void)frameDidChange:(NSNotification *)notification
{
	[self resetCursorRects];
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

- (void)highlight:(BOOL)flag
{
	[[self cell] setHighlighted:flag];
}

- (BOOL)isHighlighted
{
	return [[self cell] isHighlighted];
}

- (void)select:(BOOL)flag
{
	[[self cell] select:flag];
}

- (BOOL)isSelected
{
	return [[self cell] isSelected];
}

- (void)setNegated:(BOOL)flag
{
	[[self cell] setNegated:flag];
}

- (BOOL)isNegated
{
	return [[self cell] isNegated];
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

- (NSColor *)negatedBezelColor
{
	return [[self cell] negatedBezelColor];
}

- (void)setNegatedBezelColor:(NSColor *)color
{
	[[self cell] setNegatedBezelColor:color];
}

- (PAButtonType)buttonType
{
	return [[self cell] buttonType];
}

- (void)setButtonType:(PAButtonType)buttonType
{
	[[self cell] setButtonType:buttonType];
}

- (NSInteger)fontSize
{
	return [[self cell] fontSize];
}

- (void)setFontSize:(NSInteger)size
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

- (BOOL)showsExcludeIcon
{
	return [[self cell] showsExcludeIcon];
}

- (void)setShowsExcludeIcon:(BOOL)flag
{
	[[self cell] setShowsExcludeIcon:flag];
}

- (void)toggleExclusion
{
	[[self cell] toggleExclusion];
}
	
- (NSInteger)tag
{
	return [[self cell] tag];
}

- (void)setTag:(NSInteger)aTag
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
