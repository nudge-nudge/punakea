//
//  PAImageButton.m
//  punakea
//
//  Created by Daniel on 23.03.06.
//  Copyright 2006 nudge:nudge. All rights reserved.
//

#import "PAImageButton.h"


@implementation PAImageButton

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
		PAImageButtonCell *cell = [[PAImageButtonCell alloc] initImageCell:nil];
		[self setCell:cell];
		[cell release];
		
		toolTipTag = [self addToolTipRect:[self bounds] owner:self userData:nil];
    }
    return self;
}

- (void)setImage:(NSImage *)anImage forState:(PAButtonState)aState
{
	[[self cell] setImage:anImage forState:aState];
}

- (void)setButtonType:(PAButtonType)aType
{
	[[self cell] setButtonType:aType];
}

- (BOOL)isHighlighted
{
	return [[self cell] isHighlighted];
}

- (void)dealloc
{
	[self removeToolTip:toolTipTag];
	if(toolTipTag) [toolTipTag release];
	[super dealloc];
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
- (PAButtonState)state
{
	return [[self cell] state];
}

- (void)setState:(PAButtonState)aState
{
	[[self cell] setState:aState];
}

- (NSMutableDictionary *)tag
{
	return [[self cell] tag];
}

- (void)setTag:(NSMutableDictionary *)aTag
{
	[[self cell] setTag:aTag];
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

@end
