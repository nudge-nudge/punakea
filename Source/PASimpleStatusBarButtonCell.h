//
//  PASimpleStatusBarButtonCell.h
//  punakea
//
//  Created by Daniel on 27.04.07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface PASimpleStatusBarButtonCell : NSActionCell {

	NSImage				*image;
	NSImage				*alternateImage;			/**< Image that will be displayed if user holds down the option key */
	
}

- (NSImage *)image;
- (void)setImage:(NSImage *)anImage;
- (NSImage *)alternateImage;
- (void)setAlternateImage:(NSImage *)anImage;

@end
