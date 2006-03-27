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
	PAOnHighlightedState = 2,
	PAOffHighlightedState = 3
	//PAOnDisabledState = 4,
	//PAOffDisabledState = 5
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

}

- (id)initImageCell:(NSImage *)anImage;
- (void)setButtonType:(PAImageButtonType)aType;
- (void)setImage:(NSImage *)anImage forState:(PAImageButtonState)aState;

- (BOOL)isHighlighted;
- (void)setHighlighted:(BOOL)flag;
- (PAImageButtonState)state;
- (void)setState:(PAImageButtonState)aState;
@end
