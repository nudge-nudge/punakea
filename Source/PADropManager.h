//
//  PADropManager.h
//  punakea
//
//  Created by Johannes Hoffart on 08.09.06.
//  Copyright 2006 nudge:nudge. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PADropHandler/PADropHandler.h"

/**
this singleton class handles all drops from the outside.
 it knows which file types are handled and what dragoperations will be performed on a specific file.
 handleDrop: creates and/or moves the files according to the manage files preference and returns the new files as NNFile array.
 tags have to be written to the files after drop
 */
 
@interface PADropManager : NSObject {
	
	NSMutableArray					*dropHandlers;
	
	BOOL							alternateState;
	
}

/**
get the singleton instance
 @return singleton instance of PADropManager
 */
+ (PADropManager*)sharedInstance;

- (void)registerDropHandler:(PADropHandler*)handler;
- (void)removeDropHandler:(PADropHandler*)handler;

/**
returns an array of strings with all pboardTypes currently
 handled by the dropManager
 @return array of strings with handled pboard types
 */
- (NSArray*)handledPboardTypes;

/**
handles drop and returns file array for drop
 @param pasteboard drop pasteboard
 @return new files for drop data
 */
- (NSArray*)handleDrop:(NSPasteboard*)pasteboard;

/**
determines the NSDragOperation which will be performed on the
 passed pasteboard
 @param pasteboard pasteboard to check
 @return NSDragOperation which will be performed on drop
 */
- (NSDragOperation)performedDragOperation:(NSPasteboard*)pasteboard;

- (BOOL)alternateState;
- (void)setAlternateState:(BOOL)flag;

@end
