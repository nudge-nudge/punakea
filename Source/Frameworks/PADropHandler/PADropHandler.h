//
//  PADropHandler.h
//  punakea
//
//  Created by Johannes Hoffart on 08.09.06.
//  Copyright 2006 nudge:nudge. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PADropDataHandler.h"

/**
abstract class for handling drops of a single pboardType
 */
@interface PADropHandler : NSObject {
	NSString *pboardType;
	PADropDataHandler *dataHandler;
}

- (NSString*)pboardType;

/**
must be overwritten
 
checks pasteboard if it can be handled
 @param pasteboard pasteboard to check
 @return YES if it is handled, NO if not
 */
- (BOOL)willHandleDrop:(NSPasteboard*)pasteboard;

/**
must be overwritten
 
handles the pasteboard, returns content as array of PATaggableObjects.
 uses dropDataHandler to get a file for the pasteboard data
 @param pasteboard pasteboard to handle
 @return array of PATaggableObjects
 */
- (NSArray*)handleDrop:(NSPasteboard*)pasteboard;

/**
must be overwritten
 
 check which NSDragOperation will be performed on pasteboard
 @param pasteboard pasteboard to check
 @return NSDragOperation which will be performed on pasteboard
 */
- (NSDragOperation)performedDragOperation:(NSPasteboard*)pasteboard; 

@end
