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
	NSLog(@"blub dealloc");
	NSLog(@"mainView retaincount %i",[view retainCount]);
	
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
