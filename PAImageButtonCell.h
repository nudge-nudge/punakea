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


@interface PAImageButtonCell : NSButtonCell {

NSMutableDictionary *images;

}

- (void)setImage:(NSImage *)image forState:(PAImageButtonState)state;

@end
