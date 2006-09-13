//
//  PAThumbnailManager.h
//  punakea
//
//  Created by Daniel on 30.08.06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PAThumbnailItem.h"
#import "ThreadWorker.h"


@interface PAThumbnailManager : NSObject {

	NSMutableDictionary			*icons;	
	NSMutableDictionary			*thumbnails;
	
	NSMutableArray				*queue;
	NSMutableArray				*stack;
	int							numberOfThumbsBeingProcessed;
	
	NSImage						*dummyImageThumbnail;
	NSImage						*dummyImageIcon;
	
	NSTimer						*timer;
	BOOL						processingQueue;

}

+ (PAThumbnailManager *)sharedInstance;

- (void)processQueue;

@end
