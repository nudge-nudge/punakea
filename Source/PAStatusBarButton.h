//
//  PASimpleStatusBarButton.h
//  punakea
//
//  Created by Daniel on 27.04.07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PAStatusBarButtonCell.h"


@interface PAStatusBarButton : NSControl {
	
	NSString			*identifier;
	
	NSToolTipTag		toolTipTag;
	NSString			*toolTip;
	
}

+ (PAStatusBarButton *)statusBarButton;	/**< Use this for init */

- (NSString *)identifier;
- (void)setIdentifier:(NSString *)anIdentifier;

- (NSButtonType)buttonType;
- (void)setButtonType:(NSButtonType)aType;

- (void)setImage:(NSImage *)anImage;
- (void)setAlternateImage:(NSImage *)anImage;

- (NSString *)toolTip;
- (void)setToolTip:(NSString *)aToolTip;
- (BOOL)alternateState;
- (void)setAlternateState:(BOOL)flag;

@end
