//
//  PAButtonCell.m
//  punakea
//
//  Created by Daniel on 07.08.06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "PAButtonCell.h"


NSSize const PADDING_RECESSEDBEZELSTYLE = {8,0};
//NSSize const PADDING_TOKENBEZELSTYLE = {5,1};

int const HEIGHT_RECESSEDBEZELSTYLE_SMALL = 15;


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
	
	// Set colors
	NSColor *shadowColor;
	
	if([self isHighlighted] || [self isHovered])
	{
		[label addAttribute:NSForegroundColorAttributeName
					  value:[NSColor alternateSelectedControlTextColor]
					  range:NSMakeRange(0, [label length])];
					  
		shadowColor = [NSColor colorWithDeviceWhite:0.2 alpha:0.6];	
	} else {
		[label addAttribute:NSForegroundColorAttributeName
					  value:[NSColor textColor]
					  range:NSMakeRange(0, [label length])];
		
		shadowColor = [NSColor colorWithDeviceWhite:0.92 alpha:0.6];	
	}
	
	// Add shadow
	NSShadow *shadow = [[NSShadow alloc] init];
	[shadow setShadowOffset:NSMakeSize(1,-1.5)];
	[shadow setShadowColor:shadowColor];
	[label addAttribute:NSShadowAttributeName
				  value:shadow
				  range:NSMakeRange(0, [label length])];
	[shadow release];
	
	NSMutableParagraphStyle *paraStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
	[paraStyle setLineBreakMode:NSLineBreakByTruncatingMiddle];
	[paraStyle setAlignment:NSCenterTextAlignment];
	[label addAttribute:NSParagraphStyleAttributeName
				  value:paraStyle
				  range:NSMakeRange(0, [label length])];
	
	// TODO: use external vars
	NSSize padding = PADDING_RECESSEDBEZELSTYLE;
	
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

- (NSSize)cellSize
{
	NSSize size = NSMakeSize(0,0);
	
	if([self isBordered])
	{	
		switch([self bezelStyle])
		{
			case PARecessedBezelStyle:;
				NSMutableAttributedString *label = [[NSMutableAttributedString alloc] initWithString:[self title]];
				[label addAttribute:NSFontAttributeName
							  value:[NSFont systemFontOfSize:[NSFont systemFontSizeForControlSize:[self controlSize]]]
							  range:NSMakeRange(0, [label length])];
				NSSize labelSize = [label size];
				
				size.width = labelSize.width + 2 * PADDING_RECESSEDBEZELSTYLE.width;
				
				size.height = HEIGHT_RECESSEDBEZELSTYLE_SMALL;
				
				break;
			// TODO: Add token style
		}
	} else {
		// TODO: Set size to image size
	}
	
	return size;
}

@end
