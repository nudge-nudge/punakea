//
//  PAButton.h
//  punakea
//
//  Created by Daniel on 07.08.06.
//  Copyright 2006 nudge:nudge. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PAButtonCell.h"


@interface PAButton : NSControl {

	NSTrackingRectTag		trackingRect;
	int						*tag;

}

- (NSString *)title;
- (void)setTitle:(NSString *)title;
- (BOOL)isBordered;
- (void)setBordered:(BOOL)flag;
- (void)highlight:(BOOL)flag;
- (BOOL)isHighlighted;
- (void)select:(BOOL)flag;
- (BOOL)isSelected;
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
// TODO: - (void)setAlphaComponent:(float)alpha;
- (BOOL)showsCloseIcon;
- (void)setShowsCloseIcon:(BOOL)flag;	/**< Sets flag if a PATagButton shows a close icon */
- (BOOL)showsExcludeIcon;
- (void)setShowsExcludeIcon:(BOOL)flag;	/**< Sets flag if a PATagButton shows an exclude icon */
- (void)toggleExclusion;
- (int)tag;
- (void)setTag:(int)aTag;

- (SEL)action;
- (void)setAction:(SEL)action;
- (SEL)closeAction;
- (void)setCloseAction:(SEL)action;
- (id)target;
- (void)setTarget:(id)target;

@end
