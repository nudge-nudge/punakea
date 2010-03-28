//
//  PATokenAttachmentCell.m
//  PATokenField
//
//  Created by Daniel on 27.03.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "PATokenAttachmentCell.h"


@implementation PATokenAttachmentCell

@synthesize tokenForegroundColor, tokenBackgroundColor;

- (id)tokenForegroundColor
{
	return tokenForegroundColor ? tokenForegroundColor : [super tokenForegroundColor];
}

- (id)tokenBackgroundColor
{
	return tokenBackgroundColor ? tokenBackgroundColor : [super tokenBackgroundColor];
}

@end
