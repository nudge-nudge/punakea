//
//  PAFileHandler.h
//  punakea
//
//  Created by Johannes Hoffart on 10.09.06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PAFile.h"

/**
abstract class
 */
@interface PADropDataHandler : NSObject {
	BOOL manageFiles;
	
	NSFileManager *fileManager;
}

/**
if file management is active, the given file will be moved to an internal folder
 the new location is returned
 must be overwritten - abstract
 @param filePath path to file
 @return path to new location
 */
- (PAFile*)fileDropData:(id)data;

/**
convenience method, calls handleFile:
 */
- (NSArray*)fileDropDataObjects:(NSArray*)dataObjects;

/**
returns the performed NSDragOperation, depending on fileManager
 must be overwritten - abstract
 @return NSDragOperation which will be performed by this dropDataHandler
 */
- (NSDragOperation)performedDragOperation;

/**
helper methods
 */
- (PAFile*)destinationForNewFile:(NSString*)fileName;
- (NSString*)pathForFiles;

@end
