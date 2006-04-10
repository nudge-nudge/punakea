//
//  PAResultsGroupCell.m
//  punakea
//
//  Created by Daniel on 05.04.06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "PAResultsGroupCell.h"


@implementation PAResultsGroupCell

#pragma mark Init + Dealloc
- (id)initTextCell:(NSString *)aText
{
	self = [super initTextCell:aText];
	//if (self) {}	
	return self;
}

- (void)dealloc
{
	if(group) [group release];
	/*if(triangle)
	{
		[triangle removeFromSuperview];
		[triangle release];
		NSLog(@"removing");
	}*/
	[super dealloc];
}


#pragma mark Drawing
- (void)drawInteriorWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{					   
	// Check if subviews already exist in controlView
	// References are not kept because cells are autoreleased
	int i;
	NSArray *subviews = [controlView subviews];
	for(i = 0; i < [subviews count]; i++)
	{
		if([[[subviews objectAtIndex:i] class] isEqualTo:[PAImageButton class]])
		{
			NSDictionary *tag = [[subviews objectAtIndex:i] tag];
			if([[tag objectForKey:@"identifier"] isEqualToString:[group value]])
			{
				triangle = [subviews objectAtIndex:i];
			}
		}
		if([[[subviews objectAtIndex:i] class] isEqualTo:[PASegmentedImageControl class]])
		{
			NSDictionary *tag = [[subviews objectAtIndex:i] tag];
			if([[tag objectForKey:@"identifier"] isEqualToString:[group value]])
			{
				segmentedControl = [subviews objectAtIndex:i];
			}
		}
	}
	
	// Add triangle if neccessary
	if([triangle superview] != controlView)
	{
		triangle = [[PAImageButton alloc] initWithFrame:NSMakeRect(cellFrame.origin.x, cellFrame.origin.y + 2, 16, 16)];
		[triangle setImage:[NSImage imageNamed:@"CollapsedTriangleWhite"] forState:PAOffState];
		[triangle setImage:[NSImage imageNamed:@"ExpandedTriangleWhite"] forState:PAOnState];
		[triangle setImage:[NSImage imageNamed:@"ExpandedTriangleWhite_Pressed"] forState:PAOnHighlightedState];
		[triangle setImage:[NSImage imageNamed:@"CollapsedTriangleWhite_Pressed"] forState:PAOffHighlightedState];
		[triangle setButtonType:PASwitchButton];
		[triangle setState:PAOnState];
		[triangle setTarget:[[self controlView] delegate]];
		
		// Add references to PAImageButton's tag for later usage
		NSMutableDictionary *tag = [triangle tag];
		[tag setObject:[group value] forKey:@"identifier"];
		[tag setObject:group forKey:@"group"];
		
		[controlView addSubview:triangle];  
	} else {
		[triangle setFrame:NSMakeRect(cellFrame.origin.x, cellFrame.origin.y + 2, 16, 16)];
	}
	
	// Add segmented control if neccessary
	if([segmentedControl superview] != controlView)
	{
		segmentedControl = [[PASegmentedImageControl alloc] initWithFrame:cellFrame];
		
		NSImage *image = [NSImage imageNamed:@"MDIconViewOff-1"];
		[image setFlipped:YES];
		PAImageButtonCell *cell = [[PAImageButtonCell alloc] initImageCell:image];
		[segmentedControl addSegment:cell];
		
		// Add references to PASegmentedImageControl's tag for later usage
		NSMutableDictionary *tag = [segmentedControl tag];
		[tag setObject:[group value] forKey:@"identifier"];
		[tag setObject:group forKey:@"group"];
		
		[controlView addSubview:segmentedControl];
	}
	// Refresh frame after all segments have been added
	NSRect scFrame = [segmentedControl frame];
	NSRect rect = NSMakeRect(cellFrame.origin.x + cellFrame.size.width - scFrame.size.width,
							  cellFrame.origin.y,
							  scFrame.size.width,
							  20);
	[segmentedControl setFrame:rect];
	
	
	// Draw background
	
	// TODO: Change image if window doesn't have focus
	
	NSImage *backgroundImage = [NSImage imageNamed:@"MD0-0-Middle-1"];
	[backgroundImage setFlipped:YES];
	[backgroundImage setScalesWhenResized:YES];
	
	NSRect imageRect;
	imageRect.origin = NSZeroPoint;
	imageRect.size = [backgroundImage size];
		
	[backgroundImage drawInRect:cellFrame fromRect:imageRect operation:NSCompositeSourceOver fraction:1.0];

					   
	// Draw text	
	NSString *value = [group value];
	
	NSMutableDictionary *fontAttributes = [NSMutableDictionary dictionaryWithCapacity:3];
	[fontAttributes setObject:[NSColor whiteColor] forKey:NSForegroundColorAttributeName];
	[fontAttributes setObject:[NSFont boldSystemFontOfSize:12] forKey:NSFontAttributeName];
	
	[value drawAtPoint:NSMakePoint(cellFrame.origin.x + 23, cellFrame.origin.y + 1) withAttributes:fontAttributes];
}


#pragma mark Accessors
- (void)setGroup:(NSMetadataQueryResultGroup *)aGroup
{
	group = [aGroup retain];
}

@end
