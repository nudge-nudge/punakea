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
	[self setState:PAOffState];
	[self setButtonType:PAMomentaryLightButton];	
	[self setBezelStyle:PARecessedBezelStyle];
	[self setBordered:YES];
	[self setControlSize:NSSmallControlSize];
	
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
	// Clear all drawings
	[[NSColor clearColor] set];
	[[NSBezierPath bezierPathWithRect:cellFrame] fill];

	if(bordered)
	{
		[self drawTextButtonWithFrame:cellFrame inView:controlView];
	} else {
		if(hovered)
		{
			NSString *str = @"___";
			[str drawAtPoint:cellFrame.origin withAttributes:nil];
		}
		[title drawAtPoint:cellFrame.origin withAttributes:nil];
	}
}

- (void)highlight:(BOOL)flag withFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
	[self drawInteriorWithFrame:cellFrame inView:controlView];
}

- (void)drawTextButtonWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
	// Attributed string for title
	NSMutableAttributedString *label = [[NSMutableAttributedString alloc] initWithString:title];
	[label addAttribute:NSFontAttributeName
				  value:[NSFont systemFontOfSize:[NSFont systemFontSizeForControlSize:[self controlSize]]]
				  range:NSMakeRange(0, [label length])];
	
	if([self isHighlighted] || [self isHovered])
	{
		[label addAttribute:NSForegroundColorAttributeName
					  value:[NSColor alternateSelectedControlTextColor]
					  range:NSMakeRange(0, [label length])];
	} else {
		[label addAttribute:NSForegroundColorAttributeName
					  value:[NSColor textColor]
					  range:NSMakeRange(0, [label length])];
	}
	
	NSMutableParagraphStyle *paraStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
	[paraStyle setLineBreakMode:NSLineBreakByTruncatingMiddle];
	[paraStyle setAlignment:NSCenterTextAlignment];
	[label addAttribute:NSParagraphStyleAttributeName
				  value:paraStyle
				  range:NSMakeRange(0, [label length])];
	
	NSSize padding = NSMakeSize(5,1);
	
	NSRect bezelFrame = cellFrame;
	
	if([self state] == PAOnState || [self isHovered])
	{
		[[NSColor grayColor] set];
		[[NSBezierPath bezierPathWithRoundRectInRect:bezelFrame radius:20] fill];
	}
		
	NSRect labelFrame = bezelFrame;
	labelFrame.origin.x = bezelFrame.origin.x + padding.width;
	labelFrame.origin.y += padding.height;
	labelFrame.size.width = bezelFrame.size.width - 2 * padding.width;
	labelFrame.size.height = bezelFrame.size.height - 2 * padding.height;

	[label drawInRect:labelFrame];
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

- (PABezelStyle)bezelStyle
{
	return bezelStyle;
}

- (void)setBezelStyle:(PABezelStyle)aBezelStyle
{
	bezelStyle = aBezelStyle;
}

- (PAButtonType)buttonType
{
	return buttonType;
}

- (void)setButtonType:(PAButtonType)type
{
	buttonType = type;
}

@end
