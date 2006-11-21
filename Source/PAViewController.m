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
	NSLog(@"%@ dealloc",[self className]);
	NSLog(@"mainView retaincount %i",[view retainCount]);
	
	// release view twice
	// 1. objects in nib are instantiated with retain count 1
	// 2. setView has been called
	[view release];
	[view release];
	
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
