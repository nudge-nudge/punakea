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

//
// NOT USED AT THE MOMENT. OpenMeta SHOULD DO FINE!

#import <Cocoa/Cocoa.h>

#import "NNQueue.h"

@class NNFile;

extern NSInteger const NNTAGCHECKER_MAX_RETRY_COUNT;
extern useconds_t const NNTAGCHECKER_CONSTANT_WAITTIME;
extern useconds_t const NNTAGCHECKER_INCREMENTAL_WAITTIME;
extern useconds_t const NNTAGCHECKER_FILEMOVE_WAITTIME;

extern NSString * const NNTagCheckerPositiveResult;
extern NSString * const NNTagCheckerNegativeResult;

/**
 \internal
 
 TODO is this still needed? Probably does not hurt to check, but moving file around
 is not necessary
 
 This class verifies each NNFile after NNTagSave has written a new comment to
 it. If the comment doesn't match the tags, NNTagChecker will try to get spotlight
 to reindex it.
 */
@interface NNTagChecker : NSObject {
	/** queue holding the files to check */
	NNQueue					*queue;
	
	NSMutableDictionary		*filesToCheck;
	NSLock					*lock;
	
	NSNumberFormatter		*numberFormatter;
	
	NSNotificationCenter	*nc;
	
	NSString				*metadataCacheFolder;
}

/**
 Tells TagChecker to check files for corect spotlight comment
 @param file	File to check
 @param oldTags	Tags that have been on file previously - needed for NNTagSave
 */
- (void)checkFile:(NNFile*)file oldTags:(NSArray*)oldTags;

@end

