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

#import "PAFileBox.h"

@implementation PAFileBox

- (void)awakeFromNib
{
	dropManager = [PADropManager sharedInstance];
	
	[self registerForDraggedTypes:[dropManager handledPboardTypes]];
}

- (void)dealloc
{
    [self unregisterDraggedTypes];
    [super dealloc];
}

#pragma mark accessors

- (void)setObjects:(NSArray*)objectArray
{
	[objects release];
	objects = [objectArray mutableCopy];
}

- (NSMutableArray*)objects
{
	return objects;
}

#pragma mark drap & drop stuff
- (NSDragOperation)draggingEntered:(id <NSDraggingInfo>)sender
{
	// check if sender should be ignored
	if(![dropManager acceptsSender:[sender draggingSource]])
		return NSDragOperationNone;
	
	NSEvent *currentEvent = [NSApp currentEvent];
    NSUInteger flags = [currentEvent modifierFlags];
    if (flags & NSAlternateKeyMask)
		[dropManager setAlternateState:YES];
	else 
		[dropManager setAlternateState:NO];	
	
	[[self window] mouseEvent];
	[self setImage:[NSImage imageNamed:@"drop_highlight"]];
	
	return [dropManager performedDragOperation:[sender draggingPasteboard]];
}

- (void)draggingExited:(id <NSDraggingInfo>)sender
{
	[self setImage:[NSImage imageNamed:@"drop"]];
	[[self window] mouseEvent];
}

- (NSDragOperation)draggingUpdated:(id <NSDraggingInfo>)sender
{
	// check if sender should be ignored
	if(![dropManager acceptsSender:[sender draggingSource]])
		return NSDragOperationNone;
	
	NSEvent *currentEvent = [NSApp currentEvent];
    NSUInteger flags = [currentEvent modifierFlags];
    if (flags & NSAlternateKeyMask)
		[dropManager setAlternateState:YES];
	else 
		[dropManager setAlternateState:NO];
	
	return [dropManager performedDragOperation:[sender draggingPasteboard]];
}

- (void)draggingEnded:(id <NSDraggingInfo>)sender
{
	//nothin
}

- (BOOL)prepareForDragOperation:(id <NSDraggingInfo>)sender
{
    return YES;
}

- (BOOL)performDragOperation:(id <NSDraggingInfo>)sender
{
	//[[[self window] delegate] appShouldStayFront];
	
	NSArray *newObjects = [dropManager handleDrop:[sender draggingPasteboard]];
	[self setObjects:newObjects];
	
    return YES;
}

/**
executes some interface stuff
 */
- (void)concludeDragOperation:(id <NSDraggingInfo>)sender
{	
	[self setImage:[NSImage imageNamed:@"drop"]];
}

@end
