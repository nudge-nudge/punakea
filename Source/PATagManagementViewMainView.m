//
//  PATagManagementViewMainView.m
//  punakea
//
//  Created by Johannes Hoffart on 29.09.06.
//  Copyright 2006 nudge:nudge. All rights reserved.
//

#import "PATagManagementViewMainView.h"


@implementation PATagManagementViewMainView

- (void)drawRect:(NSRect)rect
{
	[[NSColor whiteColor] set];
	NSRectFill([self bounds]);
}

- (id)retain
{
	NSLog(@"%@ retained to %i",[self className],[self retainCount]+1);
	return [super retain];
}

- (oneway void)release
{
	NSLog(@"%@ release to %i",[self className],[self retainCount]-1);
	[super release];
}

- (void)dealloc
{
	NSLog(@"tm-mainview dealloc");
	[super dealloc];
}

@end
