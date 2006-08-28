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
	if([self isHighlighted])
	{	
		bezelFrame = cellFrame;
		bezelFrame.origin.x += 5;
		bezelFrame.size.height = 83;
		bezelFrame.size.width = 83;
	
		[[NSColor gridColor] set];
		[[NSBezierPath bezierPathWithRoundRectInRect:bezelFrame radius:10] fill];
	}	
	
	// TEMP for thumbnail
	NSString *path = [valueDict objectForKey:@"path"];
	NSImage *thumbImage = [self thumbnailImageWithFile:path withSize:70 highQuality:NO];
	
	NSRect imageRect;
	imageRect.origin = NSZeroPoint;
	imageRect.size = [thumbImage size];
	
	[thumbImage drawAtPoint:cellFrame.origin fromRect:imageRect operation:NSCompositeCopy fraction:1.0];
}

- (void)highlight:(BOOL)flag withFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
	[self drawInteriorWithFrame:cellFrame inView:controlView];
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

- (NSImage *)thumbnailImageWithFile:(NSString *)filePath withSize:(int)size highQuality:(BOOL)hires
{
	NSImage		*big_thumb;
	NSImage		*thumbnail;
	NSSize		thumbnailSize;

	if (hires)
	{
		// create a double sized thumbnail
		thumbnailSize = NSMakeSize(size*2, size*2);

		// create the thumbnail using Epeg
		big_thumb = [EpegWrapper imageWithPath:filePath boundingBox:thumbnailSize];

		if ([big_thumb isValid])
		{
			// the real thumbnail should be half the Epeg thumbail
			thumbnailSize = NSMakeSize([big_thumb size].width/2, [big_thumb size].height/2);

			thumbnail = [[[NSImage alloc] initWithSize:thumbnailSize] autorelease];
			NSRect oldRect = NSMakeRect(0.0, 0.0, [big_thumb size].width, [big_thumb size].height);
			NSRect newRect = NSMakeRect(0.0, 0.0, [big_thumb size].width/2, [big_thumb size].height/2);

			[thumbnail lockFocus];
			[[NSGraphicsContext currentContext] setImageInterpolation:NSImageInterpolationHigh];
			[big_thumb drawInRect:newRect fromRect:oldRect operation:NSCompositeCopy fraction:1.0];
			[thumbnail unlockFocus];
		}
	}
	else
	{
		thumbnailSize = NSMakeSize(size, size);
		thumbnail = [EpegWrapper imageWithPath:filePath boundingBox:thumbnailSize];
	}
	return thumbnail;
}

@end
