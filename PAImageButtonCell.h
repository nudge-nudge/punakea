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
	PAOnDisabledState = 4,
	PAOffDisabledState = 5
} PAImageButtonState;

// TODO: enum for button type (push button, toggle button, ...)


@interface PAImageButtonCell : NSActionCell {

NSMutableDictionary *images;

}

- (void)setImage:(NSImage *)image forState:(id)state;
- (void)drawInteriorWithFrame:(NSRect)cellFrame inView:(NSView *)controlView;

@end
