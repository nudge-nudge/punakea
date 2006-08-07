//
//  PAButton.h
//  punakea
//
//  Created by Daniel on 07.08.06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PAButtonCell.h"


@interface PAButton : NSControl {

	NSTrackingRectTag		trackingRectTag;
	NSRect					trackingRect;
	int						*tag;

}

- (NSString *)title;
- (void)setTitle:(NSString *)title;
- (BOOL)isBordered;
- (void)setBordered:(BOOL)flag;
- (PAButtonState)state;
- (void)setState:(PAButtonState)aState;
- (PABezelType)bezelType;
- (void)setBezelType:(PABezelType)bezelType;
- (int)tag;
- (void)setTag:(int)aTag;
- (SEL)action;
- (void)setAction:(SEL)action;
- (id)target;
- (void)setTarget:(id)target;

@end
