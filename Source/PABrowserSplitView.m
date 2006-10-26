//
//  PABrowserSplitView.m
//  punakea
//
//  Created by Johannes Hoffart on 17.10.06.
//  Copyright 2006 nudge:nudge. All rights reserved.
//

#import "PABrowserSplitView.h"


@implementation PABrowserSplitView

#pragma mark Init + Dealloc
- (id)initWithFrame:(NSRect)frameRect
{
	if(self = [super initWithFrame:frameRect])
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
- (float)dividerThickness
{
	return 0.5;
}

- (void)drawDividerInRect:(NSRect)aRect
{
	[[NSColor grayColor] set];
	NSRectFill(aRect);
}

@end
