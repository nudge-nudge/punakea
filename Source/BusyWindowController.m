//
//  BusyWindowController.m
//  punakea
//
//  Created by Daniel on 30.01.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "BusyWindowController.h"
#import "NNTagging/NNCommonNotifications.h"


@interface BusyWindowController (PrivateAPI)

- (void)stopModal;

@end


@implementation BusyWindowController

- (void)awakeFromNib
{
	[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(progressUpdated:) 
												 name:NNProgressDidUpdateNotification
											   object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(performBusyAction:) 
												 name:NSWindowDidBecomeKeyNotification
											   object:[self window]];
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[super dealloc];
}


#pragma mark Notifications
- (void)performBusyAction:(NSNotification *)notification
{
	[busyObject performSelectorOnMainThread:busySelector
								 withObject:nil
							  waitUntilDone:NO];
	
	[progressIndicator setIndeterminate:YES];
	[progressIndicator setUsesThreadedAnimation:YES];
	[progressIndicator startAnimation:self];
	
	// Ensure we get this notification only once
	[[NSNotificationCenter defaultCenter] removeObserver:self
													name:NSWindowDidBecomeKeyNotification
												  object:[self window]];
}

- (void)progressUpdated:(NSNotification *)notification
{
	[progressIndicator stopAnimation:self];
	[progressIndicator setUsesThreadedAnimation:NO];
	[progressIndicator setIndeterminate:NO];
	
	NSDictionary *dict = [notification userInfo];
	
	double doubleValue = [[dict objectForKey:@"currentProgress"] doubleValue];
	double maxValue = [[dict objectForKey:@"maximumProgress"] doubleValue];
	
	if(maxValue != [progressIndicator maxValue])
		[progressIndicator setMaxValue:maxValue];
	
	[progressIndicator setDoubleValue:doubleValue];
	[[self window] display];
	
	if(doubleValue == maxValue)
		[self stopModal];
}


#pragma mark Actions
- (void)performBusySelector:(SEL)aSelector onObject:(id)anObject
{
	busySelector = aSelector;
	busyObject = anObject;
}

- (void)stopModal
{
	[progressIndicator setDoubleValue:0.0];
	
	[[self window] close];
	[NSApp stopModal];
	
	// Register again for notification
	[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(performBusyAction:) 
												 name:NSWindowDidBecomeKeyNotification
											   object:[self window]];
}


#pragma mark Accessors
- (void)setMessage:(NSString *)aMessage
{
	message = [NSString stringWithString:aMessage];
	[textField setStringValue:message];
}


#pragma mark TEMP
- (void)dummy:(id)sender
{
	for (int i = 0; i < 100; i++)
	{	
		NSMutableDictionary *dict = [NSMutableDictionary dictionary];
		[dict setObject:[NSNumber numberWithInt:i] forKey:@"doubleValue"];
		[dict setObject:[NSNumber numberWithInt:99] forKey:@"maxValue"];
		
		[[NSNotificationCenter defaultCenter] postNotificationName:NNProgressDidUpdateNotification
															object:dict];
	}
}
@end
