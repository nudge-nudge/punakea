//
//  PATags.h
//  punakea
//
//  Created by Johannes Hoffart on 18.04.06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PATag.h"
#import "PASimpleTag.h"
#import "PASimpleTagFactory.h"

@interface PATags : NSObject {
	NSMutableArray *tags;
	PASimpleTagFactory *simpleTagFactory;
}

- (NSMutableArray*)tags;
- (void)setTags:(NSMutableArray*)otherTags;
- (void)insertObject:(PATag *)tag inTagsAtIndex:(unsigned int)i;
- (void)removeObjectFromTagsAtIndex:(unsigned int)i;

- (void)addTag:(PATag*)aTag;
- (NSEnumerator*)objectEnumerator;

/**
looks for the simple tag with the corresponding name -
 if none exists, a new one is created and added
 @param name the tag name
 @return existing or newly created tag
 */
- (PASimpleTag*)simpleTagForName:(NSString*)name;

/**
gets simple tags for all passed names
 @param names NSString array
 @return NSArray containing simple tags
 */
- (NSArray*)simpleTagsForNames:(NSArray*)names;

@end