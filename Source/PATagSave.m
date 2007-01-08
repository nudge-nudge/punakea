//
//  PATagSave.m
//  punakea
//
//  Created by Johannes Hoffart on 02.01.07.
//  Copyright 2006 nudge:nudge. All rights reserved.
//

#import "PATagSave.h"

int const MAX_RETRY_COUNT = 10;
useconds_t const PATAGSAVE_CYCLETIME = 200000; // 0.2 seconds


@implementation PATagSave

#pragma mark init
- (id)init
{
	if (self = [super init])
	{
		queue = [[PAThreadSafeQueue alloc] init];
		
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(taggableObjectUpdate:)
													 name:PATaggableObjectUpdate
												   object:nil];
		
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(applicationWillTerminate:)
													 name:NSApplicationWillTerminateNotification
												   object:nil];
		
		[self startBackgroundThread];
	}
	return self;
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[queue release];
	[super dealloc];
}

#pragma mark event
- (void)taggableObjectUpdate:(NSNotification*)notification
{
	NSParameterAssert([[notification object] isKindOfClass:[PATaggableObject class]]);
	
	[queue enqueue:[notification object]];
}

- (void)applicationWillTerminate:(NSNotification*)notification
{
	// block main thread until queue is empty
	while ([queue tryDequeue] != NULL)
		usleep(PATAGSAVE_CYCLETIME);
}

#pragma mark queue functionality
- (void)startBackgroundThread
{
	[NSApplication detachDrawingThread:@selector(processQueue)
							  toTarget:self
							withObject:nil];
}

- (void)processQueue
{
	// this is the method executed by the background thread
	// - it will be executed during all application lifetime
	// - blocks when no object should be processed
	
	while (true)
	{
		// this blocks until an object is available
		PATaggableObject *currentObject = (PATaggableObject*)[queue dequeue];	
		
		// TODO perhaps a timeout is in order
		BOOL success = [currentObject saveTags];
		
		// retry up to MAX_RETRY_COUNT
		if (!success )
		{
			if ([currentObject retryCount] < MAX_RETRY_COUNT)
			{
				[currentObject incrementRetryCount];
				[queue enqueue:currentObject];
			}
			else
			{
				NSLog(@"writing tags to %@ failed",currentObject);
			}
		}
	}
}

@end