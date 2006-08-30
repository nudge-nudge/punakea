//
//  PAThumbnailManager.h
//  punakea
//
//  Created by Daniel on 30.08.06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ThreadWorker.h"


@interface PAThumbnailManager : NSObject {

	NSMutableDictionary			*thumbnails;
	NSMutableArray				*queue;
	int							numberOfThumbsBeingProcessed;
	
	NSImage						*dummyImage;
	
	NSTimer						*timer;

}

+ (PAThumbnailManager *)sharedInstance;

- (void)processQueue;

@end
