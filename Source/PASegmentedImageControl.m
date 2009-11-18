//
//  PASegmentedImageControl.m
//  punakea
//
//  Created by Daniel on 10.04.06.
//  Copyright 2006 nudge:nudge. All rights reserved.
//

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
