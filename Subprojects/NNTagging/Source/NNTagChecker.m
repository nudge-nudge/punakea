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

#import "NNTagChecker.h"

#import "NNFile.h"

NSInteger const NNTAGCHECKER_MAX_RETRY_COUNT = 10;

useconds_t const NNTAGCHECKER_CONSTANT_WAITTIME = 2000000; // 2.0 seconds
useconds_t const NNTAGCHECKER_INCREMENTAL_WAITTIME = 100000; // 0.1 seconds
useconds_t const NNTAGCHECKER_FILEMOVE_WAITTIME = 200000; // 0.2 seconds

NSString * const NNTagCheckerPositiveResult = @"NNTagCheckerPositiveResult";
NSString * const NNTagCheckerNegativeResult = @"NNTagCheckerNegativeResult";

@interface NNTagChecker (PrivateAPI)

- (void)startBackgroundThread;

- (BOOL)checkSpotlightsSorryAssForFile:(NNFile*)file;

- (NSString*)kickSpotlightsSorryAssForFile:(NNFile*)file;
- (NSString*)kickFile:(NNFile*)file;

@end

@implementation NNTagChecker

#pragma mark init
- (id)init
{
	if (self = [super init])
	{
		queue = [[NNQueue alloc] init];
		
		filesToCheck = [[NSMutableDictionary alloc] init];
		
		lock = [[NSLock alloc] init];
		
		metadataCacheFolder = [@"~/Library/Caches/Metadata" stringByExpandingTildeInPath];
		[metadataCacheFolder retain];
		
		numberFormatter = [[NSNumberFormatter alloc] init];
		
		nc = [NSNotificationCenter defaultCenter];
		
		[self startBackgroundThread];
	}
	return self;
}

- (void)dealloc
{
	[numberFormatter release];
	[metadataCacheFolder release];
	[lock release];
	[filesToCheck release];
	[queue release];
	[super dealloc];
}

#pragma mark event
- (void)checkFile:(NNFile*)file oldTags:(NSArray*)oldTags
{
	[lock lock];
	
	// get file info
	NSDictionary *fileInfo = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:oldTags, [NSNumber numberWithInteger:0], nil]
														 forKeys:[NSArray arrayWithObjects:@"oldTags",@"retryCount",nil]];
	
	// set the fileInfo for the file, possibly overwriting previous entries -
	// this is meant to be, always check for the latest tags
	[filesToCheck setObject:fileInfo forKey:[file path]];
	
	// add filename to queue
	[queue enqueue:file];
	
	[lock unlock];
}

- (void)applicationWillTerminate:(NSNotification*)notification
{
	// this is not used at the moment!- would need a dialog at app termination!
	
	// block main thread until queue is empty
	while (queue != nil && [queue count] > 0)
	{
		usleep(NNTAGCHECKER_INCREMENTAL_WAITTIME);
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
		NNFile *file = (NNFile*)[queue dequeue];
				
		NSString *currentFilePath = [[file path] copy];
		
		// get the file info
		[lock lock];
		NSDictionary *fileInfo = [filesToCheck objectForKey:currentFilePath];
		[lock unlock];
		
		NSInteger retryCount = NSIntegerMax; // will cause negative result if fileInfo is nil
		
		if (fileInfo)
			retryCount = [[fileInfo objectForKey:@"retryCount"] integerValue];

		// wait a bit - use retryCount as binary backoff value
		NSInteger backoff = 1<<(retryCount % 6);
		usleep(NNTAGCHECKER_INCREMENTAL_WAITTIME*backoff);
		
		BOOL success = [self checkSpotlightsSorryAssForFile:file];
		
		// retry up to MAX_RETRY_COUNT
		if (!success)
		{			
			if (retryCount < NNTAGCHECKER_MAX_RETRY_COUNT)
			{
				NSString *newPath = [self kickSpotlightsSorryAssForFile:file];
				
				// update file info
				retryCount++;
				fileInfo = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[fileInfo objectForKey:@"oldTags"],[NSNumber numberWithInteger:retryCount],nil]
													   forKeys:[NSArray arrayWithObjects:@"oldTags",@"retryCount",nil]];
				
				[lock lock];
				[filesToCheck removeObjectForKey:currentFilePath];
				[filesToCheck setObject:fileInfo forKey:newPath];
				[lock unlock];
				
				// re-enqueue file
				[queue enqueue:file];
			}
			else
			{
				// post failure notification
				NSDictionary *userInfo = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:file,[fileInfo objectForKey:@"oldTags"],nil]
																	 forKeys:[NSArray arrayWithObjects:@"file",@"oldTags",nil]];
				
				[nc postNotificationName:NNTagCheckerNegativeResult
								  object:self
								userInfo:userInfo];
			}
		}
		else
		{
			// post success notification
			NSDictionary *userInfo = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:file,[fileInfo objectForKey:@"oldTags"],nil]
																 forKeys:[NSArray arrayWithObjects:@"file",@"oldTags",nil]];
			
			[nc postNotificationName:NNTagCheckerPositiveResult
							  object:self
							userInfo:userInfo];
		}
		
		[lock lock];
		// empty dictionary if queue is empty
		if ([queue count] == 0)
			[filesToCheck removeAllObjects];
		[lock unlock];
		
		// queue doesn't autorelease stuff
		[file release];
		[currentFilePath release];
	}
}

- (BOOL)checkSpotlightsSorryAssForFile:(NNFile*)file
{
	// read tags from spotlight db's kMDItemFinderComment
	NNTagToFileWriter *tagToFileWriter = [[NNTagStoreManager defaultManager] tagToFileWriter];
	NSArray *tagsInSpotlightDB = [tagToFileWriter readTagsFromFile:file
												   creationOptions:NNTagsCreationOptionNone];
	
	return [[file tags] isEqualToSet:[NSSet setWithArray:tagsInSpotlightDB]];
}

- (NSString*)kickSpotlightsSorryAssForFile:(NNFile*)file
{
	// moving the file gives spotlight the chance to reindex
	// just move it to a temp folder and back
	return [self kickFile:file];
}

// not used at the moment
/*
- (NSString*)kickManagedFile:(NNFile*)file
{
	NSFileManager *fileManager = [NSFileManager defaultManager];
	
	BOOL success;
	NSError *error;	
	NSString *src = [file path];
	NSString *dst;
	
	// get index of current folder
	NSString *stringIndex = [[src stringByDeletingLastPathComponent] lastPathComponent];
	NSNumber *idx = [numberFormatter numberFromString:stringIndex];
	unsigned int i = [idx unsignedIntValue];
	
	// increment the index and move the file to the new folder
	BOOL done = NO;
	while (!done)
	{
		i++;
		NSString *incIndex = [numberFormatter stringFromNumber:[NSNumber numberWithUnsignedInt:i]];
		
		NSString *managedFolderWithIndex = [[[NNTagStoreManager defaultManager] managedFolder] stringByAppendingPathComponent:incIndex];
		
		// make sure the new dir exists
		BOOL isDirectory;
		
		if (![fileManager fileExistsAtPath:managedFolderWithIndex isDirectory:&isDirectory])
		{
			// create it
			success = [fileManager createDirectoryAtPath:managedFolderWithIndex attributes:nil];
			
			if (!success)
				NSLog(@"error creating new index folder %@ in managed folder",managedFolderWithIndex);
		}
		else if (!isDirectory)
		{
			NSLog(@"error: %@ should be a directory, is a file",managedFolderWithIndex);
		}
		
		dst = [managedFolderWithIndex stringByAppendingPathComponent:[file filename]];
		
		// stop if folder not containing a file with this name has been found
		if (![fileManager fileExistsAtPath:dst isDirectory:&isDirectory])
			done = YES;
	}
	
	// do the move
	success = [fileManager moveItemAtPath:src
								   toPath:dst
									error:&error];
	
	if (!success)
	{
		NSLog(@"error moving managed file %@",[error localizedDescription]);
	}
	else
	{
		// update path on file
		[file setPath:dst];
	}
	
	return dst;
}
*/

- (NSString*)kickFile:(NNFile*)file
{
	BOOL success;
	NSError *error;
	
	NSString *src = [file path];
	NSString *dst =  [metadataCacheFolder stringByAppendingPathComponent:[file filename]];
	
	success = [[NSFileManager defaultManager] moveItemAtPath:src toPath:dst error:&error];

	if (!success)
		NSLog(@"error while moving file to '~/Library/Caches/Metadata': %@",[error localizedDescription]);
	
	// wait a bit before moving back
	usleep(NNTAGCHECKER_FILEMOVE_WAITTIME);
	
	success = [[NSFileManager defaultManager] moveItemAtPath:dst toPath:src error:&error];

	if (!success)
		NSLog(@"error while moving file to '~/Library/Caches/Metadata': %@",[error localizedDescription]);
	
	return src;
}

	

@end
