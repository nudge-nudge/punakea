//
//  PAFileCell.m
//  punakea
//
//  Created by Johannes Hoffart on 10.10.06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "PAFileCell.h"


@implementation PAFileCell

- (id)initTextCell:(NSString *)aText
{
	self = [super initTextCell:aText];
	if (self)
	{
		// Nothing
	}	
	return self;
}

- (void)drawInteriorWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
	// Draw icon
	NSRect iconFrame = cellFrame;
	iconFrame.origin.x += 5;
	iconFrame.origin.y += 1;
	iconFrame.size = NSMakeSize(16,16);
		
	NSImage *icon = [[PAThumbnailManager sharedInstance] iconForFile:[file path]
	                                                          inView:controlView
															   frame:iconFrame];	
	
	[icon setSize:NSMakeSize(16,16)];
	[icon setFlipped:YES];
	
	NSRect imageRect;
	imageRect.origin = NSZeroPoint;
	imageRect.size = [icon size];
	
	[icon drawAtPoint:iconFrame.origin fromRect:imageRect operation:NSCompositeSourceOver fraction:1.0];
	// Font attributes
	NSMutableDictionary *fontAttributes = [NSMutableDictionary dictionaryWithCapacity:3];
	
	if([self isHighlighted] &&
	   [[[controlView window] firstResponder] isDescendantOf:[controlView superview]] &&
	   [[controlView window] isKeyWindow]) 
		[fontAttributes setObject:[NSColor whiteColor] forKey:NSForegroundColorAttributeName];
	else
		[fontAttributes setObject:[NSColor blackColor] forKey:NSForegroundColorAttributeName];
	
	[fontAttributes setObject:[NSFont systemFontOfSize:11] forKey:NSFontAttributeName];
	
	NSMutableParagraphStyle *paraStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
	[paraStyle setLineBreakMode:NSLineBreakByTruncatingMiddle];
	[fontAttributes setObject:paraStyle forKey:NSParagraphStyleAttributeName];
	
	// Draw display name	
	NSString *value = [file name];
	
	[value	drawInRect:NSMakeRect(cellFrame.origin.x + 25,
								  cellFrame.origin.y + 2,
								  cellFrame.size.width - 25,
								  cellFrame.size.height - 2)
	    withAttributes:fontAttributes];
}

#pragma mark Accessors
- (id)objectValue
{
	return file;
}

- (void)setObjectValue:(id <NSCopying>)object
{
	file = object;
}

@end
