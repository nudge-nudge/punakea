//
//  PASelectedTagCell.m
//  punakea
//
//  Created by Daniel on 23.06.06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "PASelectedTagCell.h"


@implementation PASelectedTagCell

#pragma mark Init + Dealloc
- (id)initTextCell:(NSString *)aText
{
	self = [super initTextCell:aText];
	if (self)
	{
		valueDict = [[NSMutableDictionary alloc] init];
		[valueDict setValue:aText forKey:@"value"];
		
		[self setImagesForStates];
		[self setButtonType:PASwitchButton];
	}	
	return self;
}

- (void)dealloc
{
	if(valueDict) [valueDict release];
	[super dealloc];
}

- (id)copyWithZone:(NSZone *)zone
{
	PASelectedTagCell *cellCopy = [super copyWithZone:zone];
	
	cellCopy->valueDict = nil;
	[cellCopy setObjectValue:[self objectValue]];
	
	return cellCopy;
}


#pragma mark Drawing
- (void)drawInteriorWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{	
	// TODO:
	// Highlighting doesn't work as untilMouseUp seems to be ignored by superclass :'(

	// Let superclass handle the main drawing stuff
	[super drawInteriorWithFrame:cellFrame inView:controlView];
	
	// Add borders corresponding to the current state
	if([self state] == PAOffState)
	{
		NSImage *leftImage = [NSImage imageNamed:@"pane_key-buttonLeft-N"];
		[leftImage setFlipped:YES];
		
		NSRect imageRect;
		imageRect.origin = NSZeroPoint;
		imageRect.size = [leftImage size];
		
		[leftImage drawAtPoint:cellFrame.origin fromRect:imageRect operation:NSCompositeCopy fraction:1.0];
		
		NSImage *rightImage = [NSImage imageNamed:@"pane_key-buttonRight-N"];
		[rightImage setFlipped:YES];
		
		imageRect.origin = NSZeroPoint;
		imageRect.size = [leftImage size];
		
		NSPoint rightPoint = NSMakePoint(cellFrame.origin.x + cellFrame.size.width - imageRect.size.width,
								         cellFrame.origin.y);
		
		[rightImage drawAtPoint:rightPoint fromRect:imageRect operation:NSCompositeCopy fraction:1.0];
	}
	
	// Font attributes
	NSMutableDictionary *fontAttributes = [NSMutableDictionary dictionaryWithCapacity:3];
	
	if([self isHighlighted]) 
		[fontAttributes setObject:[NSColor redColor] forKey:NSForegroundColorAttributeName];
	else
		[fontAttributes setObject:[NSColor blackColor] forKey:NSForegroundColorAttributeName];
		
	[fontAttributes setObject:[NSFont systemFontOfSize:11] forKey:NSFontAttributeName];
	
	NSMutableParagraphStyle *paraStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
	[paraStyle setLineBreakMode:NSLineBreakByTruncatingMiddle];
	[fontAttributes setObject:paraStyle forKey:NSParagraphStyleAttributeName];
	
	// Draw display name	
	NSString *value = [valueDict objectForKey:@"value"];
	
	[value	drawInRect:NSMakeRect(cellFrame.origin.x + 7,
								  cellFrame.origin.y + 3,
								  cellFrame.size.width,
								  cellFrame.size.height)
	    withAttributes:fontAttributes];
}

- (void)highlight:(BOOL)flag withFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
	[self drawInteriorWithFrame:cellFrame inView:controlView];
}


#pragma mark Helpers
- (void)setImagesForStates
{	
	NSImage *image = [NSImage imageNamed:@"pane_key-buttonFill-N"];
	[image setScalesWhenResized:YES];
	[image setFlipped:YES];
	[self setImage:image forState:PAOffState];
	
	image = [NSImage imageNamed:@"pane_key-buttonFill-H1"];
	[image setScalesWhenResized:YES];
	[image setFlipped:YES];
	[self setImage:image forState:PAOnState];	
	
	image = [NSImage imageNamed:@"pane_key-buttonFill-P1"];
	[image setScalesWhenResized:YES];
	[image setFlipped:YES];
	[self setImage:image forState:PAOnHighlightedState];
	
	image = [NSImage imageNamed:@"pane_key-buttonFill-P"];
	[image setScalesWhenResized:YES];
	[image setFlipped:YES];		
	[self setImage:image forState:PAOffHighlightedState];
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
