//
//  PAActiveTags.h
//  punakea
//
//  Created by Johannes Hoffart on 17.02.06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PATag.h"

@interface PASelectedTags : NSObject {
	NSMutableArray *tags;
}

- (NSEnumerator*)objectEnumerator;

- (NSArray *)tags;

//controller stuff
- (void)addTagToTags:(PATag*)tag;
- (void)addTagsToTags:(NSArray*)tags;
- (void)clearTags;
- (void)removeTagFromTags:(PATag*)tag;
- (void)removeTagsFromTags:(NSArray*)tags;

@end