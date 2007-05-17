//
//  NNFilterEngine.m
//  NNTagging
//
//  Created by Johannes Hoffart on 17.04.07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "NNFilterEngine.h"

@interface NNFilterEngine (PrivateAPI)

- (NSMutableArray*)currentlyFilteredObjects;

- (void)runCheck;
- (void)startFilterEngine;
- (void)stopFilterEngine;

- (NSConnection*)serverConnection;
- (void)setServerConnection:(NSConnection*)newConnection;
- (void)setPorts:(NSArray*)portArray;
- (NSArray*)ports;

- (void)stopThread;

- (void)setFilterObjects:(NSMutableArray*)objects;
- (NSMutableArray*)filterObjects;
- (void)setFilteredObjects:(NSMutableArray*)objects;
- (NSMutableArray*)filteredObjects;

- (BOOL)checkIfDone;

@end

@implementation NNFilterEngine

#pragma mark init
- (id)init
{
	if (self = [super init])
	{
		filters = [[NSMutableArray alloc] init];
		buffers = [[NSMutableArray alloc] init];
		
		// create input queue
		[buffers addObject:[NNQueue queue]];
		
		// create lock, only one check-thread may be running
		threadLock = [[NSConditionLock alloc] initWithCondition:NNThreadStopped];
		
		filteredObjects = [[NSMutableArray alloc] init];
		filteredObjectsLock = [[NSLock alloc] init];
		
		threadCount = 0;
		threadCountLock = [[NSLock alloc] init];
	}
	return self;
}

- (void)dealloc
{
	[filterObjects release];
	
	[threadCountLock release];
	[filteredObjectsLock release];
	[filteredObjects release];
	[threadLock release];
	[buffers release];
	[filters release];
	[super dealloc];
}

#pragma mark threading stuff
- (void)runCheckWithPorts:(NSArray*)portArray
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

	// setup DO messaging stuff
	NSConnection *serverConnection = [NSConnection connectionWithReceivePort:[portArray objectAtIndex:0] 
																	sendPort:[portArray objectAtIndex:1]];
				
	[[NSRunLoop currentRunLoop] run];
	
	// do some book keeping	
	[threadCountLock lock];
	if (threadCount == 0)
	{
		[(id)[serverConnection rootProxy] filteringStarted];
	}
	
	threadCount++;
	[threadCountLock unlock];
	
	// wait for possible previous thread to stop
	[threadLock lockWhenCondition:NNThreadStopped];
	
	//  start thread
	[threadLock unlockWithCondition:NNThreadRunning];
	
	while ([threadLock condition] == NNThreadRunning)
	{		
		usleep(50000);

		if (![threadLock tryLockWhenCondition:NNThreadRunning])
			break;
				
		NSMutableArray *currentlyFilteredObjects = [self currentlyFilteredObjects];
		
		if ([currentlyFilteredObjects count] > 0)
		{
			[self lockFilteredObjects];
			[filteredObjects addObjectsFromArray:currentlyFilteredObjects];
			[self unlockFilteredObjects];
			
			// tell client-thread that new objects have been filtered
			[(id)[serverConnection rootProxy] objectsFiltered];
		}
		
		[threadLock unlock];
		
		if ([self checkIfDone])
			break;
	}
	
	[threadCountLock lock];
	threadCount--;
	if (threadCount == 0)
	{
		[(id)[serverConnection rootProxy] filteringFinished];
	}
	[threadCountLock unlock];
	
	[threadLock lock];
	[threadLock unlockWithCondition:NNThreadStopped];
	
	[pool release];
}

#pragma mark accessors
- (void)setFilterObjects:(NSMutableArray*)objects
{	
	[objects retain];
	[filterObjects release];
	filterObjects = objects;
}

- (NSMutableArray*)filterObjects
{
	return filterObjects;
}

- (void)setFilteredObjects:(NSMutableArray*)objects
{
	[objects retain];
	[filteredObjects release];
	filteredObjects = objects;
}

- (NSMutableArray*)filteredObjects
{
	return filteredObjects;
}

#pragma mark function
- (void)lockFilteredObjects
{
	[filteredObjectsLock lock];
}

- (void)unlockFilteredObjects
{
	[filteredObjectsLock unlock];
}

// will be called from outside
- (void)startWithServer:(id <NNBVCServerProtocol>)aServer
{	
	// hold server reference
	// needed if filters change without new filterObjects being set
	server = aServer;
	
	// setup DO messaging
	NSPort *port1;
	NSPort *port2;
	NSArray *portArray;
	
	port1 = [NSPort port];
	port2 = [NSPort port];
	
	NSConnection *serverConnection = [[NSConnection alloc] initWithReceivePort:port1
																	  sendPort:port2];
	
	[serverConnection setRootObject:server];
	
	portArray = [NSArray arrayWithObjects:port2,port1,nil];
	
	// start the engine
	[self startFilterEngineWithPorts:portArray];
}

- (void)setObjects:(NSArray*)objects
{
	[self stopFilterEngine];
	[self setFilterObjects:objects];
}

- (void)startFilterEngineWithPorts:(NSArray*)portArray
{
	// buffer in position 0 is the main input buffer
	NNQueue *inBuffer = [buffers objectAtIndex:0];
	[inBuffer enqueueObjects:[self filterObjects]];
	
	NSLog(@"filterEngine started with filterObjects: %@\ninBuffer: %@\nfilters: %@",[self filterObjects],inBuffer,filters);
	
	NNObjectFilter *filter;
	NSEnumerator *e = [filters objectEnumerator];
	
	// start filter threads
	while (filter = [e nextObject])
	{
		[NSThread detachNewThreadSelector:@selector(run)
								 toTarget:filter
							   withObject:nil];
	}
	
	// start check thread
	[NSThread detachNewThreadSelector:@selector(runCheckWithPorts:)
							 toTarget:self
						   withObject:portArray];
}

- (void)stopFilterEngine
{
	// stop check thread
	[self setThreadShouldQuit];
	
	// cancel filter threads
	NNObjectFilter *filter;
	NSEnumerator *filterEnumerator = [filters objectEnumerator];
	
	while (filter = [filterEnumerator nextObject])
		[filter markAsCanceled];
		
	// empty all buffers
	NSEnumerator *bufferEnumerator = [buffers objectEnumerator];
	NNQueue *buffer;
	
	while (buffer = [bufferEnumerator nextObject])
		[buffer clear];	
	
	// empty results
	[filteredObjects removeAllObjects];
}

- (NSMutableArray*)currentlyFilteredObjects
{
	NSMutableArray *results = [NSMutableArray array];
	id obj;
	
	NNQueue *lastBuffer = [buffers lastObject];
	
	while (obj = [lastBuffer tryDequeue])
	{
		[results addObject:obj];
	}
	
	return results;
}

- (BOOL)checkIfDone
{
	BOOL done = YES;
	
	// check if all buffers are empty
	NSEnumerator *bufferEnumerator = [buffers objectEnumerator];
	NNQueue *buffer;
	
	while (buffer = [bufferEnumerator nextObject])
	{
		if (![buffer count] == 0)
		{
			done = NO;
			break;
		}
	}
	
	return done;	
}

- (void)stopThread
{
	[self setThreadShouldQuit];
	
	[threadLock lockWhenCondition:NNThreadStopped];
	[threadLock unlock];
	
	return;
}

- (void)setThreadShouldQuit
{
	[threadLock lock];
	
	if ([threadLock condition] == NNThreadStopped)
		[threadLock unlock];
	else
		[threadLock unlockWithCondition:NNThreadCanceled];
}

- (NSMutableArray*)filters
{
	return filters;
}

- (void)addFilter:(NNObjectFilter*)newFilter
{
	// stops check thread and resets main buffer
	[self setObjects:filterObjects];
	
	NSEnumerator *e = [filters objectEnumerator];
	NNObjectFilter *filter;
	unsigned int slot = 0;
	
	// find place in the filter queue for the new filter
	while ((filter = [e nextObject]) && ([filter weight] >= [newFilter weight]))
		slot++;
	
	// connect newFilter's inqueue to the previous outQueue
	[newFilter setInQueue:[buffers objectAtIndex:slot]];
	
	// create new outQueue-buffer for the filter
	NNQueue *newOutQueue = [NNQueue queue];
	[buffers insertObject:newOutQueue atIndex:slot+1];
	[newFilter setOutQueue:newOutQueue];
	
	// insert new filter in the slot
	[filters insertObject:newFilter atIndex:slot];
	
	// handle the case when the filter is not the last filter
	if (slot < ([filters count]-1)) {
		NNObjectFilter *nextFilter = [filters objectAtIndex:slot+1];
		[nextFilter setInQueue:[newFilter outQueue]];
	}
	
	[self startWithServer:server];
}
	
- (void)removeFilter:(NNObjectFilter*)filter
{	
	if (!filter)
		return;

	// stops check thread and resets main buffer
	[self setObjects:filterObjects];
	
	unsigned int slot = [filters indexOfObject:filter];
	
	// reconnect next filter
	if (slot < [filters count]-1)
	{
		NNObjectFilter *nextFilter = [filters objectAtIndex:slot+1];
		[nextFilter setInQueue:[filter inQueue]];
	}
	
	// remove filter and buffer
	[filters removeObjectAtIndex:slot];
	[buffers removeObjectAtIndex:slot+1];
	
	[self startWithServer:server];
}

- (void)removeAllFilters
{
	// TODO more efficient
	
	NSEnumerator *e = [filters objectEnumerator];
	NNObjectFilter *filter;
	
	while (filter = [e nextObject])
		[self removeFilter:filter];
}

@end
