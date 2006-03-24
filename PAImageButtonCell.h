//
//  PAImageButtonCell.h
//  punakea
//
//  Created by Daniel on 21.03.06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


typedef enum _PAImageButtonState
{
	PAOnState = 0,
	PAOffState = 1,
	PAOnPressedState = 2,
	PAOffPressedState = 3,
	PAOnHighlightedState = 4,
	PAOffHighlightedState = 5,
	PAOnDisabledState = 6,
	PAOffDisabledState = 7
} PAImageButtonState;

typedef enum _PAImageButtonType
{
	PAMomentaryLightButton = 0,
	PASwitchButton = 1
} PAImageButtonType;


@interface PAImageButtonCell : NSActionCell {

NSMutableDictionary *images;
PAImageButtonState state;
PAImageButtonType type;
//NSView *controlView;

}

- (id)initImageCell:(NSImage *)anImage;
- (void)setImage:(NSImage *)anImage forState:(PAImageButtonState)aState;
- (void)drawInteriorWithFrame:(NSRect)cellFrame inView:(NSView *)controlView;

@end
