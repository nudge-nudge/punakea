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

- (NSArray*)tagsOnFiles:(NSArray*)filePaths;
- (NSArray*)tagsOnFiles:(NSArray*)filePaths includeTempTags:(BOOL)includeTempTags;

- (PATag*)tagForName:(NSString*)tagName;
- (PATag*)tagForName:(NSString*)tagName includeTempTag:(BOOL)includeTempTag;

- (NSArray*)tagsForNames:(NSArray*)tagNames includeTempTags:(BOOL)includeTempTags;

/**
add multiple tags to a file
 @param tags array with tags
 @param path path to file
 */
- (void)addTags:(NSArray*)tags toFiles:(NSArray*)filePaths;

- (PATag*)createTagForName:(NSString*)tagName;

- (NSArray*)createTagsForNames:(NSArray*)tagNames;

- (void)addKeywords:(NSArray*)keywords toFiles:(NSArray*)filePaths createSimpleTags:(BOOL)createSimpleTags;

/**
get keywords as NSString array for file at path
 @param path file for which to get the tags
 @return array with NSStrings corresponding to the kMDItemKeywords on the file
 */
- (NSArray*)keywordsForFile:(NSString*)path;

/**
removes the tag from all files
 @param tag tag to remove
 @param files files to remove tags from (array of path strings)
 */
- (void)removeTag:(PATag*)tag fromFiles:(NSArray*)files;

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
- (void)renameTag:(PATag*)tag toTag:(PATag*)newTag onFiles:(NSArray*)files;

/**
gets tag names of simple tags for all files at the paths (with count)
 @param paths NSArray of NSStrings with file paths
 @return dict with simple tags (and occurrence count) of files at paths
 */
- (NSDictionary*)tagNamesWithCountForFilesAtPaths:(NSArray*)paths;

#pragma mark accessors
- (PATags*)tags;
- (void)setTags:(PATags*)allTags;

@end
