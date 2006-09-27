//
//  PAViewController.m
//  punakea
//
//  Created by Johannes Hoffart on 13.07.06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "PAViewController.h"


@implementation PAViewController

- (void)awakeFromNib
{
	[mainView setNextResponder:self];
}

- (void)dealloc
{
	[mainView release];
	[super dealloc];
}

#pragma mark accessors
- (NSView*)mainView
{
	return mainView;
}

- (void)setMainView:(NSView*)aView
{
	[aView retain];
	[mainView release];
	mainView = aView;
}

@end
