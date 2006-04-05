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
	if(triangle)
	{
		[triangle removeFromSuperview];
		[triangle release];
		//NSLog(@"removing");
	}
	[super dealloc];
}


#pragma mark Drawing
- (void)drawInteriorWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{					   
	// Add or move triangle
	/*if([triangle superview] != controlView)
	{
		triangle = [[PAImageButton alloc] initWithFrame:NSMakeRect(cellFrame.origin.x, cellFrame.origin.y + 2, 16, 16)];
		[triangle setImage:[NSImage imageNamed:@"CollapsedTriangleWhite"] forState:PAOffState];
		[triangle setImage:[NSImage imageNamed:@"ExpandedTriangleWhite"] forState:PAOnState];
		[triangle setImage:[NSImage imageNamed:@"ExpandedTriangleWhite_Pressed"] forState:PAOnHighlightedState];
		[triangle setImage:[NSImage imageNamed:@"CollapsedTriangleWhite_Pressed"] forState:PAOffHighlightedState];
		[triangle setButtonType:PASwitchButton];
		[triangle setState:PAOnState];
		[triangle setTarget:self];
		[controlView addSubview:triangle];  
		//NSLog(@"adding");
	} else {
		[triangle setFrame:NSMakeRect(cellFrame.origin.x, cellFrame.origin.y + 2, 16, 16)];
	}*/
	
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


#pragma mark Actions
- (void)action:(id)sender
{
	NSLog(@"action");
}


#pragma mark Accessors
- (void)setGroup:(NSMetadataQueryResultGroup *)aGroup
{
	group = [aGroup retain];
}

@end
