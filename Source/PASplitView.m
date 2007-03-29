//
//  PASplitView.m
//  punakea
//
//  Created by Daniel on 29.03.07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "PASplitView.h"


@implementation PASplitView

- (float)dividerThickness
{
	return 1.0;
}

- (void)drawDividerInRect:(NSRect)aRect
{
	// override to do nothing
	[[NSColor grayColor] set];
	NSRectFill(aRect);
}

@end
