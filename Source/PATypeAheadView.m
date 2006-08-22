//
//  PATypeAheadView.m
//  punakea
//
//  Created by Johannes Hoffart on 22.08.06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "PATypeAheadView.h"


@implementation PATypeAheadView

- (void)drawRect:(NSRect)rect
{	
	[[NSColor colorWithDeviceRed:(189.0/255.0) green:(198.0/255.0) blue:(213.0/255.0) alpha:1.0] set];
	NSRectFill([self bounds]);
	[super drawRect:rect];
}

@end
