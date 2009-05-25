//
//  NNActiveAppSavingWindow.m
//  punakea
//
//  Created by Johannes Hoffart on 25.05.09.
//  Copyright 2009 nudge:nudge. All rights reserved.
//

#import "NNActiveAppSavingWindow.h"


@implementation NNActiveAppSavingWindow

#pragma mark Accessors
- (BOOL)activatesLastActiveApp
{
	return activatesLastActiveApp;
}

- (void)setActivatesLastActiveApp:(BOOL)flag
{
	activatesLastActiveApp = flag;
}

- (void)setLastActiveApp:(ProcessSerialNumber)serialNumber
{
	lastActiveProcess = serialNumber;
}

- (void)activateLastActiveApp
{
	SetFrontProcess(&lastActiveProcess);
}

@end
