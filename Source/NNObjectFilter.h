//
//  NNObjectFilter.h
//  NNTagging
//
//  Created by Johannes Hoffart on 17.04.07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "NNTagging/NNQueue.h"

typedef enum _NNThreadState {
	NNThreadStopped = 0,
	NNThreadRunning = 1,
	NNThreadCanceled = 2
} NNThreadState;

/** 
abstract class, do not instantiate!

do not mess with the NNQueues, they will be handled by the NNFilterEngine.
each filter comes with its own outQueue, and the inQueue will be connected to other filters' outQueues
*/
@interface NNObjectFilter : NSObject {
	/** higher weight causes the filter to be applied after filters with lower weight */
	unsigned int weight;
	
	NSConditionLock *stateLock;
	
	NNQueue *inQueue;
	NNQueue *outQueue;
}

- (void)waitForFilter; /**< this avoids deadlocks */
- (void)markAsCanceled;

- (void)setInQueue:(NNQueue*)queue;
- (NNQueue*)inQueue;
- (void)setOutQueue:(NNQueue*)queue;
- (NNQueue*)outQueue;
- (unsigned int)weight;

/**
call this in a new thread
 */
- (void)run;

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
