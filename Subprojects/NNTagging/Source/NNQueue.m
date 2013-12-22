// Copyright (c) 2006-2013 nudge:nudge (Johannes Hoffart & Daniel Bär). All rights reserved.
// 
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "NNQueue.h"

@implementation NNQueue

#pragma mark init
- (id)init 
{
	if (self = [super init]) {
		lock = [[NSConditionLock alloc] initWithCondition:NNQueueEmpty];
		elements = [[NSMutableArray alloc] init];
	}
	return self;
}

- (void)dealloc 
{
	[elements release];
	[lock release];
	[super dealloc];
}

+ (NNQueue*)queue
{
	NNQueue *queue = [[NNQueue alloc] init];
	return [queue autorelease];
}

#pragma mark function
- (void)enqueue:(id)object 
{
	if (!object)
		return;
	
	[lock lock];
	[elements addObject:object];
	[lock unlockWithCondition:NNQueueFilled];
}

- (void)enqueueObjects:(NSArray*)objects
{
	[lock lock];
	[elements addObjectsFromArray:objects];
	NSInteger count = [elements count];
	[lock unlockWithCondition:(count > 0)?NNQueueFilled:NNQueueEmpty];
}

- (id)dequeue 
{
	[lock lockWhenCondition:NNQueueFilled];
	id element = [[elements objectAtIndex:0] retain];
	[elements removeObjectAtIndex:0];
	NSInteger count = [elements count];
	[lock unlockWithCondition:(count > 0)?NNQueueFilled:NNQueueEmpty];
	return [element autorelease];
}

- (id)dequeueWithTimeout:(NSTimeInterval)timeout
{
	if ([lock lockWhenCondition:NNQueueFilled beforeDate:[NSDate dateWithTimeIntervalSinceNow:timeout]])
	{
		id element = [[elements objectAtIndex:0] retain];
		[elements removeObjectAtIndex:0];
		NSInteger count = [elements count];
		[lock unlockWithCondition:(count > 0)?NNQueueFilled:NNQueueEmpty];
		return [element autorelease];
	}
	else
	{
		return nil;
	}
}	

- (id)tryDequeue 
{
	if ([lock tryLockWhenCondition:NNQueueFilled]) 
	{
		id element = [[elements objectAtIndex:0] retain];  
		[elements removeObjectAtIndex:0];
		NSInteger count = [elements count];
		[lock unlockWithCondition:(count > 0)?NNQueueFilled:NNQueueEmpty];
		return [element autorelease];
	}
	else
	{
		return nil;
	}
}

- (void)clear
{
	[lock lock];
	[elements removeAllObjects];
	[lock unlockWithCondition:NNQueueEmpty];
}

#pragma mark accessors
- (NSUInteger)count
{
	return [elements count];
}

//- (NSString*)description
//{
//	return [NSString stringWithFormat:@"NNQueue: %@",elements];
//}

@end