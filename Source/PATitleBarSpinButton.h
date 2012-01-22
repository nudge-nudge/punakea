//
//  PATitleBarSpinButton.h
//  punakea
//
//  Created by Daniel Bär on 18.12.11.
//  Copyright 2011 nudge:nudge. All rights reserved.
//

#import "PATitleBarButton.h"
#import "PATitleBarSpinButtonCell.h"
//#import <QuartzCore/QuartzCore.h>


@interface PATitleBarSpinButton : PATitleBarButton<NSAnimationDelegate>
{
	NSImageView			*imageView;
	BOOL				shouldStop;
}

+ (PATitleBarSpinButton *)titleBarButton;

- (void)drawImage:(NSImage *)anImage;

- (void)start:(id)sender;
- (void)stop:(id)sender;

@end
