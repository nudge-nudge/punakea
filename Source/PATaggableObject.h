//
//  PATaggableObject.h
//  punakea
//
//  Created by Johannes Hoffart on 19.12.06.
//  Copyright 2006 nudge:nudge. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PATag.h"
#import "PATags.h"

extern NSString * const PATaggableObjectUpdate;

/**
abstract class representing a taggable object (normally a file
 but can be anything really)
 */
@interface PATaggableObject : NSObject <NSCopying> {
	NSMutableSet *tags;
	NSNotificationCenter *nc;
	
	PATags *globalTags;
}

- (id)initWithTags:(NSSet*)someTags;

- (NSSet*)tags;
- (void)setTags:(NSSet*)someTags;

- (void)addTag:(PATag*)tag;
- (void)addTags:(NSArray*)someTags;
- (void)removeTag:(PATag*)tag;
- (void)removeTags:(NSArray*)someTags;
- (void)removeAllTags;

/**
must be implemented by subclass
 */
- (void)saveTags;

@end