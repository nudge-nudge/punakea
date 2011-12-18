//
//  PATitleBarButtonCell.h
//  punakea
//
//  Created by Daniel Bär on 04.12.11.
//  Copyright 2011 nudge:nudge. All rights reserved.
//

#import <AppKit/AppKit.h>

@interface PATitleBarButtonCell : NSActionCell
{	
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
