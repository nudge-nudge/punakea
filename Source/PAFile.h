//
//  PAFile.h
//  punakea
//
//  Created by Johannes Hoffart on 15.09.06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface PAFile : NSObject {
	NSString *path;
	
	NSWorkspace *workspace;
	NSFileManager *fileManager;
}

- (id)initWithPath:(NSString*)aPath;
- (id)initWithFileURL:(NSURL*)url;

+ (PAFile*)fileWithPath:(NSString*)aPath;
+ (NSArray*)filesWithFilepaths:(NSArray*)filepaths;
+ (PAFile*)fileWithFileURL:(NSURL*)url;

- (NSString*)path; /**< full path including file.extension */
- (NSString*)name;
- (NSString*)nameWithoutExtension;
- (NSString*)extension;
- (NSString*)directory;
- (NSImage*)icon;

@end
