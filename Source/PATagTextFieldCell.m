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
	NSColor *innerBezelColor;
	
	if ([self isHighlighted])
		 innerBezelColor = selectedBezelColor;
	else
		innerBezelColor = bezelColor;	

	bezel = [NSBezierPath bezierPathWithRoundRectInRect:NSInsetRect(cellFrame, 1.0, 1.0) radius:20.0];
	[innerBezelColor set];
	[bezel fill];
	
	// Draw icon
	/*
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
	*/
	
	// Font attributes
	NSMutableDictionary *fontAttributes = [NSMutableDictionary dictionaryWithCapacity:3];
	
	if ([self isHighlighted])
		[fontAttributes setObject:[NSColor whiteColor] forKey:NSForegroundColorAttributeName];
	else
		[fontAttributes setObject:[NSColor blackColor] forKey:NSForegroundColorAttributeName];
	
	[fontAttributes setObject:[NSFont systemFontOfSize:14] forKey:NSFontAttributeName];
	
	NSMutableParagraphStyle *paraStyle = [[[NSParagraphStyle defaultParagraphStyle] mutableCopy] autorelease];
	[paraStyle setLineBreakMode:NSLineBreakByTruncatingTail];
	[fontAttributes setObject:paraStyle forKey:NSParagraphStyleAttributeName];
	
	// Draw display name	
	NSString *value = [self stringValue];
	
	[value	drawInRect:NSMakeRect(cellFrame.origin.x + 6,
								  cellFrame.origin.y + 2,
								  cellFrame.size.width - 8,
								  cellFrame.size.height - 4)
	    withAttributes:fontAttributes];
}

- (void)highlight:(BOOL)flag withFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
	[self drawInteriorWithFrame:cellFrame inView:controlView];
}

@end
