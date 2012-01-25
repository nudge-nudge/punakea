// Copyright (c) 2006-2012 nudge:nudge (Johannes Hoffart & Daniel BŠr). All rights reserved.
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
	// Draw finder label
	NSUInteger label = [FVFinderLabel finderLabelForURL:[item url]];
	
	if (![self isHighlighted])
	{
		NSRect frame = cellFrame;
		frame.size.height = 18;
		
		[FVFinderLabel drawFinderLabel:label inRect:frame roundEnds:YES];
	} else {
		NSRect frame = NSMakeRect(cellFrame.origin.x + cellFrame.size.width - 19 - 2,
								  cellFrame.origin.y + 2,
								  19 - 4,
								  19 - 4);
		[FVFinderLabel drawFinderLabel:label inRect:frame roundEnds:YES];
	}
	
	// Draw icon
	NSRect iconFrame = cellFrame;
	iconFrame.origin.x += 5;
	iconFrame.origin.y += 1;
	iconFrame.size = NSMakeSize(16,16);
	
	NSImage *icon = [[PAThumbnailManager sharedInstance] iconForFile:[item path]
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
	
	NSMutableParagraphStyle *paraStyle = [[[NSParagraphStyle defaultParagraphStyle] mutableCopy] autorelease];
	[paraStyle setLineBreakMode:NSLineBreakByTruncatingMiddle];
	[fontAttributes setObject:paraStyle forKey:NSParagraphStyleAttributeName];
	
	// Draw display name	
	NSString *value = [item displayName];
	if([value hasSuffix:@"webloc"])
		value = [value substringToIndex:[value length] - 7];
	
	[value	drawInRect:NSMakeRect(cellFrame.origin.x + 25,
								  cellFrame.origin.y + 2,
								  cellFrame.size.width - 190 - 25,
								  cellFrame.size.height - 2)
	    withAttributes:fontAttributes];
		
	// Draw bookmark url	// TODO taggableObject does not necessarily have a path
	// FIXME this badly needs refactoring into the controller - holy shit.
	NSDictionary *weblocDic = [NSDictionary dictionaryWithContentsOfFile:[item path]];
	NSString *url = [weblocDic objectForKey:@"URL"];
	
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
		
	// Begin drawing second column
	NSString *sortKey = [[[controlView delegate] sortDescriptor] key];
	
	// Set up date formatter
	NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];	
	[dateFormatter setFormatterBehavior:NSDateFormatterBehavior10_4];
	[dateFormatter setTimeStyle:NSDateFormatterShortStyle];
	[dateFormatter setDateStyle:NSDateFormatterLongStyle];	
	
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
	
	[value	drawInRect:NSMakeRect(cellFrame.origin.x + cellFrame.size.width - 170,
								  cellFrame.origin.y + 2,
								  160,
								  cellFrame.size.height - 2)
	   withAttributes:fontAttributes];
}


#pragma mark Renaming Stuff
- (void)editWithFrame:(NSRect)aRect inView:(NSView *)controlView editor:(NSText *)textObj delegate:(id)anObject event:(NSEvent *)theEvent
{
	NSLog(@"editWithFrame");
}

- (void)selectWithFrame:(NSRect)aRect inView:(NSView *)controlView editor:(NSText *)textObj delegate:(id)anObject start:(NSInteger)selStart length:(NSInteger)selLength
{	
	NSRect frame = aRect;
	frame.origin.x += 25;
	frame.origin.y += 1;
	frame.size.width -= 180 + 25; 
	frame.size.height -= 17;
	
	[super selectWithFrame:frame inView:controlView editor:textObj delegate:anObject start:selStart length:selLength];

	[textObj setFont:[NSFont systemFontOfSize:11]];
	
	NSString *displayName = [item displayName];
	if([displayName hasSuffix:@"webloc"])
		displayName = [displayName substringToIndex:[displayName length] - 7];
	
	[textObj setString:displayName];
	
	[textObj selectAll:self];
}


#pragma mark Class Methods
+ (CGFloat)heightOfRow
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
