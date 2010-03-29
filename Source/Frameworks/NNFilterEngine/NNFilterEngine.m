//
//  NNFilterEngine.m
//  NNTagging
//
//  Created by Johannes Hoffart on 17.04.07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "NNFilterEngine.h"

@interface NNFilterEngine (PrivateAPI)

- (NNQueue*)inBuffer;
- (NNQueue*)outBuffer;

@end

@implementation NNFilterEngine

#pragma mark init
- (id)initWithFilterObjects:(NSArray*)objects 
					filters:(NSArray*)someFilters 
				   delegate:(id<NNFilterEngineDelegate>)aDelegate
{
	if (self = [super init])
	{	
		finished = NO;
		
		filteredObjects = [[NSMutableArray alloc] init];
			
		// sort filters by weight - filters with lower weight are more efficient
		// TODO sort descending!
		 filters = [[someFilters sortedArrayUsingSelector:@selector(weight)] retain];
		
		// create buffers for all filters
		buffers = [[NSMutableArray alloc] init];
		
		for (NSUInteger i=0;i<[filters count]+1;i++)
		{
			[buffers addObject:[NNQueue queue]];
		}
		
		// fill inBuffer
		[[self inBuffer] enqueueObjects:objects];
		
		// connect buffers with filters
		// TODO buffers are not correct when more than 1 filter is present
		for (NSUInteger i=0;i<[filters count];i++)
		{			
			NNObjectFilter *filter = [filters objectAtIndex:i];
			[filter setInQueue:[buffers objectAtIndex:i]];
			[filter setOutQueue:[buffers objectAtIndex:i+1]];
		}
		
		// set delegate
		delegate = aDelegate;		
	}
	return self;
}
	
- (void)dealloc
{
	[filters release];
	[buffers release];
	[filteredObjects release];
	
	[super dealloc];
}

#pragma mark functionality
- (void)main
{
	// start all filters
	for (NNObjectFilter *filter in filters)
	{
		[filter run];
	}

	// check if objects are filtered - call delegate if new ones are available
	while (![self isCancelled]) 
	{
		for (NSUInteger i=0;i<([buffers count]);i++)
		{
			NSLog(@"Buffer %ld : %ld",i,[[buffers objectAtIndex:i] count]);
		}		
		
		NSMutableArray *newObjects = [NSMutableArray array];
		id obj;
		while ((obj = [[self outBuffer] tryDequeue]) != nil)
		{
			[newObjects addObject:obj];
		}
		
		if ([newObjects count] > 0)
		{
			[filteredObjects addObjectsFromArray:newObjects];
			
			// call delegate with a copy of the array (avoid races)
			// check again if cancelled in the mean time
			if (![self isCancelled])
			{
				[delegate filterEngineFilteredObjects:[NSArray arrayWithArray:filteredObjects]];
			}
		}
		else 
		{
			// check if all buffers are empty and the filtering is done
			BOOL done = YES;
			
			for (NNQueue *buffer in buffers)
			{
				if (![buffer count] == 0)
				{
					done = NO;
					break;
				}
			}
			
			if (done && ![self isCancelled])
			{
				// cancel all NNObjectFilters
				for (NNObjectFilter *filter in filters)
				{
					[filter cancel];
				}
				
				[delegate filterEngineFinishedFiltering];
				[self willChangeValueForKey:@"executing"];
				[self willChangeValueForKey:@"finished"];
				finished = YES;
				[self didChangeValueForKey:@"executing"];
				[self didChangeValueForKey:@"finished"];
				break;
			}
		}

		usleep(50000);
	}
}

- (BOOL)hasFilters
{
	return ([filters count] > 0);
}

- (NNQueue*)inBuffer
{
	return [buffers objectAtIndex:0];
}

- (NNQueue*)outBuffer
{
	return [buffers lastObject];
}

#pragma mark NSOperation stuff
- (BOOL)isConcurrent
{
	return YES;
}

- (BOOL)isExecuting
{
	return !finished;
}

- (BOOL)isFinished
{
	return finished;
}

@end
