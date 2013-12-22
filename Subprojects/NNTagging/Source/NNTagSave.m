// Copyright (c) 2006-2013 nudge:nudge (Johannes Hoffart & Daniel Bär). All rights reserved.
// 
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "NNTagSave.h"

#import "OpenMeta.h"
#import "NNTagging.h"
#import "NNTaggableObject.h"
#import "NNTags.h"
#import "NNTagDirectoryWriter.h"

#import "lcl.h"

NSInteger const NNTAGSAVE_MAX_RETRY_COUNT = 10;
useconds_t const NNTAGSAVE_CYCLETIME = 200000; // 0.2 seconds

@interface NNTagSave (PrivateAPI)

- (void)startBackgroundThread;

- (BOOL)handleTaggableObject:(NNTaggableObject*)taggableObject;

- (void)createDirectoryForFile:(NNFile*)file withOldTags:(NSArray*)oldTags;

@end


@implementation NNTagSave

#pragma mark init
- (id)init
{
	if (self = [super init])
	{
		queue = [[NNQueue alloc] init];
		
		tagStoreManager = [NNTagStoreManager defaultManager];
		
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(taggableObjectUpdate:)
													 name:NNTaggableObjectUpdate
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
	if ([notification object] == nil)
	{
		lcl_log(lcl_cnntagging, lcl_vError, @"TaggableObject already gone");
		return;
	}
	
	NSParameterAssert([[notification object] isKindOfClass:[NNTaggableObject class]]);
	
	[queue enqueue:[notification object]];
}

- (void)applicationWillTerminate:(NSNotification*)notification
{
	// sync recent OpenMeta tags
	[OpenMetaPrefs synchPrefs];
	
	// block main thread until queue is empty
	while (queue != nil && [queue count] > 0)
	{
		usleep(NNTAGSAVE_CYCLETIME);
	}
	
	// close the tag database
	if (tagStoreManager != nil && [tagStoreManager db] != nil)
	{
		[[tagStoreManager db] close];
	}
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
	while (YES)
	{
		// this blocks until an object is available
		NNTaggableObject *currentObject = (NNTaggableObject*)[queue dequeue];
		
		// skip objects that cannot be tagged
		if (![currentObject isWritable])
		{
			lcl_log(lcl_cnntagging,lcl_vError,@"Could not write tags to %@, object is not writable",currentObject);
			
			// queue doesn't autorelease stuff
			[currentObject release];
			continue;
		}
		
		BOOL success = [self handleTaggableObject:currentObject];
		
		// retry up to MAX_RETRY_COUNT
		if (!success)
		{
			if ([currentObject retryCount] < NNTAGSAVE_MAX_RETRY_COUNT)
			{
				[currentObject incrementRetryCount];
				[queue enqueue:currentObject];
			}
			else
			{
				lcl_log(lcl_cnntagging,lcl_vError,@"Writing tags to %@ failed",currentObject);
			}
		}
		
		// queue doesn't autorelease stuff
		[currentObject release];
	}
}

- (BOOL)handleTaggableObject:(NNTaggableObject*)taggableObject
{	
	NSArray *oldTags = [[tagStoreManager tagToFileWriter] readTagsFromFile:(NNFile*)taggableObject 
														   creationOptions:NNTagsCreationOptionTemp];
	
	// update recent tags for OpenMeta
	NSArray* oldTagNames = [[NNTagging tagging] tagNamesForTags:oldTags];
	NSArray *newTagNames = [[NNTagging tagging] tagNamesForTags:[[taggableObject tags] allObjects]];

	[OpenMetaPrefs updatePrefsRecentTags:oldTagNames newTags:newTagNames];
	
	// save tags to tag store
	BOOL success = [taggableObject saveTags];
	
	if (success && [taggableObject isKindOfClass:[NNFile class]])
	{
		NNFile *file = (NNFile*)taggableObject;
		[self createDirectoryForFile:file withOldTags:oldTags];
	}
			
	return success;
}

- (void)createDirectoryForFile:(NNFile*)file withOldTags:(NSArray*)oldTags
{
	// create folder structure if enabled
	if ([[NNTagStoreManager defaultManager] tagsFolderEnabled])
	{
		[[tagStoreManager tagDirectoryWriter] createDirectoryStructureForTaggableObject:file withOldTags:oldTags];
	}
}

@end