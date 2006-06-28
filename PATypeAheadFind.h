//
//  PATypeAheadFind.h
//  punakea
//
//  Created by Johannes Hoffart on 06.05.06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PATags.h"

/**
simple type ahead find implementation, not the quickest, but works
 */
@interface PATypeAheadFind : NSObject {
	PATags *allTags; /**< all tags currently known */
	
	NSString *prefix;
	NSMutableArray *matchingTags; /**< all tags matching the current prefix */
}

- (id)initWithTags:(PATags*)tags;

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

@end
