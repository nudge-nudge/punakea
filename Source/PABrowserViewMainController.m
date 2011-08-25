// Copyright (c) 2006-2011 nudge:nudge (Johannes Hoffart & Daniel Bär). All rights reserved.
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

#import "PABrowserViewMainController.h"

@implementation PABrowserViewMainController

#pragma mark init
- (void)dealloc
{	
	[displayMessage release];
	[currentView release];
	[super dealloc];
}

#pragma mark main
- (void)handleTagActivation:(NNTag*)tag
{
	return;
}

- (void)handleTagNegation:(NNTag*)tag
{
	return;
}

- (void)handleTagActivations:(NSArray*)someTags
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

- (NSString*)displayMessage
{
	return @"";
}

- (void)reset
{
	return;
}

@end
