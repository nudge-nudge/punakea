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
- (void)startFilterEngineWithPorts:(NSArray*)portArray;
- (void)stopFilterEngine;

- (NSConnection*)serverConnection;
- (void)setServerConnection:(NSConnection*)newConnection;
- (void)setPorts:(NSArray*)portArray;
- (NSArray*)ports;

- (void)setThreadShouldQuit;

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
	
	[serverConnection setReplyTimeout:5.0];
	
	[[NSRunLoop currentRunLoop] run];
	
	// do some book keeping	
	[threadCountLock lock];
	if (threadCount == 0)
	{
		BOOL established = NO;
		
		while (!established)
		{
			@try
			{
				[(id)[serverConnection rootProxy] filteringStarted];
				established = YES;
			}
			@catch (NSException *e)
			{
				NSLog(@"main thread not ready yet");
			}
		}			
	}
	
	threadCount++;
	[threadCountLock unlock];
	
	// wait for possible previous thread to stop
	[threadLock lockWhenCondition:NNThreadStopped];
	
	//  start thread
	[threadLock unlockWithCondition:NNThreadRunning];

	// reduce timeout to avoid deadlocks
	[serverConnection setReplyTimeout:0.2];
	
	while ([threadLock condition] == NNThreadRunning)
	{		
		usleep(50000);

		if (![threadLock condition] == NNThreadRunning)
		{
			NSLog(@"was here");
			break;
		}
		
		if ([threadLock lockWhenCondition:NNThreadRunning 
							   beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.1]])
		{
			NSMutableArray *currentlyFilteredObjects = [self currentlyFilteredObjects];
			
			if ([currentlyFilteredObjects count] > 0)
			{
				[self lockFilteredObjects];
				[filteredObjects addObjectsFromArray:currentlyFilteredObjects];
				[self unlockFilteredObjects];
				@try
				{
					[(id)[serverConnection rootProxy] objectsFiltered];
				}
				@catch (NSException *e)
				{
					NSLog(@"deadlock avoided");
					// TODO this is not working!!
					//[[self outBuffer] enqueueObjects:currentlyFilteredObjects];
				}
			}
			[threadLock unlock];
		} 
				
		if ([self checkIfDone])
			break;
	}
	
	// increase timeout again
	[serverConnection setReplyTimeout:5.0];
	
	[threadCountLock lock];
	threadCount--;
	if (threadCount == 0)
	{
		BOOL established = NO;
		
		while (!established)
		{
			@try
			{
				[(id)[serverConnection rootProxy] filteringFinished];
				established = YES;
			}
			@catch (NSException *e)
			{
				NSLog(@"main thread not ready yet");
			}		
		}
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

- (NSArray*)filterObjects
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

- (NNQueue*)inBuffer
{
	if ([buffers count] > 0)
		return [buffers objectAtIndex:0];
	else
		return nil;
}

- (NNQueue*)outBuffer
{
	return [buffers lastObject];
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
	[[self inBuffer] enqueueObjects:[self filterObjects]];
	
	NSLog(@"filterEngine started with filterObjects: %@\ninBuffer: %@\nfilters: %@",[self filterObjects],[self inBuffer],filters);
	
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

- (void)reset
{
	[self stopFilterEngine];
	[self removeAllFilters];
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
	
	while (obj = [[self outBuffer] tryDequeue])
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

- (void)setThreadShouldQuit
{
	[threadLock lock];
	
	if ([threadLock condition] == NNThreadStopped)
		[threadLock unlock];
	else
		[threadLock unlockWithCondition:NNThreadCanceled];
}

- (BOOL)hasFilters
{
	return ([filters count] > 0);
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
	
	if (slot == NSNotFound)
		return;
	
	// reconnect next filter
	if (slot < [filters count]-1)
	{
		NNObjectFilter *nextFilter = [filters objectAtIndex:slot+1];
		[nextFilter setInQueue:[filter inQueue]];
	}
	
	// remove filter and buffer
	// wait for filter to stop
	[filter waitForFilter];
	
	[filters removeObjectAtIndex:slot];
	[buffers removeObjectAtIndex:slot+1];
	
	[self startWithServer:server];
}

- (void)removeAllFilters
{
	// stops check thread and resets main buffer
	[self setObjects:filterObjects];
	
	// wait for all filters to stop
	NSEnumerator *e = [filters objectEnumerator];
	NNObjectFilter *filter;
	
	while (filter = [e nextObject])
		[filter waitForFilter];
	
	// all filters are stopped now
	[filters removeAllObjects];
	
	// remove all buffers
	[buffers removeAllObjects];
	
	// re-add inbuffer
	[buffers addObject:[NNQueue queue]];
}

@end
