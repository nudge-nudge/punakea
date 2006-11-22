//
//  PASidebarTagCell.m
//  punakea
//
//  Created by Johannes Hoffart on 26.05.06.
//  Copyright 2006 nudge:nudge. All rights reserved.
//

#import "PATagTextFieldCell.h"


@implementation PATagTextFieldCell

- (id)initTextCell:(NSString*)name
{
	if (self = [super initTextCell:name])
	{
		//nothin
	}
	return self;
}

- (void)drawInteriorWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
	NSColor *bezelColor = [NSColor colorWithDeviceRed:(222.0/255.0) green:(231.0/255.0) blue:(248.0/255.0) alpha:1.0];
	NSColor *selectedBezelColor = [NSColor alternateSelectedControlColor];

	NSColor *outerBezelColor = [bezelColor blendedColorWithFraction:0.4 ofColor:selectedBezelColor];

	NSBezierPath *bezel = [NSBezierPath bezierPathWithRoundRectInRect:cellFrame radius:20.0];
	[bezel setLineWidth:1.1];
	[outerBezelColor set];
	[bezel fill];
	
	// Draw inner bezel
	NSColor *innerBezelColor = bezelColor;

	bezel = [NSBezierPath bezierPathWithRoundRectInRect:NSInsetRect(cellFrame, 1.0, 1.0) radius:20.0];
	[innerBezelColor set];
	[bezel fill];
	
	// Draw icon
	NSRect iconFrame = cellFrame;
	iconFrame.origin.x += iconFrame.size.width - 28;
	iconFrame.origin.y += 7;
	iconFrame.size = NSMakeSize(18,12);
	
	NSImage *icon = [NSImage imageNamed:@"drop_tag_small"];
	
	[icon setSize:NSMakeSize(18,12)];
	[icon setFlipped:YES];
	
	NSRect imageRect;
	imageRect.origin = NSZeroPoint;
	imageRect.size = [icon size];
	
	[icon drawAtPoint:iconFrame.origin fromRect:imageRect operation:NSCompositeSourceOver fraction:1.0];
	
	// Font attributes
	NSMutableDictionary *fontAttributes = [NSMutableDictionary dictionaryWithCapacity:3];
	
	[fontAttributes setObject:[NSColor blackColor] forKey:NSForegroundColorAttributeName];
	[fontAttributes setObject:[NSFont systemFontOfSize:14] forKey:NSFontAttributeName];
	
	NSMutableParagraphStyle *paraStyle = [[[NSParagraphStyle defaultParagraphStyle] mutableCopy] autorelease];
	[paraStyle setLineBreakMode:NSLineBreakByTruncatingTail];
	[fontAttributes setObject:paraStyle forKey:NSParagraphStyleAttributeName];
	
	// Draw display name	
	NSString *value = [self stringValue];
	
	[value	drawInRect:NSMakeRect(cellFrame.origin.x + 6,
								  cellFrame.origin.y + 2,
								  cellFrame.size.width - 44,
								  cellFrame.size.height - 4)
	    withAttributes:fontAttributes];
}

- (void)highlight:(BOOL)flag withFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
	NSLog(@"highlight");
	[self drawInteriorWithFrame:cellFrame inView:controlView];
}

@end
