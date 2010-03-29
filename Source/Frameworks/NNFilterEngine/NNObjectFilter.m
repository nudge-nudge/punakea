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
	}
	return self;
}

- (void)dealloc
{
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
- (void)main
{
	// start filtering until thread gets canceled	
	while (![self isCancelled])
	{
		id object = [inQueue dequeueWithTimeout:0.1];
		[self filterObject:object];
	}
}

- (void)objectFiltered:(id)object
{
//	NSLog(@"%@ - : - %@",self,object);
	[outQueue enqueue:object];
}

- (void)filterObject:(id)object
{
	// nothing, implemented by subclass
	
	//NSLog(@"%@ looking at %@",self,object);
}

#pragma mark NSOperation stuff
- (BOOL)isConcurrent
{
	return YES;
}

//TODO
//- (BOOL)isExecuting
//{
//	return !finished;
//}
//
//- (BOOL)isFinished
//{
//	return finished;
//}

@end
