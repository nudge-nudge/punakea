//
//  PAFile.h
//  punakea
//
//  Created by Johannes Hoffart on 15.09.06.
//  Copyright 2006 nudge:nudge. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PATaggableObject.h"
#import "NSFileManager+PAExtensions.h"

extern NSString * const TAGGER_OPEN_COMMENT;
extern NSString * const TAGGER_CLOSE_COMMENT;

/**
represents a file. uses NSString, NSWorkspace and NSFilemanager stuff internally. Please use this for all methods which
 access files
 */
@interface PAFile : PATaggableObject {
	
	NSString				*path; /**< full path including file.extension */
	
	NSString				*album;
	NSString				*authors;
	
	NSWorkspace				*workspace;
	NSFileManager			*fileManager;
}

- (id)initWithPath:(NSString*)aPath;
- (id)initWithFileURL:(NSURL*)url;
- (id)initWithNSMetadataItem:(NSMetadataItem*)metadataItem;

// convenience initializers
+ (PAFile*)fileWithPath:(NSString*)aPath;
+ (NSArray*)filesWithFilepaths:(NSArray*)filepaths;
+ (PAFile*)fileWithFileURL:(NSURL*)url;
+ (PAFile*)fileWithNSMetadataItem:(NSMetadataItem*)metadataItem;

// file wrapping stuff
- (NSString*)path; /**< full path including file.extension */
- (NSString*)standardizedPath; /**< standardized path */
- (NSString*)name; /**< file name including extension */
- (NSString*)displayNameWithoutExtension; /**< file name without extension */
- (NSString*)extension; /**< file extension */
- (NSString*)directory; /**< directory path the file is located in */
- (BOOL)isDirectory; /**< checks if file is directory */
- (NSImage*)icon; /**< icon representing file */

// These accessors will be moved into some more sophisticated classes later
- (NSString *)album;
- (void)setAlbum:(NSString *)anAlbum;
- (NSString *)authors;
- (void)setAuthors:(NSString *)theAuthors;

@end
