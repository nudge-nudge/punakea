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

#import <Cocoa/Cocoa.h>
#import "NNTagging/NNQueue.h"

/** 
abstract class, do not instantiate!

do not mess with the NNQueues, they will be handled by the NNFilterEngine.
each filter comes with its own outQueue, and the inQueue will be connected to other filters' outQueues
*/
@interface NNObjectFilter : NSObject {
	/** higher weight causes the filter to be applied after filters with lower weight */
	NSUInteger weight;
		
	NNQueue *inQueue;
	NNQueue *outQueue;
	
	BOOL	cancelled;
}

- (void)setInQueue:(NNQueue*)queue;
- (NNQueue*)inQueue;
- (void)setOutQueue:(NNQueue*)queue;
- (NNQueue*)outQueue;
- (NSUInteger)weight;

/**
 call this to start the filtering
 */
- (void)run;

/**
 call this to cancel the filter
 */
- (void)cancel;

/**
 @return YES if cancelled
 */
- (BOOL)isCancelled;

/**
call this if an object has passed the filter.
 object will be passed to the next filter
 
 @param object that passed the filter
 */
- (void)objectFiltered:(id)object;

/** 
abstract method, subclass this

if the object passes the filter, call
objectFiltered:object

@param object object to filter
*/
- (void)filterObject:(id)object;

@end
