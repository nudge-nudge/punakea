//
//  PAResultsMultiItemThumbnailCell.m
//  punakea
//
//  Created by Daniel on 17.06.06.
//  Copyright 2006 nudge:nudge. All rights reserved.
//

#import "PAResultsMultiItemThumbnailCell.h"


@implementation PAResultsMultiItemThumbnailCell

#pragma mark Init + Dealloc
- (id)initTextCell:(NNFile *)anItem
{
	self = [super initTextCell:anItem];
	if(self)
	{
		// nothing yet
	}	
	return self;
}

- (void)dealloc
{
	[super dealloc];
}


#pragma mark Drawing
- (void)drawInteriorWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{		
	// Clear all drawings
	[[NSColor clearColor] set];
	[[NSBezierPath bezierPathWithRect:cellFrame] fill];

	// Attributed string for value
	NSString *value = [item valueForAttribute:(id)kMDItemDisplayName];
	NSMutableAttributedString *valueLabel = [[[NSMutableAttributedString alloc] initWithString:value] autorelease];
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
	
	NSMutableParagraphStyle *paraStyle = [[[NSParagraphStyle defaultParagraphStyle] mutableCopy] autorelease];
	[paraStyle setLineBreakMode:NSLineBreakByTruncatingMiddle];
	[paraStyle setAlignment:NSCenterTextAlignment];
	[valueLabel addAttribute:NSParagraphStyleAttributeName
	                   value:paraStyle
				       range:NSMakeRange(0, [valueLabel length])];
	
	NSRect bezelFrame = cellFrame;
	bezelFrame.origin.y += cellFrame.size.height - 30;
	bezelFrame.size.height = 16;  // Spotlight height
	
	// Draw Finder label
	NSUInteger label = [FVFinderLabel finderLabelForURL:[[self item] url]];
	
	[FVFinderLabel drawFinderLabel:label inRect:bezelFrame roundEnds:YES];
	
	// Draw selection
	if([self isHighlighted])
	{	
		NSRect selRect = bezelFrame;
		
		// Inset rect if there's a Finder label
		if (label > 0)
		{
			selRect = NSInsetRect(selRect, 2, 2);
		}
		
		[[NSColor alternateSelectedControlColor] set];
		[[NSBezierPath bezierPathWithRoundRectInRect:selRect radius:20] fill];
	}
	
	NSSize padding = NSMakeSize(5,1);
	
	// Draw label
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
				thumbnailWithContentsOfFile:[item valueForAttribute:(id)kMDItemPath]
				                     inView:controlView
									  frame:bezelFrame];
	
	if([controlView isFlipped]) [thumbImage setFlipped:YES];
	
	NSRect imageRect;
	imageRect.origin = NSZeroPoint;
	imageRect.size = [thumbImage size];
	
	NSPoint targetPoint = NSMakePoint(bezelFrame.origin.x + 4,
									  bezelFrame.origin.y + 4 + (77 - imageRect.size.height) / 2);
	
	if(imageRect.size.width < bezelFrame.size.width - 8 ||
	   imageRect.size.height < bezelFrame.size.height - 8)
	{
		targetPoint.x = bezelFrame.origin.x + (bezelFrame.size.width - imageRect.size.width) / 2;
		targetPoint.y = bezelFrame.origin.y + (bezelFrame.size.height - imageRect.size.height) / 2;
	}

	[thumbImage drawAtPoint:targetPoint fromRect:imageRect operation:NSCompositeSourceOver fraction:1.0];
	
	// Begin drawing bottom row
	NSString *sortKey = [[[controlView delegate] sortDescriptor] key];
	
	// Set up date formatter
	NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];	
	[dateFormatter setFormatterBehavior:NSDateFormatterBehavior10_4];
	[dateFormatter setTimeStyle:NSDateFormatterShortStyle];
	[dateFormatter setDateStyle:NSDateFormatterShortStyle];	
	
	if ([sortKey isEqualToString:@"displayName"] ||
		[sortKey isEqualToString:@"label"])
	{		
		//value = [dateFormatter friendlyStringFromDate:[item lastUsedDate]];
		value = [dateFormatter stringFromDate:[item lastUsedDate]];
	} 
	else if ([sortKey isEqualToString:@"creationDate"])
	{
		value = [dateFormatter stringFromDate:[item creationDate]];
	}
	else if ([sortKey isEqualToString:@"modificationDate"])
	{
		value = [dateFormatter stringFromDate:[item modificationDate]];
	}
	else if ([sortKey isEqualToString:@"kind"])
	{
		value = [item kind];
	}
	else if ([sortKey isEqualToString:@"size"])
	{
		NSNumberFormatter *numberFormatter = [[[NSNumberFormatter alloc] init] autorelease];
		[numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
		
		value = [numberFormatter stringFromFileSize:[item size]];
	}
	else {
		value = @"";
	}	
	
	NSMutableDictionary *fontAttributes = [NSMutableDictionary dictionaryWithCapacity:3];
	[fontAttributes setObject:[NSColor grayColor] forKey:NSForegroundColorAttributeName];		
	[fontAttributes setObject:[NSFont systemFontOfSize:10] forKey:NSFontAttributeName];	
	
	paraStyle = [[[NSParagraphStyle defaultParagraphStyle] mutableCopy] autorelease];
	[paraStyle setLineBreakMode:NSLineBreakByTruncatingMiddle];
	[paraStyle setAlignment:NSCenterTextAlignment];
	[fontAttributes setObject:paraStyle forKey:NSParagraphStyleAttributeName];	
	
	NSRect dateFrame = valueLabelFrame;
	dateFrame.origin.x = cellFrame.origin.x;
	dateFrame.origin.y += 16;
	dateFrame.size.width = cellFrame.size.width;
			
	[value drawInRect:dateFrame withAttributes:fontAttributes];
}

- (void)highlight:(BOOL)flag withFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
	[self drawInteriorWithFrame:cellFrame inView:controlView];
}


#pragma mark Renaming Stuff
- (void)editWithFrame:(NSRect)aRect inView:(NSView *)controlView editor:(NSText *)textObj delegate:(id)anObject event:(NSEvent *)theEvent
{	
	[self selectWithFrame:aRect inView:controlView editor:textObj delegate:anObject start:0 length:0];
}

- (void)selectWithFrame:(NSRect)aRect inView:(NSView *)controlView editor:(NSText *)textObj delegate:(id)anObject start:(NSInteger)selStart length:(NSInteger)selLength
{	
	NSRect frame = aRect;
	//frame.origin.x -= 2;
	frame.origin.y += frame.size.height - 30;
	//frame.size.width += 4; 
	frame.size.height = 30;
	
	[super selectWithFrame:frame inView:controlView editor:textObj delegate:anObject start:selStart length:selLength];
	
	[textObj setDrawsBackground:YES];
	[textObj setBackgroundColor:[NSColor whiteColor]];
	[textObj setFont:[NSFont systemFontOfSize:11]];
	[textObj setString:[item valueForAttribute:(id)kMDItemDisplayName]];
	
	[textObj selectAll:self];
	
	[[self controlView] setNeedsDisplay:YES];
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
