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

#include <unistd.h>

#import <Cocoa/Cocoa.h>
#import "NNQueue.h"
#import "NNTagStoreManager.h"
#import "OpenMeta.h"
#import "OpenMetaPrefs.h"

@class NNTagging;
@class NNTaggableObject;
@class NNTags;
@class NNTagDirectoryWriter;

extern NSInteger const NNTAGSAVE_MAX_RETRY_COUNT;
extern useconds_t const NNTAGSAVE_CYCLETIME;

/**
\internal
 
waits for taggable objects to post update notifications
 runs a background thread to update the backing storage
 (spotlight comment, folder structure, ...)
 
 TagSave is started by NNTags
 */
@interface NNTagSave : NSObject {
	/** queue holding NNTaggable objects to work on */
	NNQueue *queue;
			
	NNTagStoreManager *tagStoreManager;
}

@end
