//
//  PATokenAttachmentCell.m
//  PATokenField
//
//  Created by Daniel on 27.03.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "PATokenAttachmentCell.h"


@implementation PATokenAttachmentCell

- (id)tokenForegroundColor
{
	if (!tokenForegroundColor)
	{	
		// If there's no color set, use the system behavior. This call also cares
		// for altering the color on hover and selection.
		return [super tokenForegroundColor];
	}
	else
	{
		if (_tacFlags._selected)
			return tokenBackgroundColor;							// Use background color for selection
		else if ([self isHighlighted])
			return [tokenForegroundColor shadowWithLevel:0.05];		// Darken the foreground color on hover
		else 
			return tokenForegroundColor;
	}
}

- (id)tokenBackgroundColor
{
	return tokenBackgroundColor ? tokenBackgroundColor : [super tokenBackgroundColor];
}

- (void)setTokenForegroundColor:(NSColor *)color
{
	if (tokenForegroundColor) [tokenForegroundColor release];
	tokenForegroundColor = [color retain];
}

- (void)setTokenBackgroundColor:(NSColor *)color
{
	if (tokenBackgroundColor) [tokenBackgroundColor release];
	tokenBackgroundColor = [color retain];
}

@end
