//
//  PAFileCache.h
//  punakea
//
//  Created by Johannes Hoffart on 06.11.06.
//  Copyright 2006 nudge:nudge. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#include <unistd.h>

#import "PAFile.h"
#import "ThreadWorker.h"
#import "PATags.h"
#import "NSFileManager+PAExtensions.h"

extern useconds_t const PAFILECACHE_CYCLETIME;

extern int const MAX_RETRY_LIMIT;

extern NSString * const TAGGER_OPEN_COMMENT;
extern NSString * const TAGGER_CLOSE_COMMENT;

/**
used by PATagger to cache read-/write accesses
 */
@interface PAFileCache : NSObject {
	NSMutableDictionary *cache;
	NSMutableDictionary *fileRetryCount;
	
	BOOL synching;
	
	PATags *tags;
}

- (id)initWithTags:(PATags*)allTags;

- (NSArray*)keywordsForFile:(PAFile*)file;
- (void)writeKeywords:(NSArray*)keywords toFile:(PAFile*)file;

@end
