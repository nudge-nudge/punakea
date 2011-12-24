//
//  PATitleBarSpinButtonCell.h
//  punakea
//
//  Created by Daniel Bär on 19.12.11.
//  Copyright 2011 nudge:nudge. All rights reserved.
//

#import "PATitleBarButtonCell.h"


@interface PATitleBarSpinButtonCell : PATitleBarButtonCell
{
	BOOL					spinning;
}

- (void)setSpinning:(BOOL)flag;

@end
