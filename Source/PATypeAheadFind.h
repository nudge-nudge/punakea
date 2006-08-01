//
//  PATypeAheadFind.h
//  punakea
//
//  Created by Johannes Hoffart on 06.05.06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PATagger.h"
#import "PATags.h"

/**
simple type ahead find implementation, not the quickest, but works
 */
@interface PATypeAheadFind : NSObject {
	PATags *tags; /**< all tags currently known */
	NSArray *activeTags;
	
	NSString *prefix;
	NSMutableArray *matchingTags; /**< all tags matching the current prefix */
}


- (NSArray*)activeTags;
- (void)setActiveTags:(NSArray*)someTags;

/**
returns the prefix
 @return prefix current prefix
 */
- (NSString*)prefix;

/**
changes the current prefix to the given one -
 automatically updates matchingTags
 @param newPrefix new prefix
 */
- (void)setPrefix:(NSString*)newPrefix;

/**
tags matching the prefix
 @return matchingTags tags matching the current prefix
 */
- (NSMutableArray*)matchingTags;

/**
checks if there are any tags at all matching the prefix,
 this does not influence matchingTags:
 @param prefix prefix to look for
 @return true if there are any tags matching the prefix
 */
- (BOOL)hasTagsForPrefix:(NSString*)prefix;

- (NSArray*)tagsForPrefix:(NSString*)prefix;
- (NSArray*)tagsForPrefix:(NSString*)prefix inTags:(NSArray*)tags;

@end
