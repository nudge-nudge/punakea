//
//  PATagSave.h
//  punakea
//
//  Created by Johannes Hoffart on 02.01.07.
//  Copyright 2007 nudge:nudge. All rights reserved.
//

#include <unistd.h>

#import <Cocoa/Cocoa.h>
#import "PAThreadSafeQueue.h"
#import "PATaggableObject.h"
#import "PATags.h"

extern int const MAX_RETRY_COUNT;
extern useconds_t const PATAGSAVE_CYCLETIME;

/**
waits for taggable objects to post update notifications
 runs a background thread to save the tags to spotligh comment
 */
@interface PATagSave : NSObject {
	PAThreadSafeQueue *queue;
}

@end
