//
//  PAInfoPaneSubview.m
//  punakea
//
//  Created by Daniel on 10.05.07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "PAInfoPaneSubview.h"


unsigned const LINE_HEIGHT = 16;


@implementation PAInfoPaneSubview

- (id)initWithFrame:(NSRect)frame 
{
    self = [super initWithFrame:frame];
    if(self)
	{
        // Initialization code here.
    }
    return self;
}


#pragma mark Drawing
- (void)drawRect:(NSRect)rect
{
	[[NSColor whiteColor] set];
	NSRectFill(rect);
}

@end
