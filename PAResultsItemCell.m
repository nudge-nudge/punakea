//
//  PAResultsItemCell.m
//  punakea
//
//  Created by Daniel on 05.04.06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "PAResultsItemCell.h"


@implementation PAResultsItemCell

#pragma mark Init + Dealloc
- (id)initTextCell:(NSString *)aText
{
	self = [super initTextCell:aText];
	//if (self) {}	
	return self;
}

- (void)dealloc
{
	if(item) [item release];
	[super dealloc];
}


#pragma mark Drawing
- (void)drawInteriorWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{				
	// Draw icon
	NSImage *icon = [[NSWorkspace sharedWorkspace] iconForFile:[item valueForAttribute:(id)kMDItemPath]];
	[icon setFlipped:YES];
	[icon setSize:NSMakeSize(16,16)];
	
	NSRect imageRect;
	imageRect.origin = NSZeroPoint;
	imageRect.size = [icon size];
	
	[icon drawAtPoint:NSMakePoint(cellFrame.origin.x + 23, cellFrame.origin.y + 1) fromRect:imageRect operation:NSCompositeSourceOver fraction:1.0];
	   					   
	// Draw text	
	NSString *value = [item valueForAttribute:(id)kMDItemDisplayName];
	
	NSMutableDictionary *fontAttributes = [NSMutableDictionary dictionaryWithCapacity:3];
	
	if([self isHighlighted]) 
		[fontAttributes setObject:[NSColor whiteColor] forKey:NSForegroundColorAttributeName];
	else
		[fontAttributes setObject:[NSColor blackColor] forKey:NSForegroundColorAttributeName];
		
	[fontAttributes setObject:[NSFont systemFontOfSize:11] forKey:NSFontAttributeName];
	
	[value drawAtPoint:NSMakePoint(cellFrame.origin.x + 43, cellFrame.origin.y + 1)
	    withAttributes:fontAttributes];
}



#pragma mark Accessors
- (NSMetadataItem *)item
{
	return item;
}

- (void)setItem:(NSMetadataItem *)anItem
{
	item = [anItem retain];
}

@end
