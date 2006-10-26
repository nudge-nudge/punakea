//
//  PAFile.h
//  punakea
//
//  Created by Johannes Hoffart on 15.09.06.
//  Copyright 2006 nudge:nudge. All rights reserved.
//

#import <Cocoa/Cocoa.h>

/**
represents a file. uses NSString, NSWorkspace and NSFilemanager stuff internally. Please use this for all methods which
 access files
 */
@interface PAFile : NSObject {
	NSString *path; /**< full path including file.extension */
	
	NSWorkspace *workspace;
	NSFileManager *fileManager;
}

- (id)initWithPath:(NSString*)aPath;
- (id)initWithFileURL:(NSURL*)url;

+ (PAFile*)fileWithPath:(NSString*)aPath;
+ (NSArray*)filesWithFilepaths:(NSArray*)filepaths;
+ (PAFile*)fileWithFileURL:(NSURL*)url;

- (NSString*)path; /**< full path including file.extension */
- (NSString*)standardizedPath; /**< standardized path */
- (NSString*)name; /**< file name including extension */
- (NSString*)nameWithoutExtension; /**< file name without extension */
- (NSString*)extension; /**< file extension */
- (NSString*)directory; /**< directory path the file is located in */
- (BOOL)isDirectory; /**< checks if file is directory */
- (NSImage*)icon; /**< icon representing file */

@end
