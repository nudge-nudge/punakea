//
//  PATableViewDropController.h
//  punakea
//
//  Created by Johannes Hoffart on 07.05.06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PASimpleTag.h"
#import "PATagger.h"

@interface PATableViewDropController : NSObject {
	NSArrayController *tags;
}

- (id)initWithTags:(NSArrayController*)usedTags;

@end
