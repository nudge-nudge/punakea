//
//  TaggerInterface.h
//  punakea
//
//  Created by Johannes Hoffart on 05.02.06.
//  Copyright 2006 nudge:nudge. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <CoreServices/CoreServices.h>
#import <Carbon/Carbon.h>
#import <ApplicationServices/ApplicationServices.h>
#import "Matador.h"
#import "PATags.h"
#import "PASimpleTagFactory.h"
#import "PATempTag.h"
#import "PAQuery.h"
#import "PAFile.h"

extern NSString * const TAGGER_OPEN_COMMENT;
extern NSString * const TAGGER_CLOSE_COMMENT;

/**
singleton class for working with finder spotlight comment (our simpleTags)
 */
@interface PATagger : NSObject {
	PASimpleTagFactory *simpleTagFactory;
	PATags *tags;
	
	NSAppleScript *finderCommentScript;
	
	NSMutableDictionary *fileCache;
}

/**
get the singleton instance
 @return singleton instance of PATagger
 */
+ (PATagger*)sharedInstance;

/**
convenience method:
 calls tagsOnFiles: with file as array content
 @param file file to fetch tags for
 @return array of PATags
 */
- (NSArray*)tagsOnFile:(PAFile*)file;

/**
convenience method:
calls tagsOnFiles: with includeTempTags:YES
 @param files files to fetch tags for
 @return array of PATags
 */
- (NSArray*)tagsOnFiles:(NSArray*)files;

/**
returns an array of PATags, corresponding to the kMDItemKeywords on the files
 creates PATempTags for tags not in PATags
 @param files files to fetch tags for
 @param includeTempTags flag controlling tempTag creation
 @return array of PATags
 */
- (NSArray*)tagsOnFiles:(NSArray*)files includeTempTags:(BOOL)includeTempTags;

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
 @param files array with paths to files
 */
- (void)addTags:(NSArray*)someTags toFiles:(NSArray*)files;

/**
convenience method:
 wraps addTags
 @param keywords NSString array with tag names - exisiting tags are used if found
 @param files array with file paths
 @param createSimpleTags flag controlling simpleTag creation for non-existant keywords
 */
- (void)addKeywords:(NSArray*)keywords toFiles:(NSArray*)files createSimpleTags:(BOOL)createSimpleTags;

/**
get keywords as NSString array for file at path
 @param file file for which to get the tags
 @return array with NSStrings corresponding to the kMDItemKeywords on the file
 */
- (NSArray*)keywordsForFile:(PAFile*)file;

/**
convenience method:
 remove tags from all files
 @param tag tag to remove
 */
- (void)removeTag:(PATag*)tag;

/**
removes the tag from files
 @param tag tag to remove
 @param files files to remove tags from (array of path strings)
 */
- (void)removeTag:(PATag*)tag fromFiles:(NSArray*)files;

/**
removes the tags from files
 @param tags tag array with simpleTags to remove
 @param files files to remove tags from (array of path strings)
 */
- (void)removeTags:(NSArray*)tags fromFiles:(NSArray*)files;

/**
convenience method:
 rename tag on all files
 @param name tag to renam
 @param newTagName new tag
 */
- (void)renameTag:(NSString*)tagName toTag:(NSString*)newTagName;

/**
renames the tag on files
 @param tagName tag to rename
 @param newTagName new name
 @param files files to rename in (array of path strings)
 */
- (void)renameTag:(NSString*)tagName toTag:(NSString*)newTagName onFiles:(NSArray*)files;

/**
removes all tags from file
 @param file file to remove tags from
 */
- (void)removeAllTagsFromFile:(PAFile *)file;

#pragma mark accessors
- (PATags*)tags;
- (void)setTags:(PATags*)allTags;

@end
