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
	NSMutableArray *activeTags;
}


- (NSMutableArray*)activeTags;
- (void)setActiveTags:(NSMutableArray*)someTags;

/**
checks if there are any tags at all matching the prefix,
 this does not influence matchingTags:
 @param prefix prefix to look for
 @return true if there are any tags matching the prefix
 */
- (BOOL)hasTagsForPrefix:(NSString*)prefix;

- (NSMutableArray*)tagsForPrefix:(NSString*)prefix;
- (NSMutableArray*)tagsForPrefix:(NSString*)prefix inTags:(NSArray*)tags;

@end
