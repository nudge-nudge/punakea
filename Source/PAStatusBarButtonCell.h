//
//  PASimpleStatusBarButtonCell.h
//  punakea
//
//  Created by Daniel on 27.04.07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


extern NSSize const STATUSBAR_BUTTON_PADDING;
extern NSSize const STATUSBAR_BUTTON_MIN_SIZE;


@interface PAStatusBarButtonCell : NSActionCell {

	NSButtonType		buttonType;
	
	NSImage				*image;
	NSImage				*alternateImage;			/**< Image that will be displayed if user holds down the option key */
	
	BOOL				alternateState;
	
}

- (NSButtonType)buttonType;
- (void)setButtonType:(NSButtonType)aType;

- (NSImage *)image;
- (void)setImage:(NSImage *)anImage;
- (NSImage *)alternateImage;
- (void)setAlternateImage:(NSImage *)anImage;

- (BOOL)alternateState;
- (void)setAlternateState:(BOOL)flag;

@end
