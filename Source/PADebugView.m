//
//  PADebugView.m
//  punakea
//
//  Created by Johannes Hoffart on 21.11.06.
//  Copyright 2006 nudge:nudge. All rights reserved.
//

#import "PADebugView.h"


@implementation PADebugView

- (void)dealloc
{
	NSLog(@"mainview dealloced");
	[super dealloc];
}

- (id)retain
{
	NSLog(@"%@ retained to %lu",[self className],[self retainCount]+1);
	return [super retain];
}

- (oneway void)release
{
	NSLog(@"%@ release to %lu",[self className],[self retainCount]-1);
	[super release];
}

@end
