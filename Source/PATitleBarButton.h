//
//  PASimpleStatusBarButton.h
//  punakea
//
//  Created by Daniel on 27.04.07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PATitleBarButtonCell.h"


@interface PATitleBarButton : NSControl
{	
	NSString					*identifier;
	
	NSToolTipTag				toolTipTag;
	NSString					*toolTip;
	
	NSTextAlignment				alignment;
	
}

+ (PATitleBarButton *)titleBarButton;	/**< Use this for init */

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
