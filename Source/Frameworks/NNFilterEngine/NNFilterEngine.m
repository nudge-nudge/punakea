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
		filteredObjects = [[NSMutableArray alloc] init];
			
		// sort filters by weight - filters with lower weight are more efficient
		NSSortDescriptor *sortDesc = [[NSSortDescriptor alloc] initWithKey:@"weight"
																 ascending:YES];
		filters = [[someFilters sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDesc]] retain];
		[sortDesc release];
		
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
			
			NNQueue *inBuffer = [buffers objectAtIndex:i];
			NNQueue *outBuffer = [buffers objectAtIndex:i+1];
			
			[filter setInQueue:inBuffer];
			[filter setOutQueue:outBuffer];
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
				if ([delegate respondsToSelector:@selector(filterEngineFilteredObjects:)])
				{
					[delegate performSelectorOnMainThread:@selector(filterEngineFilteredObjects:)
											   withObject:[NSArray arrayWithArray:filteredObjects]
											waitUntilDone:NO];
				}
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
				
				if ([delegate respondsToSelector:@selector(filterEngineFinishedFiltering:)])
				{
					[delegate performSelectorOnMainThread:@selector(filterEngineFinishedFiltering:)
											   withObject:[NSArray arrayWithArray:filteredObjects]
											waitUntilDone:NO];
				}
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
/*
 overwriting cancel - need to cancel all NNObjectFilters
 */
- (void)cancel
{
	for (NNObjectFilter *filter in filters)
	{
		[filter cancel];
	}
	
	[super cancel];
}

@end
