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

#import "PASegmentedImageControl.h"


@implementation PASegmentedImageControl

#pragma mark Init + Dealloc
- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
		[self setCellClass:[NSTextFieldCell class]];
		[self renewRows:1 columns:0];
		[self setIntercellSpacing:NSMakeSize(0,0)];
		[self setCellSize:NSMakeSize(21,20)];
		[self setMode:NSHighlightModeMatrix];
		tag = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void)dealloc
{
	if(tag) [tag release];
	[super dealloc];
}


#pragma mark Actions
- (void)addSegment:(PAImageButtonCell *)imageButtonCell
{
	NSInteger col = [self numberOfColumns];
	
	[imageButtonCell setTarget:self];

	[self insertColumn:col];
	[self putCell:imageButtonCell atRow:0 column:col];
	
	// First cell determines the cells' size
	/*if(col == 0)
	{
		NSSize cellSize = [imageButtonCell cellSize];
		[self setCellSize:cellSize];
	}*/
	NSRect rect = [self frame];
	NSSize cellSize = [self cellSize];
	rect.size.width = cellSize.width * [self numberOfColumns];
	[self setFrame:rect];
}


#pragma mark Notifications
- (void)action:(id)sender
{
	// Deselect all cells except the one the user clicked on (RadioMode)
	NSInteger i;
	BOOL allCellsAreDeselected = YES;
	for(i = 0; i < [self numberOfColumns]; i++)
	{
		if([[self cellAtRow:0 column:i] isHighlighted]) allCellsAreDeselected = NO;
	}
	if(allCellsAreDeselected) [[self selectedCell] setHighlighted:YES];
	
	for(i = 0; i < [self numberOfColumns]; i++)
	{
		NSCell *cell = [self cellAtRow:0 column:i];
		if([cell isNotEqualTo:[self selectedCell]]) [cell setHighlighted:NO];
	}
	
	[self sendAction:[self action] to:[self target]];
}


#pragma mark Accessors
- (NSMutableDictionary *)tag
{
	return tag;
}

- (void)setTag:(NSDictionary *)aTag
{
	tag = [aTag retain];
}

@end
