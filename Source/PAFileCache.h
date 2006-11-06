//
//  PAFileCache.h
//  punakea
//
//  Created by Johannes Hoffart on 06.11.06.
//  Copyright 2006 nudge:nudge. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PAFile.h"
#import "ThreadWorker.h"
#import "PATags.h"

extern int const PAFILECACHE_CYCLETIME;

extern NSString * const TAGGER_OPEN_COMMENT;
extern NSString * const TAGGER_CLOSE_COMMENT;

/**
used by PATagger to cache read-/write accesses
 */
@interface PAFileCache : NSObject {
	NSMutableDictionary *cache;
	NSLock *cacheLock;
	
	NSTimer *timer;
	
	PATags *tags;
}

- (id)initWithTags:(PATags*)allTags;

- (NSArray*)keywordsForFile:(PAFile*)file;
- (void)writeKeywords:(NSArray*)keywords toFile:(PAFile*)file;

@end
