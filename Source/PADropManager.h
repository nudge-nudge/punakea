//
//  PADropManager.h
//  punakea
//
//  Created by Johannes Hoffart on 08.09.06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PADropHandler.h"
#import "PAFileManager.h"
#import "PAFilenamesDropHandler.h"

@interface PADropManager : NSObject {
	NSMutableArray *dropHandlers;
	
	PAFileManager *fileManager;
}

- (void)registerDropHandler:(PADropHandler*)handler;
- (void)removeDropHandler:(PADropHandler*)handler;

- (NSArray*)handledPboardTypes;

/**
handles drop and returns file array for drop
 @param pasteboard drop pasteboard
 @return dictionary with keys: 
	"files" resulting files
	"icon" NSImage representing these files
 */
- (NSDictionary*)handleDrop:(NSPasteboard*)pasteboard;

@end
