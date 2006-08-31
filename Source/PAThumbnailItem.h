//
//  PAThumbnailItem.h
//  punakea
//
//  Created by Daniel on 31.08.06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface PAThumbnailItem : NSObject {

	NSString			*filename;
	NSView				*view;
	NSRect				frame;

}

- (NSString *)filename;
- (NSView *)view;
- (NSRect)frame;

@end
