//
//  PATagSave.m
//  punakea
//
//  Created by Johannes Hoffart on 02.01.07.
//  Copyright 2006 nudge:nudge. All rights reserved.
//

#import "PATagSave.h"

@implementation PATagSave

#pragma mark init
- (id)init
{
	if (self = [super init])
	{
		queue = [[PAThreadSafeQueue alloc] init];
		
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(tagUpdate:)
													 name:PATaggableObjectUpdate
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
- (void)tagUpdate:(NSNotification*)notification
{
	NSParameterAssert([[notification object] isKindOfClass:[PATaggableObject class]]);
	
	[queue enqueue:[notification object]];
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
		[currentObject saveTags];
	}
}

@end