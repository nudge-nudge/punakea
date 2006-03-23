//
//  PAImageButton.m
//  punakea
//
//  Created by Daniel on 23.03.06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "PAImageButton.h"


@implementation PAImageButton

- (id)initWithFrame:(NSRect)frameRect
{
	PAImageButtonCell *cell = [[PAImageButtonCell alloc] initImageCell:[NSImage imageNamed:@"MDIconViewOff-1"]];
	[self setCell:cell];
	
	return [super initWithFrame:frameRect];
}

@end
