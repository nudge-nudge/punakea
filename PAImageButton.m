//
//  PAImageButton.m
//  punakea
//
//  Created by Daniel on 23.03.06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "PAImageButton.h"


@implementation PAImageButton

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
		cell = [[PAImageButtonCell alloc] initImageCell:nil];
		[self setCell:cell];
    }
    return self;
}

- (void)setImage:(NSImage *)anImage forState:(PAImageButtonState)aState
{
	[cell setImage:anImage forState:aState];
}

- (void)dealloc
{
	if(cell) { [cell release]; }
	[super dealloc];
}

@end
