//
//  PAImageButtonCell.h
//  punakea
//
//  Created by Daniel on 21.03.06.
//  Copyright 2006 nudge:nudge. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PAButtonCell.h"

@interface PAImageButtonCell : NSButtonCell {

	NSMutableDictionary *images;
	PAButtonState state;
	PAButtonState previousState;
	PAButtonType type;
	NSMutableDictionary *tag;
	
}

- (id)initImageCell:(NSImage *)anImage;
- (void)setButtonType:(PAButtonType)aType;
- (void)setImage:(NSImage *)anImage forState:(PAButtonState)aState;

- (BOOL)isHighlighted;
- (void)setHighlighted:(BOOL)flag;
- (PAButtonState)state;
- (void)setState:(PAButtonState)aState;
- (NSMutableDictionary *)tag;
- (void)setTag:(NSMutableDictionary *)aTag;

@end
