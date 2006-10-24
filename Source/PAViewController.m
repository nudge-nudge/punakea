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
	[view setNextResponder:self];
}

- (void)dealloc
{
	[view release];
	[super dealloc];
}

#pragma mark accessors
- (NSView*)view
{
	return view;
}

- (void)setMainView:(NSView*)aView
{
	[aView retain];
	[view release];
	view = aView;
}

@end
