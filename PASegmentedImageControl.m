//
//  PASegmentedImageControl.m
//  punakea
//
//  Created by Daniel on 10.04.06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
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
		tag = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void)dealloc
{
	if(tag) { [tag release]; }
	[super dealloc];
}


#pragma mark Actions
- (void)addSegment:(PAImageButtonCell *)imageButtonCell
{
	[imageButtonCell setTarget:self];
	/*NSNumber *pos = [NSNumber numberWithInt:[self numberOfColumns]]] - 1;
	[valueDict setObject:imageButton forKey:pos];
	[self setNeedsDisplay];*/
	int col = [self numberOfColumns];
	[self insertColumn:col];
	[self putCell:imageButtonCell atRow:0 column:col];
	
	// Renew frame
	NSRect rect = [self frame];
	NSSize cellSize = [imageButtonCell cellSize];
	[self setCellSize:cellSize];
	rect.size.width = cellSize.width * [self numberOfColumns];
	[self setFrame:rect];
}


#pragma mark Notifications
- (void)action:(id)sender
{
	
}


#pragma mark Accessors
/* Action messages from buttons are sent to this control, but forwarded afterwards
- target
- (void)setTarget: */

- (NSMutableDictionary *)tag
{
	return tag;
}

- (void)setTag:(NSDictionary *)aTag
{
	tag = [aTag retain];
}

/*- (NSRect)frame
{
	NSRect frame = [super frame];
	frame.size.width = frame.size.width * [self numberOfColumns];
	return frame;
}*/

@end
