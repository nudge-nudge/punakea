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
	PATokenBezelStyle = 1
} PABezelStyle;


extern NSSize const PADDING_RECESSEDBEZELSTYLE;
extern NSSize const PADDING_TOKENBEZELSTYLE;

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
	NSColor						*bezelBorderColor;
	PAButtonType				buttonType;
	int							fontSize;
	

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
- (NSColor *)bezelColor;
- (void)setBezelColor:(NSColor *)aBezelColor;
- (NSColor *)bezelBorderColor;
- (void)setBezelBorderColor:(NSColor *)aBorderColor;

- (PAButtonType)buttonType;
- (void)setButtonType:(PAButtonType)type;
- (int)fontSize;
- (void)setFontSize:(int)aFontSize;

@end
