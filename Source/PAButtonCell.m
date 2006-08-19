//
//  PAButtonCell.m
//  punakea
//
//  Created by Daniel on 07.08.06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "PAButtonCell.h"


NSSize const PADDING_RECESSEDBEZELSTYLE = {8,0};
NSSize const PADDING_TOKENBEZELSTYLE = {10,2};

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
	
	[self setBezelColor:[NSColor colorWithDeviceRed:(222.0/255.0) green:(231.0/255.0) blue:(248.0/255.0) alpha:1.0]];
	[self setBezelBorderColor:[NSColor colorWithDeviceRed:(164.0/255.0) green:(189.0/255.0) blue:(236.0/255.0) alpha:1.0]];
	[self setFontSize:11];
	
	tag = [[NSMutableDictionary alloc] init];
}

- (void)dealloc
{
	if(bezelColor) [bezelColor release];
	if(bezelBorderColor) [bezelBorderColor release];
	if(title) [title release];
	if(attributedTitle) [attributedTitle release];
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
		switch(bezelStyle)
		{
			case PARecessedBezelStyle:
				[self drawRecessedButtonWithFrame:cellFrame inView:controlView]; break;
			case PATokenBezelStyle:
				[self drawTokenButtonWithFrame:cellFrame inView:controlView]; break;
		}
		
	} else {
		// TODO: Draw image-only button
	}
}

- (void)highlight:(BOOL)flag withFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
	[self drawInteriorWithFrame:cellFrame inView:controlView];
}

- (void)drawRecessedButtonWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
	// Attributed string for title
	NSMutableAttributedString *label = [self attributedTitle];
	
	// Set colors
	NSColor *textColor;
	NSColor *shadowColor;
	
	if([self isHighlighted] || [self isHovered])
	{
		textColor = [NSColor alternateSelectedControlTextColor];					  
		shadowColor = [NSColor colorWithDeviceWhite:0.2 alpha:0.6];	
	} else {
		textColor = [NSColor colorWithDeviceWhite:0.1 alpha:0.9];
		shadowColor = [NSColor whiteColor];
	}
	[label addAttribute:NSForegroundColorAttributeName
				  value:textColor
				  range:NSMakeRange(0, [label length])];
	
	// Add shadow
	NSShadow *shadow = [[NSShadow alloc] init];
	[shadow setShadowOffset:NSMakeSize(0,-1.5)];
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
	
	NSSize padding = PADDING_RECESSEDBEZELSTYLE;	

	NSImage *bezelImage = nil;
	if([self isHovered] && ![self isHighlighted] && ![self isPressed])
		bezelImage = [NSImage imageNamed:@"TabHover"];
	else if([self isHighlighted] && ![self isPressed])
		bezelImage = [NSImage imageNamed:@"TabSelected"];
	else if([self isPressed])
		bezelImage = [NSImage imageNamed:@"TabActive"];
	
	if(bezelImage)
	{
		[bezelImage setScalesWhenResized:YES];
		
		NSRect imgRect;
		NSRect destRect = cellFrame;
		
		// Draw left edge
		imgRect.origin = NSZeroPoint;
		imgRect.size = NSMakeSize(7,15);		
		destRect = cellFrame;
		destRect.size.width = 7;		
		[bezelImage drawInRect:destRect fromRect:imgRect operation:NSCompositeSourceOver fraction:1.0];
		
		// Draw scaled background
		imgRect.origin = NSMakePoint(7,0);
		imgRect.size = NSMakeSize(1,15);
		destRect = cellFrame;
		destRect.origin.x += 7;
		destRect.size.width -= 16;
		[bezelImage drawInRect:destRect fromRect:imgRect operation:NSCompositeSourceOver fraction:1.0];
		
		// Draw right edge
		imgRect.origin = NSMakePoint(8,0);
		imgRect.size = NSMakeSize(7,15);
		destRect = cellFrame;
		destRect.origin.x = destRect.size.width - 8;
		destRect.size.width = 7;
		[bezelImage drawInRect:destRect fromRect:imgRect operation:NSCompositeSourceOver fraction:1.0];
	}
	
	[label drawInRect:NSInsetRect(cellFrame, padding.width, padding.height)];
}

- (void)drawTokenButtonWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
	// TEMP for testing in front of white background
	//[[NSColor whiteColor] set];
	//NSRectFill(cellFrame);

	// Attributed string for title
	NSMutableAttributedString *label = [self attributedTitle];
	
	// Set colors
	// TODO: Make accessor for textcolors (1. off-state, 2. on-state)
	NSColor *textColor;	
	if([self isHighlighted] || [self isPressed])
	{
		textColor = [NSColor whiteColor];					  
	} else {
		textColor = [NSColor textColor];
	}
	[label addAttribute:NSForegroundColorAttributeName
				  value:textColor
				  range:NSMakeRange(0, [label length])];
				
	// Set paragraph style
	NSMutableParagraphStyle *paraStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
	[paraStyle setLineBreakMode:NSLineBreakByTruncatingMiddle];
	[paraStyle setAlignment:NSCenterTextAlignment];
	[label addAttribute:NSParagraphStyleAttributeName
				  value:paraStyle
				  range:NSMakeRange(0, [label length])];
	
	NSSize padding = PADDING_TOKENBEZELSTYLE;
	
	// Add bezel
	// TODO: Make accessor for selected bezel color + hovered bezel color + hovered bezel border color
	NSColor *outerBezelColor;
	if([self isHighlighted] || [self isPressed])
		outerBezelColor = [NSColor alternateSelectedControlColor];
	else
		outerBezelColor = bezelBorderColor;
	
	NSBezierPath *bezel = [NSBezierPath bezierPathWithRoundRectInRect:cellFrame radius:20.0];
	[bezel setLineWidth:1.1];
	[outerBezelColor set];
	[bezel fill];
	
	if(!([self isPressed] || [self isHighlighted]))
	{
		bezel = [NSBezierPath bezierPathWithRoundRectInRect:NSInsetRect(cellFrame, 1.0, 1.0) radius:20.0];
		[bezelColor set];
		[bezel fill];
	}
	
	[label drawInRect:NSInsetRect(cellFrame, padding.width, padding.height)];
}


#pragma mark Mouse Tracking
- (BOOL)trackMouse:(NSEvent *)theEvent inRect:(NSRect)cellFrame ofView:(NSView *)controlView untilMouseUp:(BOOL)untilMouseUp
{
	return [super trackMouse:theEvent inRect:cellFrame ofView:controlView untilMouseUp:NO];
}

- (BOOL)startTrackingAt:(NSPoint)startPoint inView:(NSView *)controlView
{	
	[self setPressed:YES];
	[[self controlView] setNeedsDisplay:YES];
	return YES;
}

- (BOOL)continueTracking:(NSPoint)lastPoint at:(NSPoint)currentPoint inView:(NSView *)controlView
{
	return YES;
}

- (void)stopTracking:(NSPoint)lastPoint at:(NSPoint)stopPoint inView:(NSView *)controlView mouseIsUp:(BOOL)flag
{
	[self setPressed:NO];
	[[self controlView] setNeedsDisplay:YES];
}


#pragma mark Actions
- (NSMutableAttributedString *)attributedTitle
{
	if(attributedTitle) return attributedTitle;

	NSMutableAttributedString *attrTitle = attributedTitle;
	
	switch([self bezelStyle])
	{
		case PARecessedBezelStyle:;
			attrTitle = [[NSMutableAttributedString alloc] initWithString:[self title]];
			[attrTitle addAttribute:NSFontAttributeName
						      value:[NSFont boldSystemFontOfSize:11]
						      range:NSMakeRange(0, [attrTitle length])];
			break;
		case PATokenBezelStyle:;
			attrTitle = [[NSMutableAttributedString alloc] initWithString:[self title]];
			[attrTitle addAttribute:NSFontAttributeName
						      value:[NSFont systemFontOfSize:[self fontSize]]
						      range:NSMakeRange(0, [attrTitle length])];
			break;
	}
	
	return attrTitle;
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

- (BOOL)isPressed
{
	return pressed;
}

- (void)setPressed:(BOOL)flag
{
	pressed = flag;
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

- (NSColor *)bezelColor
{
	return bezelColor;
}

- (void)setBezelColor:(NSColor *)aBezelColor
{
	if(bezelColor) [bezelColor release];
	bezelColor = [aBezelColor retain];
}

- (NSColor *)bezelBorderColor
{
	return bezelBorderColor;
}

- (void)setBezelBorderColor:(NSColor *)aBorderColor
{
	if(bezelBorderColor) [bezelBorderColor release];
	bezelBorderColor = [aBorderColor retain];
}

- (PAButtonType)buttonType
{
	return buttonType;
}

- (void)setButtonType:(PAButtonType)type
{
	buttonType = type;
}

- (int)fontSize
{
	return fontSize;
}

- (void)setFontSize:(int)aFontSize
{
	fontSize = aFontSize;
}

- (NSSize)cellSize
{
	NSSize size = NSMakeSize(0,0);
	NSSize labelSize = [[self attributedTitle] size];
	
	if([self isBordered])
	{	
		switch([self bezelStyle])
		{
			case PARecessedBezelStyle:;	
				size.width = labelSize.width + 2 * PADDING_RECESSEDBEZELSTYLE.width;				
				size.height = HEIGHT_RECESSEDBEZELSTYLE_SMALL;				
				break;			
			case PATokenBezelStyle:;				
				size.width = labelSize.width + 2 * PADDING_TOKENBEZELSTYLE.width;
				size.height = labelSize.height + 2 * PADDING_TOKENBEZELSTYLE.height;
				break;
		}
	} else {
		// TODO: Set size to image size
	}
	
	return size;
}

@end
