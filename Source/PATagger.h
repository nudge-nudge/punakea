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
convenience method:
calls tagsOnFiles: with includeTempTags:YES
 @param filePaths files to fetch tags for
 @return array of PATags
 */
- (NSArray*)tagsOnFiles:(NSArray*)filePaths;

/**
returns an array of PATags, corresponding to the kMDItemKeywords on the files
 creates PATempTags for tags not in PATags
 @param filePaths files to fetch tags for
 @param includeTempTags flag controlling tempTag creation
 @return array of PATags
 */
- (NSArray*)tagsOnFiles:(NSArray*)filePaths includeTempTags:(BOOL)includeTempTags;

/**
convenience method: 
 calls tagForName: with includeTempTag:YES
 @param tagName name of tag
 @return PATag corresponding to tagName, if no tag is found, a PATempTag is created and returned
 */
- (PATag*)tagForName:(NSString*)tagName;

/**
fetches a tag from PATags for the given tagName
 @param tagName name of the tag
 @param includeTempTag flag controlling the creation of PATempTags
 @return PATag with the name, PATempTag when no tag is found and includeTempTag is YES, nil otherwise
 */
- (PATag*)tagForName:(NSString*)tagName includeTempTag:(BOOL)includeTempTag;

/**
convenience method:
 fetches an array of PATags corresponding to tagNames
 @param tagNames array of NSString tag names
 @param includeTempTags flag controlling tempTag creation
 @return corresponding PATag objects
 */
- (NSArray*)tagsForNames:(NSArray*)tagNames includeTempTags:(BOOL)includeTempTags;

/**
convenience method:
 calls tagsForName and generates new simpleTags for tags not in PATags
 @param tagName name for the new tag
 @return tag with tag name, either from PATags if exists, otherwise a new simpleTag
 */
- (PATag*)createTagForName:(NSString*)tagName;

/**
convenience method:
 creates multiple tags
 @param tagNames array of NSStrings with tag names
 @return PATag objects for tag names
 */
- (NSArray*)createTagsForNames:(NSArray*)tagNames;

/**
add multiple tags to a file
 @param someTags array with tags
 @param filePaths array with paths to files
 */
- (void)addTags:(NSArray*)someTags toFiles:(NSArray*)filePaths;

/**
convenience method:
 wraps addTags
 @param keywords NSString array with tag names - exisiting tags are used if found
 @param filePaths array with file paths
 @param createSimpleTags flag controlling simpleTag creation for non-existant keywords
 */
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
