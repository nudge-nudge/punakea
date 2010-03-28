//
//  PATokenAttachmentCell.h
//  PATokenField
//
//  Created by Daniel on 27.03.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "NSTokenAttachmentCell.h"


@interface PATokenAttachmentCell : NSTokenAttachmentCell {
	
	NSColor *tokenForegroundColor;
	NSColor *tokenBackgroundColor;
	
}

- (void)setTokenForegroundColor:(NSColor *)color;
- (void)setTokenBackgroundColor:(NSColor *)color;

@end
