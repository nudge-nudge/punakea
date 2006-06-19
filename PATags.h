//
//  PATags.h
//  punakea
//
//  Created by Johannes Hoffart on 18.04.06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PATagger.h"
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

/**
creates a query for the given tags
 @param someTags tags for which to create the query
 @return query configured to search for tags
 */
- (NSMetadataQuery*)queryForTags:(NSMutableArray*)someTags;

@end