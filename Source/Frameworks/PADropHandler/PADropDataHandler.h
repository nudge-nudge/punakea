//
//  PAFileHandler.h
//  punakea
//
//  Created by Johannes Hoffart on 10.09.06.
//  Copyright 2006 nudge:nudge. All rights reserved.
//

#import <Cocoa/Cocoa.h>

/**
abstract class for analyzing the data of a single pboardType. is used by PADropHandler.
 */
@interface PADropDataHandler : NSObject {
	BOOL manageFiles;
	
	NSFileManager *fileManager;
}

/**
this method is the main method of the DropDataHandler.
it should be called with appropriate data by the DropHandler.
 use destinationForNewFile: to get a location for the new file.
 
 must be overwritten - abstract
 
 @param data pdata to file
 @return file with new location
 */
- (NSString*)fileDropData:(id)data;

/**
convenience method, calls handleFile:
 */
- (NSArray*)fileDropDataObjects:(NSArray*)dataObjects;

/**
returns the performed NSDragOperation, depending on fileManager.
 use the BOOL manageFiles to determine if files should be managed.
 
 must be overwritten - abstract
 
 @return NSDragOperation which will be performed by this dropDataHandler
 */
- (NSDragOperation)performedDragOperation;

/**
helper method

returns the destination for a file to be written
 use this to get a destination for the dropped data, it
 will consider user settings of managing files
 @param fileName name of the new file
 @return complete path for the new file. save the drop data there
 */ 
- (NSString*)destinationForNewFile:(NSString*)fileName;


@end
