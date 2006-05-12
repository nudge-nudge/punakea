//
//  TaggerInterface.h
//  punakea
//
//  Created by Johannes Hoffart on 05.02.06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <CoreServices/CoreServices.h>
#import "PASimpleTagFactory.h"
#import "Matador.h"

/**
singleton class for working with spotlight kMDItemKeywords
 */
@interface PATagger : NSObject {
	PASimpleTagFactory *tagFactory;
}

/**
get the singleton instance
 @return singleton instance of PATagger
 */
+ (PATagger*)sharedInstance;

//TODO rename the addTag* methods

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
add tag to multiple files
 @param tag tag
 @param paths array with filepaths
 */
- (void)addTagToFiles:(PASimpleTag*)tag filePaths:(NSArray*)paths;

/**
add tags to multiple files
 @param tags array with simpletags tag
 @param paths array with filepaths
 */
- (void)addTagsToFiles:(NSArray*)tags filePaths:(NSArray*)paths;

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
get keywords as NSString array for file at path
 @param path file for which to get the tags
 @return array with NSStrings corresponding to the kMDItemKeywords on the file
 */
- (NSArray*)keywordsForFile:(NSString*)path;

@end
