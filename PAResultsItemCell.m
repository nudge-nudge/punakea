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
	if (self)
	{
		// Nothing
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
	// Draw icon
	NSImage *icon = [[NSWorkspace sharedWorkspace] iconForFile:[valueDict objectForKey:@"path"]];
	[icon setFlipped:YES];
	[icon setSize:NSMakeSize(16,16)];
	
	NSRect imageRect;
	imageRect.origin = NSZeroPoint;
	imageRect.size = [icon size];
	
	[icon drawAtPoint:NSMakePoint(cellFrame.origin.x + 5, cellFrame.origin.y + 1) fromRect:imageRect operation:NSCompositeSourceOver fraction:1.0];
	 
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
	NSString *value = [valueDict objectForKey:@"displayName"];
	
	[value	drawInRect:NSMakeRect(cellFrame.origin.x + 25,
								  cellFrame.origin.y + 2,
								  cellFrame.size.width - 180 - 25,
								  cellFrame.size.height - 2)
	    withAttributes:fontAttributes];
		
	// Draw last used date
	NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
	[dateFormatter setFormatterBehavior:NSDateFormatterBehavior10_4];
	
	[dateFormatter setDateStyle:NSDateFormatterMediumStyle];
	[dateFormatter setTimeStyle:NSDateFormatterNoStyle];
		
	NSDate *lastUsedDate = [valueDict objectForKey:@"lastUsedDate"];
	
	// TODO: Support TODAY and YESTERDAY
	if([lastUsedDate timeIntervalSinceNow] > [[NSNumber numberWithInt:-60*60*24*40] doubleValue])
	{
		[dateFormatter setDateStyle:NSDateFormatterLongStyle];
		[dateFormatter setTimeStyle:NSDateFormatterShortStyle];
	} else {
		[dateFormatter setDateFormat:@"MMMM yyyy"];
	}
	
	value = [dateFormatter stringFromDate:lastUsedDate];
		
	[value drawAtPoint:NSMakePoint(cellFrame.origin.x + cellFrame.size.width - 160, cellFrame.origin.y + 2)
	    withAttributes:fontAttributes];
		
	/*[dateFormatter setDateStyle:NSDateFormatterNoStyle];
	[dateFormatter setTimeStyle:NSDateFormatterShortStyle];
	
	value = [dateFormatter stringFromDate:lastUsedDate];	
	[value drawAtPoint:NSMakePoint(cellFrame.origin.x + cellFrame.size.width - 40, cellFrame.origin.y + 2)
	    withAttributes:fontAttributes]; */
}


#pragma mark Accessors
- (id)objectValue
{
	return valueDict;
}

- (void)setObjectValue:(id <NSCopying>)object
{
	[valueDict autorelease];
	valueDict = [(NSDictionary *)object retain];
}

@end
