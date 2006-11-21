//
//  PABrowserViewMainController.m
//  punakea
//
//  Created by Johannes Hoffart on 26.09.06.
//  Copyright 2006 nudge:nudge. All rights reserved.
//

#import "PABrowserViewMainController.h"


@implementation PABrowserViewMainController

#pragma mark init
- (void)dealloc
{	
	[currentView release];
	[super dealloc];
}

#pragma mark main
- (void)handleTagActivation:(PATag*)tag
{
	return;
}

#pragma mark accessors
- (NSView*)currentView
{
	return currentView;
}

- (void)setCurrentView:(NSView*)aView
{
	[aView retain];
	[currentView release];
	currentView = aView;
	
	[currentView setNextResponder:self];
}

- (NSResponder*)dedicatedFirstResponder
{
	return currentView;
}
	
- (id)delegate
{
	return delegate;
}

- (void)setDelegate:(id)anObject
{
	delegate = anObject;
}

- (BOOL)isWorking
{
	return working;
}

- (void)setWorking:(BOOL)flag
{
	working = flag;
}

- (void)reset
{
	return;
}

@end
