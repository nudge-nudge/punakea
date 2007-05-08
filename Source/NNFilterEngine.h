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
	id <NNBVCServerProtocol> server;
	
	NSArray *filterObjects;
	
	/** use lockFilteredObjects before accessing them! */
	NSMutableArray *filteredObjects;
	
	NSMutableArray *filters;
	NSMutableArray *buffers;
	
	NSConditionLock *threadLock;
	NSLock *filteredObjectsLock;
}

- (void)startWithServer:(id <NNBVCServerProtocol>)aServer;
- (void)setThreadShouldQuit;

- (void)setObjects:(NSArray*)objects;

- (void)addFilter:(NNObjectFilter*)filter;
- (void)removeFilter:(NNObjectFilter*)filter;
- (void)removeAllFilters;

- (void)lockFilteredObjects;
- (void)unlockFilteredObjects;

@end