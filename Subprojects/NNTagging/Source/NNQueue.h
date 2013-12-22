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

#import <Cocoa/Cocoa.h>

typedef enum _NNQueueState {
	NNQueueEmpty = 0,
	NNQueueFilled = 1
} NNQueueState;

/**
\internal

Original from http://www.cocoadev.com/index.pl?ProducersAndConsumerModel
 with some modifications/additions.
 
 Threadsafe implementation of a FIFO-queue
 */
@interface NNQueue : NSObject {
	NSMutableArray* elements;
	NSConditionLock* lock; // 0 = no elements, 1 = elements
}

/**
 @return New fifo-queue
 */
+ (NNQueue*)queue;

/**
 @param object	New object to enqueue at head of queue
 */
- (void)enqueue:(id)object;

/**
 @param objects	Multiple objects to enqueue - first object of objects will be enqueue first
 */
- (void)enqueueObjects:(NSArray*)objects;

/**
 This call blocks until there is something to dequeue
 
 @return	Next object in queue
 */
- (id)dequeue;

/**
Blocks until a new object can be dequeued or the time ran out.
 
 @param timeout		Time to wait for a new object
 @return			Object if timeout was not reached, nil otherwise
 */
- (id)dequeueWithTimeout:(NSTimeInterval)timeout;

/**
 @return Next element in queue, or nil if there is none
 */
- (id)tryDequeue;

/**
Empties the queue.
 */
- (void)clear;

/**
 @return Number of elements in queue
 */
- (NSUInteger)count;

@end
