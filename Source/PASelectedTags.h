//
//  PASelectedTags.h
//  punakea
//
//  Created by Johannes Hoffart on 18.04.06.
//  Copyright 2006 nudge:nudge. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PATagging/PATag.h"

/**
container class for selected tags
 */
@interface PASelectedTags : NSObject {
	NSMutableArray *selectedTags;
	PATag *lastTag;
	
	NSNotificationCenter *nc;
}

- (id)initWithTags:(NSArray*)tags;

- (PATag*)lastTag;
- (void)setLastTag:(PATag*)aTag;
- (NSMutableArray*)selectedTags;
- (void)setSelectedTags:(NSMutableArray*)otherTags;

- (void)removeLastTag;
- (void)removeAllTags;
- (unsigned int)count;
- (void)addTag:(PATag*)aTag;
- (void)removeTag:(PATag*)aTag;
- (BOOL)containsTag:(PATag*)aTag;
- (NSEnumerator*)objectEnumerator;

- (void)addObjectsFromArray:(NSArray*)array;
- (void)removeObjectsInArray:(NSArray*)array;

@end