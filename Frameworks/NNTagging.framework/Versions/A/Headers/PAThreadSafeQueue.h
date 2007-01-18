//
//  PAThreadSafeQueue.h
//  punakea
//
//  Created by Johannes Hoffart on 03.01.07.
//  Copyright 2007 nudge:nudge. All rights reserved.
//

#import <Cocoa/Cocoa.h>

typedef enum _PAQueueState {
	PAQueueEmpty = 0,
	PAQueueFilled = 1
} PAQueueState;

/**
copied from http://www.cocoadev.com/index.pl?ProducersAndConsumerModel
 */
@interface PAThreadSafeQueue : NSObject {
	NSMutableArray* elements;
	NSConditionLock* lock; // 0 = no elements, 1 = elements
}

-(void)enqueue:(id)object;
-(id)dequeue; // Blocks until there is an object to return
-(id)tryDequeue; // Returns NULL if the queue is empty

@end
