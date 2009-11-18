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

- (NSUInteger)weight
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
		id object = [inQueue dequeueWithTimeout:0.1];
		
		if ([stateLock tryLockWhenCondition:NNThreadRunning])
		{
			[stateLock unlock];
			
			if (object)
				[self filterObject:object];
		}
		else
		{
			// put the object back from where it was taken
			if (object)
				[inQueue enqueue:object];
			
			// cancel filter
			break;
		}
	}
	
	[stateLock lock];
	[stateLock unlockWithCondition:NNThreadStopped];
	
	[pool release];
}

- (void)markAsCanceled
{	
	while(![stateLock lockBeforeDate:[NSDate dateWithTimeIntervalSinceNow:0.1]]);
	
	if ([stateLock condition] == NNThreadStopped)
	{
		[stateLock unlock];
	}
	else
	{
		[stateLock unlockWithCondition:NNThreadCanceled];
	}
}

- (void)waitForStop
{
	BOOL stopped = NO;
		
	while (!stopped)
	{
		if ([stateLock lockWhenCondition:NNThreadStopped
							  beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.1]])
		{
			stopped = YES;
		}
		else
		{
			// tell filter to stop
			[self markAsCanceled];
		}
	}
}

- (void)objectFiltered:(id)object
{
	//NSLog(@"%@ - : - %@",self,object);
	[outQueue enqueue:object];
}

- (void)filterObject:(id)object
{
	// nothing, implemented by subclass
	
	//NSLog(@"%@ looking at %@",self,object);
}

@end
