//
//  PAViewController.m
//  punakea
//
//  Created by Johannes Hoffart on 13.07.06.
//  Copyright 2006 nudge:nudge. All rights reserved.
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
	[nibView release];
	
	NSLog(@"%@ dealloc",[self className]);
	
	[super dealloc];
}

#pragma mark accessors
- (NSView*)view
{
	return view;
}

- (void)setView:(NSView*)aView
{
	[aView retain];
	[view release];
	view = aView;
}

@end
