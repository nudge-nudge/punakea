//
//  PAButtonCell.m
//  punakea
//
//  Created by Daniel on 07.08.06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "PAButtonCell.h"


@implementation PAButtonCell

#pragma mark Init + Dealloc
- (id)initImageCell:(NSImage *)anImage
{	
	self = [super initImageCell:anImage];
	if(self)
	{
		images = [[NSMutableDictionary alloc] init];
		if (anImage) [self setImage:anImage forState:PAOffState];
		
		[self commonInit];
	}	
	return self;
}

- (id)initTextCell:(NSString *)aText
{	
	self = [super initTextCell:aText];
	if(self)
	{
		title = aText;
		[self commonInit];
	}
	return self;
}

- (void)commonInit
{
	state = PAOffState;
	buttonType = PAMomentaryLightButton;	
	bezelType = PARecessedBezelType;
	bordered = NO;
	
	tag = [[NSMutableDictionary alloc] init];
	
	//[self setAction:@selector(action:)];
}

- (void)dealloc
{
	if(title) [title release];
	if(images) [images release];
	if(tag) [tag release];
	[super dealloc];
}


#pragma mark Drawing
- (void)drawInteriorWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
	if(hovered)
	{
		NSString *str = @"___";
		[str drawAtPoint:cellFrame.origin withAttributes:nil];
	}
	[title drawAtPoint:cellFrame.origin withAttributes:nil];
}

- (void)highlight:(BOOL)flag withFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
	[self drawInteriorWithFrame:cellFrame inView:controlView];
}


#pragma mark Accessors
- (NSString *)title
{
	return title;
}

- (void)setTitle:(NSString *)aTitle
{
	title = [aTitle retain];
}

- (BOOL)isBordered
{
	return bordered;
}

- (void)setBordered:(BOOL)flag
{
	bordered = flag;
}

- (BOOL)isHovered
{
	return hovered;
}

- (void)setHovered:(BOOL)flag
{
	hovered = flag;
}

- (PAButtonState)state
{
	return state;
}

- (void)setState:(PAButtonState)aState
{
	state = aState;
}

- (PABezelType)bezelType
{
	return bezelType;
}

- (void)setBezelType:(PABezelType)aBezelType
{
	bezelType = aBezelType;
}

@end
