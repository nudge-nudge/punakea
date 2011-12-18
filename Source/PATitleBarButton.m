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

#import "PATitleBarButton.h"


@implementation PATitleBarButton

#pragma mark Init + Dealloc
- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
		PATitleBarButtonCell *cell = [[PATitleBarButtonCell alloc] initImageCell:nil];
		[self setCell:cell];
		[cell release];
		
		[self setAlignment:NSLeftTextAlignment];
		
		toolTipTag = [self addToolTipRect:[self bounds] owner:self userData:nil];
    }
    return self;
}

+ (PATitleBarButton *)titleBarButton
{
	return [[[[self class] alloc] initWithFrame:NSMakeRect(0, 0, 0, 0)] autorelease];
}

- (void)dealloc
{
	[self removeToolTip:toolTipTag];
	if(toolTip) [toolTip release];
	
	[super dealloc];
}


#pragma mark Events
- (void)mouseDown:(NSEvent *)event
{
	if(![self canDraw]) return;
	
	[super mouseDown:event];
}


#pragma mark Misc
- (NSString *)view:(NSView *)view
  stringForToolTip:(NSToolTipTag)tag
             point:(NSPoint)point
		  userData:(void *)userData
{
	return [self toolTip] ? [self toolTip] : nil;
}


#pragma mark Accessors
- (NSString *)identifier
{
	return identifier;
}

- (void)setIdentifier:(NSString *)anIdentifier
{
	[identifier release];
	identifier = [anIdentifier retain];
}

- (NSButtonType)buttonType
{
	return [[self cell] buttonType];
}

- (void)setButtonType:(NSButtonType)aType
{
	[[self cell] setButtonType:aType];
}

- (void)setImage:(NSImage *)anImage
{
	[[self cell] setImage:anImage];
	
	[self sizeToFit];
}

- (void)setAlternateImage:(NSImage *)anImage
{
	[[self cell] setAlternateImage:anImage];
}

- (NSString *)toolTip
{
	return toolTip;
}

- (void)setToolTip:(NSString *)aToolTip
{
	if(toolTip) [toolTip release];
	toolTip = [aToolTip retain];
}

- (BOOL)alternateState
{
	return [[self cell] alternateState];
}

- (void)setAlternateState:(BOOL)flag
{
	[[self cell] setAlternateState:flag];
}

- (NSTextAlignment)alignment
{
	return alignment;
}

- (void)setAlignment:(NSTextAlignment)mode
{
	alignment = mode;
}

@end
