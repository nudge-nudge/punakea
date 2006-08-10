//
//  TaggerInterface.h
//  punakea
//
//  Created by Johannes Hoffart on 05.02.06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <CoreServices/CoreServices.h>
#import "Matador.h"
#import "PATags.h"
#import "PASimpleTagFactory.h"
#import "PATempTag.h"

/**
singleton class for working with spotlight kMDItemKeywords
 */
@interface PATagger : NSObject {
	PASimpleTagFactory *simpleTagFactory;
	PATags *tags;
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
- (void)addTag:(PASimpleTag*)tag ToFile:(NSString*)path;

/**
add multiple tags to a file
 @param tags array with tags
 @param path path to file
 */
- (void)addTags:(NSArray*)tags ToFile:(NSString*)path;

/**
add tag to multiple files
 @param tag tag
 @param paths array with filepaths
 */
- (void)addTag:(PASimpleTag*)tag ToFiles:(NSArray*)paths;

/**
add tags to multiple files
 @param tags array with simpletags tag
 @param paths array with filepaths
 */
- (void)addTags:(NSArray*)tags ToFiles:(NSArray*)paths;

/**
removes the tag from all files
 @param tag tag to remove
 @param files files to remove tags from (array of path strings)
 */
- (void)removeTag:(PASimpleTag*)tag fromFiles:(NSArray*)files;

/**
removes the tags from all files
 @param tags tag array with simpleTags to remove
 @param files files to remove tags from (array of path strings)
 */
- (void)removeTags:(NSArray*)tags fromFiles:(NSArray*)files;

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

/**
gets simple tags for file at path
 @param path path to file
 @return array of simple tags on file
 */
- (NSArray*)simpleTagsForFileAtPath:(NSString*)path;

/**
gets simple tags for all files at the paths
 @param paths NSArray of NSStrings with file paths
 @return array of simple tags on files
 */
- (NSArray*)simpleTagsForFilesAtPaths:(NSArray*)paths;

/**
gets tag names of simple tags for all files at the paths (with count)
 @param paths NSArray of NSStrings with file paths
 @return dict with simple tags (and occurrence count) of files at paths
 */
- (NSDictionary*)simpleTagNamesWithCountForFilesAtPaths:(NSArray*)paths;


// NEW
- (NSArray*)tagsOnFiles:(NSArray*)filePaths;
- (NSArray*)tagsOnFiles:(NSArray*)filePaths includeTempTags:(BOOL)includeTempTags;
- (PATag*)tagForName:(NSString*)tagName;
- (PATag*)tagForName:(NSString*)tagName includeTempTag:(BOOL)includeTempTag;
- (NSArray*)tagsForNames:(NSArray*)tagNames includeTempTags:(BOOL)includeTempTags;
- (PATag*)createTagForName:(NSString*)tagName;
- (NSArray*)createTagsForNames:(NSArray*)tagNames;
- (void)addTags:(NSArray*)tags toFile:(NSString*)filePath;
- (void)addKeywords:(NSArray*)keywords toFile:(NSString*)filePath createSimpleTags:(BOOL)createSimpleTags;

#pragma mark accessors
- (PATags*)tags;
- (void)setTags:(PATags*)allTags;

@end
