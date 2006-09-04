//
//  PAFileManager.h
//  punakea
//
//  Created by Johannes Hoffart on 04.09.06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface PAFileManager : NSObject {
	BOOL manageFiles;
	
	NSFileManager *fileManager;
}

/**
if file management is active, the given file will be moved to an internal folder
 the new location is returned
 @param filePath path to file
 @return path to new location
 */
- (NSString*)handleFile:(NSString*)filePath;

/**
convenience method, calls handleFile:
 */
- (NSArray*)handleFiles:(NSArray*)filePaths;

@end
