//
//  PAResultsGroupCell.m
//  punakea
//
//  Created by Daniel on 05.04.06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "PAResultsGroupCell.h"


@interface PAResultsGroupCell (PrivateAPI)

- (NSString *)currentDisplayMode;
- (NSArray *)availableDisplayModes;
- (PAImageButtonCell *)segmentForDisplayMode:(NSString *)mode;

@end


@implementation PAResultsGroupCell

#pragma mark Init + Dealloc
- (id)initTextCell:(NSString *)aText
{
	self = [super initTextCell:aText];
	if (self)
	{
		hasMultipleDisplayModes = NO;
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
	// Check if subviews already exist in controlView
	// References are not kept because cells are autoreleased
	NSEnumerator *enumerator = [[controlView subviews] objectEnumerator];
	id anObject;
	
	while(anObject = [enumerator nextObject])
	{
		if([[anObject class] isEqualTo:[PAImageButton class]])
		{
			NSDictionary *tag = [(PAImageButton *)anObject tag];
			//if([[tag objectForKey:@"identifier"] isEqualToString:[group value]])
			if([[tag objectForKey:@"identifier"] isEqualToString:[valueDict objectForKey:@"identifier"]])
				triangle = anObject;
		}
		
		if([self hasMultipleDisplayModes])
			if([[anObject class] isEqualTo:[PASegmentedImageControl class]])
			{
				NSDictionary *tag = [(PASegmentedImageControl *)anObject tag];
				//if([[tag objectForKey:@"identifier"] isEqualToString:[group value]])
				if([[tag objectForKey:@"identifier"] isEqualToString:[valueDict objectForKey:@"identifier"]])
					segmentedControl = anObject;
			}
	}
	
	// Add triangle if neccessary
	if([triangle superview] != controlView)
	{
		triangle = [[PAImageButton alloc] initWithFrame:NSMakeRect(cellFrame.origin.x + 4, cellFrame.origin.y + 2, 16, 16)];
		[triangle setImage:[NSImage imageNamed:@"CollapsedTriangleWhite"] forState:PAOffState];
		[triangle setImage:[NSImage imageNamed:@"ExpandedTriangleWhite"] forState:PAOnState];
		[triangle setImage:[NSImage imageNamed:@"ExpandedTriangleWhite_Pressed"] forState:PAOnHighlightedState];
		[triangle setImage:[NSImage imageNamed:@"CollapsedTriangleWhite_Pressed"] forState:PAOffHighlightedState];
		[triangle setButtonType:PASwitchButton];
		[triangle setState:PAOnState];
		[triangle setAction:@selector(triangleClicked:)];
		[triangle setTarget:[(PAResultsOutlineView *)[self controlView] delegate]];
		
		// Add references to PAImageButton's tag for later usage
		NSMutableDictionary *tag = [triangle tag];
		//[tag setObject:[group value] forKey:@"identifier"];
		[tag setObject:[valueDict objectForKey:@"identifier"] forKey:@"identifier"];
		//[tag setObject:group forKey:@"group"];
		
		[controlView addSubview:triangle];  
	} else {
		[triangle setFrame:NSMakeRect(cellFrame.origin.x + 4, cellFrame.origin.y + 2, 16, 16)];
	}
	
	// Does triangle's current state match the cell's state?
	id group = [controlView groupForIdentifier:[valueDict objectForKey:@"identifier"]];	
	if([triangle state] != PAOnHighlightedState && [triangle state] != PAOffHighlightedState)
		if([(NSOutlineView *)[triangle superview] isItemExpanded:group])
			[triangle setState:PAOnState];
		else
			[triangle setState:PAOffState];
	
	// Add segmented control if neccessary
	if([self hasMultipleDisplayModes])
	{
		if([segmentedControl superview] != controlView)
		{			
			NSArray *displayModes = [self availableDisplayModes];
	
			segmentedControl = [[PASegmentedImageControl alloc] initWithFrame:cellFrame];
		
			// ListMode applies for all groups
			[segmentedControl addSegment:[self segmentForDisplayMode:@"ListMode"]];
			
			if([displayModes containsObject:@"IconMode"])
				[segmentedControl addSegment:[self segmentForDisplayMode:@"IconMode"]];
			
			[segmentedControl setAction:@selector(segmentedControlClicked:)];
			[segmentedControl setTarget:[(PAResultsOutlineView *)[self controlView] delegate]];
			
			// Add references to PASegmentedImageControl's tag for later usage
			NSMutableDictionary *tag = [segmentedControl tag];
			[tag setObject:[valueDict objectForKey:@"identifier"] forKey:@"identifier"];
			//[tag setObject:group forKey:@"group"];
			
			[controlView addSubview:segmentedControl];
		}
		// Refresh frame after all segments have been added
		NSRect scFrame = [segmentedControl frame];
		NSRect rect = NSMakeRect(cellFrame.origin.x + cellFrame.size.width - scFrame.size.width,
								  cellFrame.origin.y,
								  scFrame.size.width,
								  20);
		[segmentedControl setFrame:rect];
	}
	
	
	// Draw background
	
	NSImage *backgroundImage;
	if ([[controlView window] isKeyWindow])
		backgroundImage = [NSImage imageNamed:@"MD0-0-Middle-1"];
	else
		backgroundImage = [NSImage imageNamed:@"MD0-1-Middle-1"];
	
	[backgroundImage setFlipped:YES];
	[backgroundImage setScalesWhenResized:YES];
	
	NSRect imageRect;
	imageRect.origin = NSZeroPoint;
	imageRect.size = [backgroundImage size];
		
	[backgroundImage drawInRect:cellFrame fromRect:imageRect operation:NSCompositeCopy fraction:1.0];

					   
	// Draw text	
	NSString *value = [self naturalLanguageGroupValue];
	
	NSMutableDictionary *fontAttributes = [NSMutableDictionary dictionaryWithCapacity:3];
	[fontAttributes setObject:[NSColor whiteColor] forKey:NSForegroundColorAttributeName];
	[fontAttributes setObject:[NSFont boldSystemFontOfSize:12] forKey:NSFontAttributeName];
	
	[value drawAtPoint:NSMakePoint(cellFrame.origin.x + 23, cellFrame.origin.y + 1) withAttributes:fontAttributes];
}

- (void)highlight:(BOOL)flag withFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
	[self drawInteriorWithFrame:cellFrame inView:controlView];
}


#pragma mark Helpers
- (NSString *)naturalLanguageGroupValue
{	
	NSBundle *bundle = [NSBundle mainBundle];
	return [bundle localizedStringForKey:[valueDict objectForKey:@"identifier"]
	                               value:[valueDict objectForKey:@"identifier"]
								   table:@"MDSimpleGrouping"];
}

- (PAImageButtonCell *)segmentForDisplayMode:(NSString *)mode
{
	NSImage *image;
	PAImageButtonCell *cell;
	
	if([mode isEqualToString:@"ListMode"])
	{
		image = [NSImage imageNamed:@"MDListViewOff-1"];
		[image setFlipped:YES];
		cell = [[PAImageButtonCell alloc] initImageCell:image];
		
		image = [NSImage imageNamed:@"MDListViewOn-1"];
		[image setFlipped:YES];
		[cell setImage:image forState:PAOnState];	
		
		image = [NSImage imageNamed:@"MDListViewPressed-1"];
		[image setFlipped:YES];
		[cell setImage:image forState:PAOnHighlightedState];		
		[cell setImage:image forState:PAOffHighlightedState];
		
		image = [NSImage imageNamed:@"MDListViewOnDisabled"];
		[image setFlipped:YES];
		[cell setImage:image forState:PAOnDisabledState];
		
		image = [NSImage imageNamed:@"MDListViewOffDisabled"];
		[image setFlipped:YES];
		[cell setImage:image forState:PAOffDisabledState];
	}
	
	if([mode isEqualToString:@"IconMode"])
	{
		image = [NSImage imageNamed:@"MDIconViewOff-1"];
		[image setFlipped:YES];
		cell = [[PAImageButtonCell alloc] initImageCell:image];
		
		image = [NSImage imageNamed:@"MDIconViewOn-1"];
		[image setFlipped:YES];
		[cell setImage:image forState:PAOnState];
		
		image = [NSImage imageNamed:@"MDIconViewPressed-1"];
		[image setFlipped:YES];
		[cell setImage:image forState:PAOnHighlightedState];
		[cell setImage:image forState:PAOffHighlightedState];
		
		image = [NSImage imageNamed:@"MDIconViewOnDisabled"];
		[image setFlipped:YES];
		[cell setImage:image forState:PAOnDisabledState];
		
		image = [NSImage imageNamed:@"MDIconViewOffDisabled"];
		[image setFlipped:YES];
		[cell setImage:image forState:PAOffDisabledState];
	}
		
	if([[self currentDisplayMode] isEqualToString:mode])			
		[cell setState:PAOnState];
	else
		[cell setState:PAOffState];
		
	[cell setButtonType:PASwitchButton];
	NSMutableDictionary *tag = [cell tag];
	[tag setObject:mode forKey:@"identifier"];
	
	return cell;
}

- (NSArray *)availableDisplayModes
{
	NSMutableArray *modes = [NSMutableArray arrayWithCapacity:5];
	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSDictionary *displayModes = [(NSDictionary *)[defaults objectForKey:@"Results"] objectForKey:@"DisplayModes"];
	
	NSString *identifier = [valueDict objectForKey:@"identifier"];
	NSEnumerator *enumerator = [displayModes keyEnumerator];
	NSString *key;
	while(key = [enumerator nextObject])
		if([(NSArray *)[displayModes objectForKey:key] containsObject:identifier])
			[modes addObject:key];

	return modes;
}

- (NSString *)currentDisplayMode
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSDictionary *currentDisplayModes = [[defaults objectForKey:@"Results"] objectForKey:@"CurrentDisplayModes"];
	NSString *mode;
	//if(mode = [currentDisplayModes objectForKey:[group value]])
	if(mode = [currentDisplayModes objectForKey:[valueDict objectForKey:@"identifier"]])
		return mode;
	else
		return @"ListMode";
}


#pragma mark Accessors
- (id)objectValue
{
	return valueDict;
}

- (void)setObjectValue:(id <NSCopying>)object
{
	valueDict = (NSDictionary *)object;
}

- (BOOL)hasMultipleDisplayModes
{
	if(hasMultipleDisplayModes) return hasMultipleDisplayModes;
	
	if([[self availableDisplayModes] count] > 0)
		return (hasMultipleDisplayModes = YES);
	else
		return (hasMultipleDisplayModes = NO);
}

@end
