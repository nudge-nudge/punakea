//
//  PAImageButton.h
//  punakea
//
//  Created by Daniel on 23.03.06.
//  Copyright 2006 nudge:nudge. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PAImageButtonCell.h"


@interface PAImageButton : NSControl 
{
	
	NSToolTipTag		toolTipTag;
	NSString			*toolTip;
	
}

- (void)setButtonType:(PAButtonType)aType;

- (void)setImage:(NSImage *)anImage forState:(PAButtonState)aState;

- (BOOL)isHighlighted;

- (PAButtonState)state;
- (void)setState:(PAButtonState)aState;
- (NSMutableDictionary *)tag;
- (void)setTag:(NSMutableDictionary *)aTag;
- (NSString *)toolTip;
- (void)setToolTip:(NSString *)aToolTip;

@end
