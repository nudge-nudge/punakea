//
//  PAThumbnailItem.h
//  punakea
//
//  Created by Daniel on 31.08.06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


typedef enum
{
	PAItemTypeThumbnail = 0,
	PAItemTypeIcon = 1
} PAThumbnailItemType;


@interface PAThumbnailItem : NSObject {

	NSString				*filename;
	NSView					*view;
	NSRect					frame;
	PAThumbnailItemType		type;

}

- (NSString *)filename;
- (NSView *)view;
- (NSRect)frame;
- (PAThumbnailItemType)type;

@end
