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
	 
	// Font attributes
	NSMutableDictionary *fontAttributes = [NSMutableDictionary dictionaryWithCapacity:3];
	
	if([self isHighlighted]) 
		[fontAttributes setObject:[NSColor whiteColor] forKey:NSForegroundColorAttributeName];
	else
		[fontAttributes setObject:[NSColor blackColor] forKey:NSForegroundColorAttributeName];
		
	[fontAttributes setObject:[NSFont systemFontOfSize:11] forKey:NSFontAttributeName];
	
	NSMutableParagraphStyle *paraStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
	[paraStyle setLineBreakMode:NSLineBreakByTruncatingMiddle];
	[fontAttributes setObject:paraStyle forKey:NSParagraphStyleAttributeName];
	
	// Draw display name	
	NSString *value = [item valueForAttribute:(id)kMDItemDisplayName];
	//[value drawAtPoint:NSMakePoint(cellFrame.origin.x + 43, cellFrame.origin.y + 2)
	//    withAttributes:fontAttributes];
	
	[value	drawInRect:NSMakeRect(cellFrame.origin.x + 43,
								  cellFrame.origin.y + 2,
								  cellFrame.size.width - 180 - 43,
								  cellFrame.size.height - 2)
	    withAttributes:fontAttributes];
		
	// Draw last used date + time
	NSDate *lastUsedDate = [item valueForAttribute:(id)kMDItemLastUsedDate];
	
	NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
	[dateFormatter setFormatterBehavior:NSDateFormatterBehavior10_4];
	[dateFormatter setDateStyle:NSDateFormatterLongStyle];
	[dateFormatter setTimeStyle:NSDateFormatterNoStyle];
	
	/*NSDate *currentDate = [NSDate dateWithTimeIntervalSinceNow:0];
	NSString *currentDateString = [dateFormatter stringFromDate:currentDate]; */
	
	value = [dateFormatter stringFromDate:lastUsedDate];
	
	/*if([[value substringFromIndex:[value length] - 4] isEqualToString:
		[currentDateString substringFromIndex:[currentDateString length] - 4]])
		value = ;*/		
		
	[value drawAtPoint:NSMakePoint(cellFrame.origin.x + cellFrame.size.width - 160, cellFrame.origin.y + 2)
	    withAttributes:fontAttributes];
		
	dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
	[dateFormatter setFormatterBehavior:NSDateFormatterBehavior10_4];
	[dateFormatter setDateStyle:NSDateFormatterNoStyle];
	[dateFormatter setTimeStyle:NSDateFormatterShortStyle];
	
	value = [dateFormatter stringFromDate:lastUsedDate];	
	[value drawAtPoint:NSMakePoint(cellFrame.origin.x + cellFrame.size.width - 40, cellFrame.origin.y + 2)
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
