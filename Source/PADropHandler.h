//
//  PADropHandler.h
//  punakea
//
//  Created by Johannes Hoffart on 08.09.06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PADropDataHandler.h"

/**
abstract class for handling drops
 */
@interface PADropHandler : NSObject {
	NSString *pboardType;
	id content;
	PADropDataHandler *dataHandler;
}

- (NSArray*)pboardTypes;

- (NSArray*)contentFiles;
- (void)setContent:(id)aContent;

- (BOOL)handleDrop:(NSPasteboard*)pasteboard; /**< must be overwritten */
- (NSImage*)iconForContent; /**< must be overwritten */

@end
