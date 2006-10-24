//
//  PATags.h
//  punakea
//
//  Created by Johannes Hoffart on 18.04.06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PATag.h"

typedef enum _PATagChangeOperation
{
	PATagRemoveOperation = 1,
	PATagAddOperation = 2,
	PATagResetOperation = 4,
	PATagUpdateOperation = 8
} PATagChangeOperation;

extern NSString * const PATagOperation;

/**
contains all PATag instances in the application. don't rely on tag order!
 posts PATagsHaveChanged notification whenever the tags array has changed or a single tag was renamed, clicked or used.
 look at code for userInfo specifics.
 */
@interface PATags : NSObject {
	NSMutableArray *tags;
	
	NSNotificationCenter *nc;
}

/**
returns the tag for the given name, or nil, if there is none
 @param tagName name of the tag to return
 @return tag with name or nil
 */
- (PATag*)tagForName:(NSString*)tagName;

- (NSMutableArray*)tags;
- (void)setTags:(NSMutableArray*)otherTags;

- (void)addTag:(PATag*)aTag;
- (void)removeTag:(PATag*)aTag;
- (NSEnumerator*)objectEnumerator;
- (int)count;
- (PATag*)tagAtIndex:(unsigned int)index;
- (void)sortUsingDescriptors:(NSArray *)sortDescriptors;

@end