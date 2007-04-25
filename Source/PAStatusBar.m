//
//  PAStatusBar.m
//  punakea
//
//  Created by Daniel on 25.04.07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "PAStatusBar.h"


@implementation PAStatusBar

#pragma mark Init + Dealloc
- (id)initWithFrame:(NSRect)frameRect
{
	self = [super initWithFrame:frameRect];
	if(self)
	{
		buttons = [[NSMutableArray alloc] init];
	}	
	return self;
}

- (void)dealloc
{
	[buttons release];
	[super dealloc];
}


#pragma mark Drawing
- (void)drawRect:(NSRect)aRect
{
	NSImage *image = [NSImage imageNamed:@"statusbar.tiff"];
	[image setScalesWhenResized:YES];
	
	NSRect imageRect;
	imageRect.origin = NSZeroPoint;
	imageRect.size = [image size];
	
	//NSRect rect = aRect;
	//rect.size.height = 23;
	
	[image drawInRect:aRect fromRect:imageRect operation:NSCompositeSourceOver fraction:1.0];
}

@end
