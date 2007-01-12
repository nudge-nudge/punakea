//
//  PATags.h
//  punakea
//
//  Created by Johannes Hoffart on 18.04.06.
//  Copyright 2006 nudge:nudge. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PATag.h"
#import "PASimpleTag.h"

typedef enum _PATagChangeOperation
{
	PATagRemoveOperation = 0,
	PATagAddOperation = 1,
	PATagResetOperation = 2,
	PATagNameChangeOperation = 4,
	PATagUseIncrementOperation = 8,
	PATagClickIncrementOperation = 16
} PATagChangeOperation;

extern NSString * const PATagOperation;

extern NSString * const PATagsHaveChangedNotification;

/**
contains all PATag instances in the application. don't rely on tag order!
 posts PATagsHaveChanged notification whenever the tags array has changed or a single tag was renamed, clicked or used.
 look at code for userInfo specifics.
 */
@interface PATags : NSObject {
	NSMutableArray *tags; /**< holds all tags */
	
	/** 
		hash tagname -> tag for quick access 
		hash uses lowercase-only strings for identifying
	*/
	NSMutableDictionary *tagHash;
	
	NSNotificationCenter *nc;
}

/**
 singleton
 */
+ (PATags*)sharedTags;

/**
returns the tag for the given name, or nil, if there is none
 @param tagName name of the tag to return
 @return tag with name or nil
 */
- (PATag*)tagForName:(NSString*)tagName;

/**
returns all tags corresponding to the names - if they exist
 @param tagNames array of strings
 @return tags for tagNames
 */
- (NSArray*)tagsForNames:(NSArray*)tagNames;

/**
returns the tag for the given name or creates a new simpletag 
 if it doesn't exist
 @param tagName name of the tag
 @return tag with name or new PASimpleTag for tagName
 */
- (PATag*)createTagForName:(NSString*)tagName;

- (NSMutableArray*)tags;
- (void)setTags:(NSMutableArray*)otherTags;

- (void)addTag:(PATag*)aTag;
- (void)removeTag:(PATag*)aTag;
- (NSEnumerator*)objectEnumerator;
- (int)count;
- (PATag*)tagAtIndex:(unsigned int)idx;
- (void)sortUsingDescriptors:(NSArray *)sortDescriptors;
- (PATag*)currentBestTag;

/**
will throw an exception for an invalid keyword
 */
- (void)validateKeyword:(NSString*)keyword;
@end