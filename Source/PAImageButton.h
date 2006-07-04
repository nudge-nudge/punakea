//
//  PAImageButton.h
//  punakea
//
//  Created by Daniel on 23.03.06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PAImageButtonCell.h"


@interface PAImageButton : NSControl 
{
	NSMutableDictionary *tag;
}

- (void)setButtonType:(PAImageButtonType)aType;
- (void)setState:(PAImageButtonState)aState;
- (void)setImage:(NSImage *)anImage forState:(PAImageButtonState)aState;

- (BOOL)isHighlighted;

- (PAImageButtonState)state;
- (void)setState:(PAImageButtonState)aState;
- (NSMutableDictionary *)tag;
- (void)setTag:(NSMutableDictionary *)aTag;

@end
