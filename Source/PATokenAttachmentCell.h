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

}

@property (readwrite, assign) NSColor *tokenForegroundColor;
@property (readwrite, assign) NSColor *tokenBackgroundColor;

@end
