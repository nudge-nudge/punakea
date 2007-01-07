//
//  PATagSave.h
//  punakea
//
//  Created by Johannes Hoffart on 02.01.07.
//  Copyright 2007 nudge:nudge. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PAThreadSafeQueue.h"
#import "PATagging/PATaggableObject.h"
#import "PATagging/PATags.h"

/**
waits for taggable objects to post update notifications
 runs a background thread to save the tags to spotligh comment
 
 TODO interrupt quit until queue is empty!
 TODO dropping 
 TODO file managing
 TODO retry on fail
 */
@interface PATagSave : NSObject {
	PAThreadSafeQueue *queue;
}

@end
