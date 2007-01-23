//
//  PAThumbnailManager.h
//  punakea
//
//  Created by Daniel on 30.08.06.
//  Copyright 2006 nudge:nudge. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PAThumbnailItem.h"
#import "NNTagging/NNThreadSafeQueue.h"


extern NSString * const PAThumbnailManagerDidFinishGeneratingItemNotification;

@interface PAThumbnailManager : NSObject {

	NSMutableDictionary			*icons;	
	NSMutableDictionary			*thumbnails;
	
	NNThreadSafeQueue			*queue;
	NSMutableArray				*stack;
	
	NSImage						*dummyImageThumbnail;
	NSImage						*dummyImageIcon;
	
	BOOL						delayNextNotification;
	
}

+ (PAThumbnailManager *)sharedInstance;

- (NSImage *)thumbnailWithContentsOfFile:(NSString *)filename inView:(NSView *)aView frame:(NSRect)aFrame;
- (NSImage *)iconForFile:(NSString *)filename inView:(NSView *)aView frame:(NSRect)aFrame;
- (void)processQueue;
- (void)generateThumbnailFromFile:(PAThumbnailItem *)thumbnailItem;
- (void)generateIconForFile:(PAThumbnailItem *)thumbnailItem;
- (void)removeAllQueuedItems;

@end
