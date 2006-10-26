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
	[super dealloc];
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
@end
