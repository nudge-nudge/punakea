//
//  NNObjectFilter.m
//  NNTagging
//
//  Created by Johannes Hoffart on 17.04.07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "NNObjectFilter.h"

@implementation NNObjectFilter

#pragma mark init
- (id)init
{
	if (self = [super init])
	{
		weight = 0;
		stateLock = [[NSConditionLock alloc] initWithCondition:NNThreadStopped];
	}
	return self;
}

- (void)dealloc
{
	[stateLock release];
	[inQueue release];
	[outQueue release];
	[super dealloc];
}

#pragma mark accessors
- (void)markAsCanceled
{
	[stateLock lock];
	
	if ([stateLock condition] == NNThreadStopped)
		[stateLock unlock];
	else
		[stateLock unlockWithCondition:NNThreadCanceled];
}

- (void)setInQueue:(NNQueue*)queue
{
	[queue retain];
	[inQueue release];
	inQueue = queue;
}

- (NNQueue*)inQueue
{
	return inQueue;
}

- (void)setOutQueue:(NNQueue*)queue
{
	[queue retain];
	[outQueue release];
	outQueue = queue;
}

- (NNQueue*)outQueue
{
	return outQueue;
}

- (unsigned int)weight
{ 
	return weight;
}

#pragma mark function
- (void)run
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
		
	[stateLock lockWhenCondition:NNThreadStopped];
	[stateLock unlockWithCondition:NNThreadRunning];
	
	// start filtering until thread gets canceled	
	while ([stateLock condition] == NNThreadRunning)
	{
		id object = [inQueue dequeueWithTimeout:0.5];
		
		if ([stateLock condition] == NNThreadCanceled)
		{
			break;
		}
		else if (object)
		{
			[self filterObject:object];
		}
	}
	
	[stateLock lock];
	[stateLock unlockWithCondition:NNThreadStopped];
	
	[pool release];
}

- (void)stopFilter
{
	[self markAsCanceled];
	
	// wait until the thread has stopped
	[stateLock lockWhenCondition:NNThreadStopped];
	[stateLock unlock];
	
	return;
}

- (void)objectFiltered:(id)object
{
	[outQueue enqueue:object];
}

- (void)filterObject:(id)object
{
	// nothing, implemented by subclass
}

@end
