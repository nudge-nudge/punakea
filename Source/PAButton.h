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

- (void)highlight:(BOOL)flag;

- (NSString *)title;
- (void)setTitle:(NSString *)title;
- (BOOL)isBordered;
- (void)setBordered:(BOOL)flag;
- (PAButtonState)state;
- (void)setState:(PAButtonState)aState;

- (PABezelStyle)bezelStyle;
- (void)setBezelStyle:(PABezelStyle)bezelStyle;
- (NSColor *)bezelColor;	/**< Sets the background color of the rounded rect bezel, if style is PATokenBezelStyle */
- (void)setBezelColor:(NSColor *)color;
- (NSColor *)selectedBezelColor;	/**< Sets the selected background color of the rounded rect bezel, if style is PATokenBezelStyle */
- (void)setSelectedBezelColor:(NSColor *)color;

- (PAButtonType)buttonType;
- (void)setButtonType:(PAButtonType)buttonType;
- (int)fontSize;
- (void)setFontSize:(int)size;	/**< Sets the font size for the title being displayed. Ignored if style is not PATokenBezelStyle. */
// TODO: - (void)setAlpha:(float)alpha;

- (int)tag;
- (void)setTag:(int)aTag;

- (SEL)action;
- (void)setAction:(SEL)action;
- (id)target;
- (void)setTarget:(id)target;

@end
