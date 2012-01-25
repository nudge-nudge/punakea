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

#import "NSTextFieldAdditions.h"


@implementation NSTextField (NSTextFieldAdditions)

/* Determines the minimum size of a textfield's content.
   Source: http://brockerhoff.net/bb/viewtopic.php?p=1982#1982
*/
- (NSSize)minSizeForContent
{
	NSRect frame = [self frame];
	NSRect newf = frame;
	NSTextView *editor = nil;
	
	if((editor = (NSTextView *)[self currentEditor])) {
		newf = [[editor layoutManager] usedRectForTextContainer:[editor textContainer]];
		newf.size.height += frame.size.height-[[self cell] drawingRectForBounds:frame].size.height;
	} else {
		newf.size.height = HUGE_VALF;
		newf.size = [[self cell] cellSizeForBounds:newf];
	}
	frame.size.height = newf.size.height;
	return frame.size;
}

@end
