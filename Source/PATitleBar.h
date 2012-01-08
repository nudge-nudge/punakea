//
//  PATitleBar.h
//  punakea
//
//  Created by Daniel Bär on 04.12.11.
//  Copyright 2011 nudge:nudge. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PAAppStoreWindow.h"
#import "PATitleBarButton.h"
#import "PATitleBarSearchButton.h"
#import "PATitleBarSpinButton.h"

@class PABrowserWindow;

extern NSSize const TITLEBAR_BUTTON_MARGIN;


typedef enum
{
	//PATitleBarButtonLeftAlignment,
	PATitleBarButtonRightAlignment,
	//PATitleBarButtonCenteredAlignment
} PATitleBarButtonAlignment;


@interface PATitleBar : NSView
{
	
}

- (NSBezierPath*)clippingPathWithRect:(NSRect)aRect cornerRadius:(CGFloat)radius;

- (void)addSubview:(NSView *)aView positioned:(PATitleBarButtonAlignment)place;
- (PATitleBarButton *)buttonWithIdentifier:(NSString *)anIdentifier;

- (void)performClickOnButtonWithIdentifier:(NSString *)anIdentifier;

@end
