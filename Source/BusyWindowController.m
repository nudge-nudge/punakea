// Copyright (c) 2006-2012 nudge:nudge (Johannes Hoffart & Daniel Bär). All rights reserved.
// 
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "BusyWindowController.h"
#import "NNTagging/NNCommonNotifications.h"


@interface BusyWindowController (PrivateAPI)

- (void)stopModal;
- (void)executeSelector;

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
    [busyObject performSelectorInBackground:busySelector
                                 withObject:busyArg];
	
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
	[self performBusySelector:aSelector onObject:anObject withObject:nil];
}

- (void)performBusySelector:(SEL)aSelector onObject:(id)anObject withObject:(id)arg
{
	busySelector = aSelector;
	busyObject = anObject;
	busyArg = arg;
}

- (void)stopModal
{
	[progressIndicator setDoubleValue:0.0];
	
	[NSApp abortModal];	
	[NSApp endSheet:[self window]];
	[[self window] orderOut:self];
	
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
	for (NSInteger i = 0; i < 100; i++)
	{	
		NSMutableDictionary *dict = [NSMutableDictionary dictionary];
		[dict setObject:[NSNumber numberWithInteger:i] forKey:@"doubleValue"];
		[dict setObject:[NSNumber numberWithInteger:99] forKey:@"maxValue"];
		
		[[NSNotificationCenter defaultCenter] postNotificationName:NNProgressDidUpdateNotification
															object:dict];
	}
}
@end
