//
//  PAResultsBookmarkCell.m
//  punakea
//
//  Created by Daniel on 24.10.06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "PAResultsBookmarkCell.h"


@implementation PAResultsBookmarkCell

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
	NSRect iconFrame = cellFrame;
	iconFrame.origin.x += 5;
	iconFrame.origin.y += 1;
	iconFrame.size = NSMakeSize(16,16);
	
	NSImage *icon = [[PAThumbnailManager sharedInstance] iconForFile:[item valueForAttribute:kMDItemPath]
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
	   [[controlView window] isKeyWindow] &&
	   ![[controlView itemAtRow:[controlView editedRow]] isEqualTo:item]) 
		[fontAttributes setObject:[NSColor whiteColor] forKey:NSForegroundColorAttributeName];
	else
		[fontAttributes setObject:[NSColor blackColor] forKey:NSForegroundColorAttributeName];
		
	[fontAttributes setObject:[NSFont systemFontOfSize:11] forKey:NSFontAttributeName];
	
	NSMutableParagraphStyle *paraStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
	[paraStyle setLineBreakMode:NSLineBreakByTruncatingMiddle];
	[fontAttributes setObject:paraStyle forKey:NSParagraphStyleAttributeName];
	
	// Draw display name	
	NSString *value = [item valueForAttribute:kMDItemDisplayName];
	value = [value substringToIndex:[value length] - 7];
	
	[value	drawInRect:NSMakeRect(cellFrame.origin.x + 25,
								  cellFrame.origin.y + 2,
								  cellFrame.size.width - 190 - 25,
								  cellFrame.size.height - 2)
	    withAttributes:fontAttributes];
		
	// Draw bookmark url
	NDResourceFork *resource = [[NDResourceFork alloc] initForReadingAtPath:[item valueForAttribute:(id)kMDItemPath]];
	NSData *data = [resource dataForType:'url ' Id:256];
	NSString *url = [[NSString alloc] initWithData:data encoding:[NSString defaultCStringEncoding]];
	
	NSMutableDictionary *urlFontAttributes = [[fontAttributes mutableCopy] autorelease];
	
	if([self isHighlighted] &&
	   [[[controlView window] firstResponder] isDescendantOf:[controlView superview]] &&
	   [[controlView window] isKeyWindow] &&
	   ![[controlView itemAtRow:[controlView editedRow]] isEqualTo:item]) 
	{
		[urlFontAttributes setObject:[NSColor whiteColor] forKey:NSForegroundColorAttributeName];
	} else {
		[urlFontAttributes setObject:[NSColor grayColor] forKey:NSForegroundColorAttributeName];
	}
	
	[url	drawInRect:NSMakeRect(cellFrame.origin.x + 25,
								  cellFrame.origin.y + 17,
								  cellFrame.size.width - 190 - 25,
								  cellFrame.size.height - 17)
	    withAttributes:urlFontAttributes];
		
	[resource release];
	[url release];
	
		
	// Draw last used date
	NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];	
	[dateFormatter setFormatterBehavior:NSDateFormatterBehavior10_4];
	[dateFormatter setDateStyle:NSDateFormatterLongStyle];	
	
	NSDate *lastUsedDate = [item valueForAttribute:(id)kMDItemLastUsedDate];
	
	value = [dateFormatter friendlyStringFromDate:lastUsedDate];
	
	[value drawAtPoint:NSMakePoint(cellFrame.origin.x + cellFrame.size.width - 170, cellFrame.origin.y + 2)
	  	withAttributes:fontAttributes];
}


#pragma mark Renaming Stuff
- (void)editWithFrame:(NSRect)aRect inView:(NSView *)controlView editor:(NSText *)textObj delegate:(id)anObject event:(NSEvent *)theEvent
{
	NSLog(@"editWithFrame");
}

- (void)selectWithFrame:(NSRect)aRect inView:(NSView *)controlView editor:(NSText *)textObj delegate:(id)anObject start:(int)selStart length:(int)selLength
{	
	NSRect frame = aRect;
	frame.origin.x += 25;
	frame.origin.y += 1;
	frame.size.width -= 180 + 25; 
	frame.size.height -= 17;
	
	[super selectWithFrame:frame inView:controlView editor:textObj delegate:anObject start:selStart length:selLength];

	[textObj setFont:[NSFont systemFontOfSize:11]];
	[textObj setString:[item valueForAttribute:(id)kMDItemDisplayName]];
	
	[textObj selectAll:self];
}


#pragma mark Class Methods
+ (float)heightOfRow
{
	return 33.0;
}


#pragma mark Accessors
- (id)objectValue
{
	return item;
}

- (void)setObjectValue:(id <NSCopying>)object
{
	item = object;
}

@end
