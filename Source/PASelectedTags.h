//
//  PASelectedTags.h
//  punakea
//
//  Created by Johannes Hoffart on 18.04.06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PATag.h"

@interface PASelectedTags : NSObject {
	NSMutableDictionary *selectedTags;
	PATag *lastTag;
	
	NSNotificationCenter *nc;
}

- (id)initWithTags:(NSDictionary*)tags;

- (NSArray*)selectedTagArray;
- (PATag*)lastTag;
- (void)setLastTag:(PATag*)aTag;
- (NSMutableDictionary*)selectedTags;
- (void)setSelectedTags:(NSMutableDictionary*)otherTags;

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