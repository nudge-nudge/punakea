//
//  PAResultsMultiItemThumbnailCell.m
//  punakea
//
//  Created by Daniel on 17.06.06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "PAResultsMultiItemThumbnailCell.h"


@implementation PAResultsMultiItemThumbnailCell

#pragma mark Init + Dealloc
- (id)initTextCell:(NSString *)aText
{
	self = [super initTextCell:aText];
	if (self)
	{
		value = aText;	
	}	
	return self;
}

- (void)dealloc
{
	if(valueDict) [valueDict release];
	if(value) [value release];
	[super dealloc];
}


#pragma mark Drawing
- (void)drawInteriorWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{		
	// Clear all drawings
	[[NSColor whiteColor] set];
	NSRectFill(cellFrame);

	// Attributed string for value
	NSMutableAttributedString *valueLabel = [[NSMutableAttributedString alloc] initWithString:value];
	[valueLabel addAttribute:NSFontAttributeName
					   value:[NSFont systemFontOfSize:11]
					   range:NSMakeRange(0, [valueLabel length])];
	
	if([self isHighlighted])
	{
		[valueLabel addAttribute:NSForegroundColorAttributeName
						   value:[NSColor alternateSelectedControlTextColor]
					       range:NSMakeRange(0, [valueLabel length])];
	} else {
		[valueLabel addAttribute:NSForegroundColorAttributeName
						   value:[NSColor textColor]
						   range:NSMakeRange(0, [valueLabel length])];
	}
	
	NSMutableParagraphStyle *paraStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
	[paraStyle setLineBreakMode:NSLineBreakByTruncatingMiddle];
	[paraStyle setAlignment:NSCenterTextAlignment];
	[valueLabel addAttribute:NSParagraphStyleAttributeName
	                   value:paraStyle
				       range:NSMakeRange(0, [valueLabel length])];

	NSSize valueLabelSize = [valueLabel size];
	
	NSRect bezelFrame = cellFrame;
	bezelFrame.origin.y += cellFrame.size.height - 30;
	bezelFrame.size.height = 16;  // Spotlight height

	if([self isHighlighted])
	{	
		[[NSColor alternateSelectedControlColor] set];
		[[NSBezierPath bezierPathWithRoundRectInRect:bezelFrame radius:20] fill];
	}
	
	NSSize padding = NSMakeSize(5,1);
	
	NSRect valueLabelFrame = bezelFrame;
	valueLabelFrame.origin.x = bezelFrame.origin.x + padding.width;
	valueLabelFrame.origin.y += padding.height;
	valueLabelFrame.size.width = bezelFrame.size.width - 2 * padding.width;
	valueLabelFrame.size.height = bezelFrame.size.height - 2 * padding.height;

	[valueLabel drawInRect:valueLabelFrame];
	
	// Draw thumbnail background rect
	bezelFrame = cellFrame;
	bezelFrame.origin.x += 5;
	bezelFrame.origin.y += 1;
	bezelFrame.size.height = 83;
	bezelFrame.size.width = 84;
	
	if([self isHighlighted])
	{	
		[[NSColor gridColor] set];
		[[NSBezierPath bezierPathWithRoundRectInRect:bezelFrame radius:10] fill];
	}	
	
	// Draw thumbnail
	NSImage *thumbImage = [[PAThumbnailManager sharedInstance]
				thumbnailWithContentsOfFile:[valueDict valueForAttribute:kMDItemPath]
				                     inView:controlView
									  frame:cellFrame];
	
	NSRect imageRect;
	imageRect.origin = NSZeroPoint;
	imageRect.size = [thumbImage size];
	
	NSPoint targetPoint = NSMakePoint(bezelFrame.origin.x + 4,
									  bezelFrame.origin.y + 4 + (77 - imageRect.size.height) / 2);

	[thumbImage drawAtPoint:targetPoint fromRect:imageRect operation:NSCompositeSourceOver fraction:1.0];
}

- (void)highlight:(BOOL)flag withFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
	[self drawInteriorWithFrame:cellFrame inView:controlView];
}


#pragma mark Renaming Stuff
- (void)editWithFrame:(NSRect)aRect inView:(NSView *)controlView editor:(NSText *)textObj delegate:(id)anObject event:(NSEvent *)theEvent
{
	NSLog(@"editWithFrame");
	
	[self selectWithFrame:aRect inView:controlView editor:textObj delegate:anObject start:0 length:0];
}

- (void)selectWithFrame:(NSRect)aRect inView:(NSView *)controlView editor:(NSText *)textObj delegate:(id)anObject start:(int)selStart length:(int)selLength
{	
	NSLog(@"selectWithFrame");

	NSRect frame = aRect;
	//frame.origin.x += 25;
	//frame.size.width -= 25; 
	
	[super selectWithFrame:frame inView:controlView editor:textObj delegate:anObject start:selStart length:selLength];
	
	[textObj setFont:[NSFont systemFontOfSize:11]];
	[textObj setString:[self value]];
	
	[textObj selectAll:self];
	
	[[self controlView] setNeedsDisplay:YES];
}


#pragma mark Accessors
- (NSString *)value
{
	return value;
}

- (void)setValueDict:(NSDictionary *)aDictionary
{
	valueDict = [aDictionary retain];
}


#pragma mark Class methods
+ (NSSize)cellSize
{
	return NSMakeSize(93, 115);
}

+ (NSSize)intercellSpacing
{
	return NSMakeSize(3, 3);
}

@end
