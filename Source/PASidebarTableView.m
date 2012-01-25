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

#import "PASidebarTableView.h"


@implementation PASidebarTableView

- (void)awakeFromNib
{
	[self setBackgroundColor:[NSColor colorWithDeviceRed:1.0 green:1.0 blue:1.0 alpha:0.85]];
}

#pragma mark drag'n'drop
/**
only works if parent window is a PASidebar
 */
- (NSDragOperation)draggingEntered:(id <NSDraggingInfo>)sender 
{
	[[self window] mouseEvent];
	return NSDragOperationNone;
}

/**
only works if parent window is a PASidebar
 */
- (void)draggingExited:(id <NSDraggingInfo>)sender 
{
	[[self window] mouseEvent];
}

#pragma mark drawing
// do not use default highlight on clicking
-(id)_highlightColorForCell:(NSCell *)cell
{
	return [NSColor colorWithDeviceRed:1.0 green:1.0 blue:1.0 alpha:0.85];
}

// draw black border on drop TODO
-(void)_drawDropHighlightOnRow:(NSInteger)rowIndex 
{
	NSRect cellFrame = [self frameOfCellAtColumn:0 row:rowIndex];
	
	NSBezierPath *bezel = [NSBezierPath bezierPathWithRoundRectInRect:cellFrame radius:20.0];
	[bezel setLineWidth:1.1];
	[[NSColor blackColor] set];
	[bezel stroke];
}

@end
