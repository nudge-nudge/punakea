//
//  PANotificationReceiver.m
//  punakea
//
//  Created by Johannes Hoffart on 02.01.07.
//  Copyright 2007 nudge:nudge. All rights reserved.
//

#import "PANotificationReceiver.h"


@implementation PANotificationReceiver
- (id)init
{
	if (self = [super init])
	{
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(note:)
													 name:nil
												   object:nil];
	}
	return self;
}

-(void)note:(NSNotification*)note
{
	if ([[note name] hasPrefix:@"PA"])
		NSLog(@"Notification: %@",[note name]);
}

@end
