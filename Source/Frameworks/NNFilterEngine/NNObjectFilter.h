//
//  NNObjectFilter.h
//  NNTagging
//
//  Created by Johannes Hoffart on 17.04.07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

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
