//
//  TaggerInterface.h
//  punakea
//
//  Created by Johannes Hoffart on 05.02.06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <CoreServices/CoreServices.h>
#import "PATag.h"
#import "Matador.h"
#import "PASimpleTagFactory.h"

/**
singleton class for working with spotlight kMDItemKeywords
 */
@interface PATagger : NSObject {
	PASimpleTagFactory *tagFactory; /**< for constructing tags from strings */
}

/**
get the singleton instance
 @return singleton instance of PATagger
 */
+ (PATagger*)sharedInstance;

/**
adds a single tag to a file
 @param tag tag to add to file
 @param path path to file
 */
- (void)addTagToFile:(PASimpleTag*)tag filePath:(NSString*)path;

/**
add multiple tags to a file
 @param tags array with tags
 @param path path to file
 */
- (void)addTagsToFile:(NSArray*)tags filePath:(NSString*)path;

/**
removes the tag from all files
 @param tag tag to remove
 @param files files to remove tags from (array of path strings)
 */
- (void)removeTag:(PASimpleTag*)tag fromFiles:(NSArray*)files;

/**
renames the tag on all files
 @param tag tag to rename
 @param newTag new name
 @param files files to rename in (array of path strings)
 */
- (void)renameTag:(PASimpleTag*)tag toTag:(PASimpleTag*)newTag onFiles:(NSArray*)files;

/**
get keywords as PASimpleTag array for file at path
 @param path file for which to get the tags
 @return array with PASimpleTags corresponding to the kMDItemKeywords on the file
 */
- (NSMutableArray*)getTagsForFile:(NSString*)path;

@end
