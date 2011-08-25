// Copyright (c) 2006-2011 nudge:nudge (Johannes Hoffart & Daniel Bär). All rights reserved.
// 
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

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

extern NSInteger const FRAME_HEIGHT_MINI;
extern NSInteger const FRAME_HEIGHT_SMALL;
extern NSInteger const FRAME_HEIGHT_REGULAR;


@interface PAButtonCell : NSActionCell {

	NSString					*title;
	NSMutableAttributedString	*attributedTitle;
	NSMutableDictionary			*images;
	NSMutableDictionary			*tag;
	BOOL						bordered;
	BOOL						hovered;
	BOOL						pressed;
	BOOL						selected;
	BOOL						negated;
	PAButtonState				state;
	PABezelStyle				bezelStyle;
	NSColor						*bezelColor;
	NSColor						*selectedBezelColor;
	NSColor						*negatedBezelColor;
	PAButtonType				buttonType;
	NSInteger							fontSize;
	
	BOOL						showsCloseIcon;
	BOOL						showsExcludeIcon;
	BOOL						excluded;
	SEL							closeAction;	
	BOOL						trackingInsideCloseIcon;
	BOOL						trackingInsideExcludeIcon;
	
	SEL							defaultAction;

}

- (PABezelStyle)bezelStyle;
- (void)setBezelStyle:(PABezelStyle)aBezelStyle;
- (NSColor *)bezelColor;	/**< Sets the background color of the rounded rect bezel, if style is PATokenBezelStyle */
- (void)setBezelColor:(NSColor *)color;
- (NSColor *)selectedBezelColor;	/**< Sets the selected background color of the rounded rect bezel, if style is PATokenBezelStyle */
- (void)setSelectedBezelColor:(NSColor *)color;
- (NSColor *)negatedBezelColor;		/**< Sets the negated background color of the rounded rect bezel, if style is PATokenBezelStyle */
- (void)setNegatedBezelColor:(NSColor *)color;

- (PAButtonType)buttonType;
- (void)setButtonType:(PAButtonType)type;
- (NSInteger)fontSize;
- (void)setFontSize:(NSInteger)size;	/**< Sets the font size for the title being displayed. Ignored if style is not PATokenBezelStyle. */
- (BOOL)showsCloseIcon;
- (void)setShowsCloseIcon:(BOOL)flag;	/**< Sets flag if a PATagButton shows a close icon */
- (BOOL)showsExcludeIcon;
- (void)setShowsExcludeIcon:(BOOL)flag;	/**< Sets flag if a PATagButton shows an exclude icon */
- (void)toggleExclusion;

- (SEL)closeAction;
- (void)setCloseAction:(SEL)action;

- (NSMutableAttributedString *)attributedTitle;

- (NSString *)title;
- (void)setTitle:(NSString *)aTitle;
- (BOOL)isBordered;
- (void)setBordered:(BOOL)flag;
- (BOOL)isHovered;
- (void)setHovered:(BOOL)flag;
- (BOOL)isPressed;
- (void)setPressed:(BOOL)flag;
- (void)select:(BOOL)flag;
- (BOOL)isSelected;
- (void)setNegated:(BOOL)flag;
- (BOOL)isNegated;
- (PAButtonState)state;
- (void)setState:(PAButtonState)aState;

@end
