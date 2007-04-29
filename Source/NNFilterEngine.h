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

@interface NNFilterEngine : NSObject {
	NSMutableArray *filterObjects;
	NSMutableArray *filteredObjects;
	
	NSMutableArray *filters;
	NSMutableArray *buffers;
	
	NSConditionLock *threadLock;
	NSLock *filteredObjectsLock;
	
	NSArray *ports;
	NSConnection *serverConnection;
}

- (id)initWithPorts:(NSArray*)newPorts;

- (void)setThreadShouldQuit;

- (void)setObjects:(NSMutableArray*)objects;
- (void)addFilter:(NNObjectFilter*)filter;
- (void)removeFilter:(NNObjectFilter*)filter;
- (void)removeAllFilters;

- (void)lockFilteredObjects;
- (void)unlockFilteredObjects;

@end