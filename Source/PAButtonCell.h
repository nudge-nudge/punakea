//
//  PAButtonCell.h
//  punakea
//
//  Created by Daniel on 07.08.06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "NSBezierPathCategory.h"


typedef enum _PAButtonState
{
	PAOnState = 0,
	PAOffState = 1,
	PAOnHighlightedState = 2,
	PAOffHighlightedState = 3,
	PAOnDisabledState = 4,
	PAOffDisabledState = 5,
	PAOnHoveredState = 6,
	PAOffHoveredState = 7
} PAButtonState;

typedef enum _PAButtonType
{
	PAMomentaryLightButton = 0,
	PASwitchButton = 1
} PAButtonType;

typedef enum _PABezelStyle
{
	PARecessedBezelStyle = 0,
	PATagBezelStyle = 1
} PABezelStyle;


extern NSSize const PADDING_RECESSEDBEZELSTYLE;
extern NSSize const PADDING_TAGBEZELSTYLE;
extern NSSize const MARGIN_TAGBEZELSTYLE;

extern int const FRAME_HEIGHT_MINI;
extern int const FRAME_HEIGHT_SMALL;
extern int const FRAME_HEIGHT_REGULAR;


@interface PAButtonCell : NSActionCell {

	NSString					*title;
	NSMutableAttributedString	*attributedTitle;
	NSMutableDictionary			*images;
	NSMutableDictionary			*tag;
	BOOL						bordered;
	BOOL						hovered;
	BOOL						pressed;
	PAButtonState				state;
	PABezelStyle				bezelStyle;
	NSColor						*bezelColor;
	NSColor						*selectedBezelColor;
	PAButtonType				buttonType;
	int							fontSize;
	
	BOOL						showsCloseIcon;
	SEL							closeAction;	
	BOOL						trackingInsideCloseIcon;
	
	SEL							defaultAction;

}

- (NSString *)title;
- (void)setTitle:(NSString *)aTitle;
- (BOOL)isBordered;
- (void)setBordered:(BOOL)flag;
- (BOOL)isHovered;
- (void)setHovered:(BOOL)flag;
- (BOOL)isPressed;
- (void)setPressed:(BOOL)flag;
- (PAButtonState)state;
- (void)setState:(PAButtonState)aState;

- (PABezelStyle)bezelStyle;
- (void)setBezelStyle:(PABezelStyle)aBezelStyle;
- (NSColor *)bezelColor;	/**< Sets the background color of the rounded rect bezel, if style is PATokenBezelStyle */
- (void)setBezelColor:(NSColor *)color;
- (NSColor *)selectedBezelColor;	/**< Sets the selected background color of the rounded rect bezel, if style is PATokenBezelStyle */
- (void)setSelectedBezelColor:(NSColor *)color;

- (PAButtonType)buttonType;
- (void)setButtonType:(PAButtonType)type;
- (int)fontSize;
- (void)setFontSize:(int)size;	/**< Sets the font size for the title being displayed. Ignored if style is not PATokenBezelStyle. */
- (BOOL)showsCloseIcon;
- (void)setShowsCloseIcon:(BOOL)flag;	/**< Sets flag if a PATagButton shows a close icon */

- (SEL)closeAction;
- (void)setCloseAction:(SEL)action;

@end