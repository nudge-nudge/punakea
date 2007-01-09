//
//  PAThreadSafeQueue.m
//  punakea
//
//  Created by Johannes Hoffart on 03.01.07.
//  Copyright 2007 nudge:nudge. All rights reserved.
//

#import "PAThreadSafeQueue.h"

@implementation PAThreadSafeQueue

-(id)init {
	if (self = [super init]) {
		elements = [[NSMutableArray alloc] init];
		lock = [[NSConditionLock alloc] initWithCondition:PAQueueEmpty];
	}
	return self;
}

-(void)dealloc {
	[elements release];
	[lock release];
	[super dealloc];
}

-(void)enqueue:(id)object {
	[lock lock];
	[elements addObject:object];
	[lock unlockWithCondition:PAQueueFilled];
}

-(id)dequeue {
	[lock lockWhenCondition:PAQueueFilled];
	id element = [[[elements objectAtIndex:0] retain] autorelease];
	[elements removeObjectAtIndex:0];
	int count = [elements count];
	[lock unlockWithCondition:(count > 0)?PAQueueFilled:PAQueueEmpty];
	return element;
}

-(id)tryDequeue {
	id element = nil;
	if ([lock tryLock]) {
		if ([lock condition] == PAQueueFilled) {
			element = [[[elements objectAtIndex:0] retain] autorelease];
			[elements removeObjectAtIndex:0];
		}
		int count = [elements count];
		[lock unlockWithCondition:(count > 0)?PAQueueFilled:PAQueueEmpty];
	}
	return element;
}

@end