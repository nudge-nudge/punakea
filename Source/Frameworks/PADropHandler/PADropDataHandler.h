//
//  PAFileHandler.h
//  punakea
//
//  Created by Johannes Hoffart on 10.09.06.
//  Copyright 2006 nudge:nudge. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "NNTagging/PATaggableObject.h"

/**
abstract class for analyzing the data of a single pboardType. is used by PADropHandler.
 */
@interface PADropDataHandler : NSObject {
	NSFileManager *fileManager;
}

/**
this method is the main method of the DropDataHandler.
it should be called with appropriate data by the DropHandler.
 use destinationForNewFile: to get a location for the new file.
 
 must be overwritten - abstract
 
 @param data arbitrary data
 @return taggableObject representing dropped data
 */
- (PATaggableObject*)fileDropData:(id)data;

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
 use this to get a destination for the dropped data,
 for example to create a .webloc file in the right directory
 @param fileName name of the new file
 @return complete path for the new file. save the drop data there
 */ 
- (NSString*)destinationForNewFile:(NSString*)fileName;

/**
may be used in order to check if files are managed
 i.e. they must be put in the managed files area
 if this method returns YES
 */
- (BOOL)shouldManageFiles;

@end
