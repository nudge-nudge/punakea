// Copyright (c) 2006-2013 nudge:nudge (Johannes Hoffart & Daniel Bär). All rights reserved.
// 
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import <Cocoa/Cocoa.h>

#import "NNQuery.h"
#import "NNTagStoreManager.h"
#import "NNTagDirectoryWriter.h"
#import "NNAssociationRules.h"
#import "NNAssociationRuleDiscoveryOperation.h"
#import "NNFolderToTagImporter.h"

#include "NNCommonNotifications.h"

@class NNTags;

/**
 Treat this class as a very simple facade to NNTagging.framework with additional helper methods.
 It provides a synchronous way for searching tagged objects, a way to batch create the tag folder
 directory structure, a method to clean up the tag DB...

 NNTag uses this class when executing taggedObjects.
 */
@interface NNTagging : NSObject 
{
	NNAssociationRules *tagRules;
	NSOperationQueue *opQueue;
}

/**
 @return Default instance
 */
+ (NNTagging*)tagging;

/**
 Searches for objects with tag.
 
 @param tag		Tag to search for
 @return		Tagged objects for tag
 */
- (NSArray*)taggedObjectsForTag:(NNTag*)tag;

/**
 Searches for objects with tags.
 
 @param tags	Tags to search for
 @return		Tagged objects for tags
 */
- (NSArray*)taggedObjectsForTags:(NSArray*)tags;

/** 
 Searches for every object tagged by Punakea.
 
 @return All tagged objects
 */
- (NSArray*)allTaggedObjects;

/**
 For a given array of tags, returns the tags that are related to them.
 Tags are related when they are on the same files as the given ones.
 
 @param tags	Tags to get related tags for
 @return		Tags related to given tags
 */
- (NSArray*)relatedTagsForTags:(NSArray*)tags; 

/**
 For a given array of tags, find tags that are strongly associated.
 These tags are good candidates for suggesting additional tags.
 Tags are strongly associated if they often occur together with the given
 tags on the same files/tagged objects
 
 @param tags	Tags to find strongly associated tags for
 @return		Highly associated tags
 */
- (NSArray*)associatedTagsForTags:(NSArray*)tags;

/**
 Use to set the available tag association rules.
 
 @param rules	Tag association rules
 */
- (void)updateTagRules:(NSArray*)rules;

/**
 Deletes all folders in tagsFolder corresponding to Punakea tags.
 Leaves all other folder content intact
 */
- (void)cleanTagsFolder;

/**
 Deletes tagsFolder - use with caution!
 */
- (void)removeTagsFolder;

/** 
 Calls createDirectoryStructureWithPrecedingCleanung:NO
 */
- (void)createDirectoryStructure;

/**
 Batch creates the directory structure representing the
 tags and relations. the directory structure's location is 
 set in the UserDefaults
 
 @param cleanup	If YES, directorey structure will be cleaned before recreating it
 */
- (void)createDirectoryStructureWithPrecedingCleanup:(BOOL)cleanup;

/**
 Looks through all the spotlight comments and adjusts the
 useCount on the tags. Tags not found on any file are deleted
 */
- (void)cleanTagDB;

/**
 Helper method to extract an array of tag names from NNTag objects
 
 @param tags	Array of NNTag objects
 @return		Array of NSString objects (tag names)
 */
- (NSArray*)tagNamesForTags:(NSArray*)tags;

/**
 Helper method to get an array of NNTag objects for tag names
 
 @param tagnames	Array of tag names (as NSString*)
 @return			Array of NNTag objects
 */
- (NSArray*)tagsForTagnames:(NSArray*)tagnames;

@end
