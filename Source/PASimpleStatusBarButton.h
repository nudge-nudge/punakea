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
	
	NSToolTipTag		toolTipTag;
	NSString			*toolTip;
	
}

+ (PASimpleStatusBarButton *)statusBarButton;	/**< Use this for init */

- (void)setImage:(NSImage *)anImage;
- (void)setAlternateImage:(NSImage *)anImage;

- (NSString *)toolTip;
- (void)setToolTip:(NSString *)aToolTip;
- (BOOL)alternateState;
- (void)setAlternateState:(BOOL)flag;

@end
