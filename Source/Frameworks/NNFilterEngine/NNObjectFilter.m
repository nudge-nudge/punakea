// Copyright (c) 2006-2012 nudge:nudge (Johannes Hoffart & Daniel BŠr). All rights reserved.
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

#import "NNObjectFilter.h"

@implementation NNObjectFilter

#pragma mark init
- (id)init
{
	if (self = [super init])
	{
		weight = 0;
		cancelled = NO;
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
- (void)run
{
	[NSApplication detachDrawingThread:@selector(doFiltering)
							  toTarget:self
							withObject:nil];
}

- (void)cancel
{
	cancelled = YES;
}

- (BOOL)isCancelled
{	
	return cancelled;
}

- (void)doFiltering
{
	
	// start filtering until thread gets canceled
	// NNFilterEngine takes care of cancelling	
	while (![self isCancelled])
	{				
		id object = [inQueue dequeueWithTimeout:0.1];
		
		if (object != nil)
		{
			[self filterObject:object];
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