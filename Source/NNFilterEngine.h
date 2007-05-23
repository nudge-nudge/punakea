//
//  NNFilterEngine.h
//  NNTagging
//
//  Created by Johannes Hoffart on 17.04.07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "NNTagging/NNQueue.h"
#import "NNTagging/NNTag.h"

#import "NNObjectFilter.h"
#import "NNDistributedObjectProtocols.h"

#include <unistd.h>

// TODO should the server be the delegate? only a delegate?

@interface NNFilterEngine : NSObject {
	id <NNBVCServerProtocol> server;
	
	NSArray *filterObjects;
	NSMutableArray *filteredObjects; /**< use lockFilteredObjects before accessing them! */
	
	NSMutableArray *filters;
	NSMutableArray *buffers;
	
	NSConditionLock *threadLock;
	NSLock *filteredObjectsLock;
	
	unsigned int threadCount;
	NSLock *threadCountLock;
	
	int currentID;
}

- (void)startWithServer:(id <NNBVCServerProtocol>)aServer forID:(int)threadID;
- (void)setThreadShouldQuit;

- (void)setObjects:(NSArray*)objects;

- (NSMutableArray*)filters;
- (void)addFilter:(NNObjectFilter*)filter;
- (void)removeFilter:(NNObjectFilter*)filter;
- (void)removeAllFilters;

- (void)lockFilteredObjects;
- (void)unlockFilteredObjects;

@end