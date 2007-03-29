//
//  PASourcePanel.m
//  punakea
//
//  Created by Daniel on 28.03.07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "PASourcePanel.h"


@implementation PASourcePanel

- (void)awakeFromNib
{
	[self setIntercellSpacing:NSZeroSize];
}

#pragma mark Drawing
- (id)_highlightColorForCell:(NSCell *)cell
{				
	return nil;
}

- (void)highlightSelectionInClipRect:(NSRect)clipRect
{
	NSRect rowRect = [self rectOfRow:[self selectedRow]];
	
	// Draw background
	NSImage *backgroundImage = [NSImage imageNamed:@"SourcePanelSelectionGradient"];
	
	if([self isFlipped]) [backgroundImage setFlipped:YES];
	[backgroundImage setScalesWhenResized:YES];
	
	// Using 0.1 and 1.9 instead of 1.0 as there seems to be some antialiasing :( 
	
	NSRect imageRect;
	imageRect.origin = NSZeroPoint;
	imageRect.size.width = 0.1;
	imageRect.size.height = [backgroundImage size].height;
	
	// Decide which color to use
	if([[[self window] firstResponder] isDescendantOf:self] &&
	   [[self window] isKeyWindow]) 
	{
		imageRect.origin.x = 0.0;
	} else {
		imageRect.origin.x = 1.9;
	}
	
	[backgroundImage drawInRect:rowRect fromRect:imageRect operation:NSCompositeSourceOver fraction:1.0];
	
	//[super highlightSelectionInClipRect:clipRect];
}


#pragma mark Misc
- (NSRect)frameOfCellAtColumn:(int)column row:(int)row
{
	NSRect rect = [super frameOfCellAtColumn:column row:row];
	
	// Skip half indentation for level 0 and shift other levels one half #up
	rect.origin.x -= [self indentationPerLevel] / 2;
	rect.size.width += [self indentationPerLevel] / 2;
	
	return rect;
}

@end
