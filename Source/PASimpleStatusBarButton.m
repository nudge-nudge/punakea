//
//  PASimpleStatusBarButton.m
//  punakea
//
//  Created by Daniel on 27.04.07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "PASimpleStatusBarButton.h"


@implementation PASimpleStatusBarButton

#pragma mark Init + Dealloc
- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
		PASimpleStatusBarButtonCell *cell = [[PASimpleStatusBarButtonCell alloc] initImageCell:nil];
		[self setCell:cell];
		[cell release];
		
		toolTipTag = [self addToolTipRect:[self bounds] owner:self userData:nil];
    }
    return self;
}

+ (PASimpleStatusBarButton *)statusBarButton
{
	return [[[PASimpleStatusBarButton alloc] initWithFrame:NSMakeRect(0, 0, MIN_SIZE.width, MIN_SIZE.height)] autorelease];
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

@end
