//
//  PARelatedTags.h
//  punakea
//
//  Created by Johannes Hoffart on 17.02.06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PATaggerInterface.h"

@interface PARelatedTags : NSObject {
	NSMutableArray *tags;
	NSNotificationCenter *nf;
}

@end
