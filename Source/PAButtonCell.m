//
//  PAButtonCell.m
//  punakea
//
//  Created by Daniel on 07.08.06.
//  Copyright 2006 nudge:nudge. All rights reserved.
//

#import "PAButtonCell.h"


NSSize const PADDING_RECESSEDBEZELSTYLE = {8,0};
NSSize const PADDING_TAGBEZELSTYLE = {10,2};
NSSize const MARGIN_TAGBEZELSTYLE = {5,3};

int const HEIGHT_RECESSEDBEZELSTYLE_SMALL = 15;


@interface PAButtonCell (PrivateAPI)

- (void)commonInit;

- (void)drawRecessedButtonWithFrame:(NSRect)cellFrame inView:(NSView *)controlView;
- (void)drawTagButtonWithFrame:(NSRect)cellFrame inView:(NSView *)controlView;

@end


@implementation PAButtonCell

#pragma mark Init + Dealloc
- (id)initImageCell:(NSImage *)anImage
{	
	self = [super initImageCell:anImage];
	if(self)
	{
		images = [[NSMutableDictionary alloc] init];
		//if (anImage) [self setImage:anImage forState:PAOffState];
		
		[self commonInit];
	}	
	return self;
}

- (id)initTextCell:(NSString *)aText
{	
	self = [super initTextCell:aText];
	if(self)
	{
		[self setTitle:aText];
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
	[self setSelectedBezelColor:[NSColor alternateSelectedControlColor]];
	[self setFontSize:11];
	
	tag = [[NSMutableDictionary alloc] init];
}

- (void)dealloc
{
	if(bezelColor) [bezelColor release];
	if(selectedBezelColor) [selectedBezelColor release];
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
			case PATagBezelStyle:
				[self drawTagButtonWithFrame:cellFrame inView:controlView]; break;
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
	NSShadow *shdw = [[NSShadow alloc] init];
	
	NSSize shadowOffset;
	if([controlView isFlipped]) { shadowOffset = NSMakeSize(0,-1.5); } else { shadowOffset = NSMakeSize(0,1.5); }
	[shdw setShadowOffset:shadowOffset];
	[shdw setShadowColor:shadowColor];
	[label addAttribute:NSShadowAttributeName
				  value:shdw
				  range:NSMakeRange(0, [label length])];
	[shdw release];
	
	NSMutableParagraphStyle *paraStyle = [[[NSParagraphStyle defaultParagraphStyle] mutableCopy] autorelease];
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
		if([controlView isFlipped]) [bezelImage setFlipped:YES];
		
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

- (void)drawTagButtonWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
	NSMutableAttributedString *label = [self attributedTitle];
	
	// Set colors
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
	NSMutableParagraphStyle *paraStyle = [[[NSParagraphStyle defaultParagraphStyle] mutableCopy] autorelease];
	[paraStyle setLineBreakMode:NSLineBreakByTruncatingMiddle];
	[paraStyle setAlignment:NSCenterTextAlignment];
	[label addAttribute:NSParagraphStyleAttributeName
				  value:paraStyle
				  range:NSMakeRange(0, [label length])];
	
	NSSize padding = PADDING_TAGBEZELSTYLE;
	
	// Move cellFrame if showsCloseIcon
	NSRect originalCellFrame = cellFrame;
	if([self showsCloseIcon])
	{
		if([controlView isFlipped])
			cellFrame.origin.y += MARGIN_TAGBEZELSTYLE.height;

		cellFrame.origin.x += MARGIN_TAGBEZELSTYLE.width;
		cellFrame.size.width -= MARGIN_TAGBEZELSTYLE.width;
		cellFrame.size.height -= MARGIN_TAGBEZELSTYLE.height;
	}
	
	// Add bezel
	if([self isHighlighted] || [self isHovered] || [self isPressed] || [self isSelected])
	{
		NSColor *outerBezelColor;
		if([self isHighlighted] || [self isPressed])
			outerBezelColor = [self selectedBezelColor];
		else if([self isHovered])
			outerBezelColor = [bezelColor blendedColorWithFraction:0.55 ofColor:[self selectedBezelColor]];
		else
			outerBezelColor = [bezelColor blendedColorWithFraction:0.4 ofColor:[self selectedBezelColor]];
		
		NSBezierPath *bezel = [NSBezierPath bezierPathWithRoundRectInRect:cellFrame radius:20.0];
		[bezel setLineWidth:1.1];
		[outerBezelColor set];
		[bezel fill];
		
		if(!([self isHighlighted] || [self isPressed]))
		{
			// Draw inner bezel
			NSColor *innerBezelColor = bezelColor;
			if([self isHovered])
				innerBezelColor = [bezelColor blendedColorWithFraction:0.15 ofColor:[self selectedBezelColor]];
			
			bezel = [NSBezierPath bezierPathWithRoundRectInRect:NSInsetRect(cellFrame, 1.0, 1.0) radius:20.0];
			[innerBezelColor set];
			[bezel fill];
		}
	}
	
	[label drawInRect:NSInsetRect(cellFrame, padding.width, padding.height)];
	
	// Draw close icon
	if([self showsCloseIcon] && ([self isHovered] || [self isPressed]))
	{
		NSImage *icon;
		if([self isPressed] && trackingInsideCloseIcon)
			icon = [NSImage imageNamed:@"sl-status_stop-pressed"];
		else
			icon = [NSImage imageNamed:@"sl-status_stop"];

		if([controlView isFlipped]) [icon setFlipped:YES];
		NSRect iconRect;
		iconRect.origin = NSZeroPoint;
		iconRect.size = [icon size];
		
		NSPoint targetPoint;
		if([controlView isFlipped])
			targetPoint = NSZeroPoint;
		else
			targetPoint = NSMakePoint(0, originalCellFrame.size.height - 1);
		
		[icon drawAtPoint:targetPoint fromRect:iconRect operation:NSCompositeSourceOver fraction:1.0];
	}
}


#pragma mark Mouse Tracking
- (BOOL)trackMouse:(NSEvent *)theEvent inRect:(NSRect)cellFrame ofView:(NSView *)controlView untilMouseUp:(BOOL)untilMouseUp
{
	if([self showsCloseIcon] && [self bezelStyle] == PATagBezelStyle)
	{
		NSPoint location = [controlView convertPoint:[theEvent locationInWindow] fromView:nil];
		
		NSRect iconRect;
		if([controlView isFlipped])
			iconRect.origin = NSZeroPoint;
		else
			iconRect.origin = NSMakePoint(0, cellFrame.size.height - 1);
		iconRect.size = NSMakeSize(13, 13);
		
		if(NSPointInRect(location, iconRect))
		{
			if(!defaultAction) defaultAction = [self action];
			[self setAction:closeAction];
			trackingInsideCloseIcon = YES;
		} else {
			if(defaultAction) [self setAction:defaultAction];
			trackingInsideCloseIcon = NO;
		}
	}

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
	if(attributedTitle)
	{
		return attributedTitle;
	}
	else
	{
		attributedTitle = [[NSMutableAttributedString alloc] initWithString:[self title]];
		
		switch([self bezelStyle])
		{
			case PARecessedBezelStyle:;
				[attributedTitle addAttribute:NSFontAttributeName
								  value:[NSFont boldSystemFontOfSize:11]
								  range:NSMakeRange(0, [attributedTitle length])];
				break;
			case PATagBezelStyle:;
				[attributedTitle addAttribute:NSFontAttributeName
								  value:[NSFont systemFontOfSize:[self fontSize]]
								  range:NSMakeRange(0, [attributedTitle length])];
				break;
		}
			
		return attributedTitle;
	}
}


#pragma mark Accessors
- (NSString *)title
{
	return title;
}

- (void)setTitle:(NSString *)aTitle
{
	[title release];
	[aTitle retain];
	title = aTitle;
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

- (void)select:(BOOL)flag
{
	selected = flag;
}

- (BOOL)isSelected
{
	return selected;
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

- (void)setBezelColor:(NSColor *)color
{
	if(bezelColor) [bezelColor release];
	bezelColor = [color retain];
}

- (NSColor *)selectedBezelColor
{
	return selectedBezelColor;
}

- (void)setSelectedBezelColor:(NSColor *)color
{
	if(selectedBezelColor) [selectedBezelColor release];
	selectedBezelColor = [color retain];
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

- (void)setFontSize:(int)size
{
	fontSize = size;
}

- (BOOL)showsCloseIcon
{
	return showsCloseIcon;
}

- (void)setShowsCloseIcon:(BOOL)flag
{
	showsCloseIcon = flag;
}

- (void)setAction:(SEL)aSelector
{
	[super setAction:aSelector];
}

- (SEL)closeAction
{
	return closeAction;
}

- (void)setCloseAction:(SEL)action
{
	closeAction = action;
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
			case PATagBezelStyle:;				
				size.width = labelSize.width + 2 * PADDING_TAGBEZELSTYLE.width;
				size.height = labelSize.height + 2 * PADDING_TAGBEZELSTYLE.height;
				
				// Enlarge cellFrame if showsCloseIcon
				if([self showsCloseIcon])
				{
					size.width += MARGIN_TAGBEZELSTYLE.width;
					size.height += MARGIN_TAGBEZELSTYLE.height;
				}
				
				break;
		}
	} else {
		// TODO: Set size to image size
	}
	
	return size;
}

@end
