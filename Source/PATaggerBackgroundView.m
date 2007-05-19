//
//  PATaggerBackgroundView.m
//  punakea
//
//  Created by Daniel on 26.10.06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "PATaggerBackgroundView.h"


@implementation PATaggerBackgroundView

#pragma mark Init + Dealloc
- (id)initWithFrame:(NSRect)frameRect
{
	self = [super initWithFrame:frameRect];
	if(self)
	{
		// nothing yet
	}	
	return self;
}

- (void)dealloc
{
	[super dealloc];
}


#pragma mark Drawing
- (void)drawRect:(NSRect)aRect
{	
	aRect = [self bounds];

	[[NSColor clearColor] set];
	NSBezierPath *path = [NSBezierPath bezierPathWithRect:aRect];
	[path fill];

	CTGradient *gradient = [CTGradient unifiedSelectedGradient];
	[gradient fillRect:aRect angle:90.0];
}

@end
