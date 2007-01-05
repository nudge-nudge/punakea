//
//  PASidebarTableViewDropController.h
//  punakea
//
//  Created by Johannes Hoffart on 07.05.06.
//  Copyright 2006 nudge:nudge. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PATagging/PASimpleTag.h"
#import "PADropManager.h"

@interface PASidebarTableViewDropController : NSObject {
	NSArrayController *tags;
	PADropManager *dropManager;
}

- (id)initWithTags:(NSArrayController*)usedTags;

@end
