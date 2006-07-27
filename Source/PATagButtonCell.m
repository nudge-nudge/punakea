#import "PATagButtonCell.h"

@interface PATagButtonCell (PrivateAPI)

- (void)drawHoverEffectWithFrame:(NSRect)cellFrame;
- (void)setTitleColor:(NSColor*)color;

@end

@implementation PATagButtonCell

#pragma mark init
- (id)initWithTag:(PATag*)aTag attributes:(NSDictionary*)attributes markRange:(NSRange)range
{
	if (self = [super init])
	{
		[self setAction:@selector(tagButtonClicked:)];
		[self setFileTag:aTag];

		//title
		NSMutableAttributedString *titleString = [[NSMutableAttributedString alloc] initWithString:[fileTag name] attributes:attributes];
		
		//mark typeAheadBuffer
		//TODO externalize
		NSColor *markColor = [NSColor redColor];
		[titleString addAttribute:NSForegroundColorAttributeName value:markColor range:range];
		[self setAttributedTitle:titleString];
		[titleString release];
		
		//looks
		[self setBordered:NO];
		
		//state
		[self setHovered:NO];
	}
	return self;
}

#pragma mark drawing
- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
	if (isHovered)
	{
		[self drawHoverEffectWithFrame:cellFrame];
	}	
	
	[super drawInteriorWithFrame:cellFrame inView:controlView];
}

- (void)drawHoverEffectWithFrame:(NSRect)cellFrame
{
	[[NSColor blueColor] set];
	[[NSBezierPath bezierPathWithRoundRectInRect:cellFrame radius:5.0] fill];
}

#pragma mark accessors
- (PATag*)fileTag
{
	return fileTag;
}

- (void)setFileTag:(PATag*)aTag
{
	[aTag retain];
	[fileTag release];
	fileTag = aTag;
}

- (BOOL)isHovered
{
	return isHovered;
}

- (void)setHovered:(BOOL)flag
{	
	isHovered = flag;
}

- (void)setTitleAttributes:(NSDictionary*)attributes  markRange:(NSRange)range;
{
	NSMutableAttributedString *titleString = [[NSMutableAttributedString alloc] initWithString:[fileTag name] attributes:attributes];
	// TODO externalize!
	NSColor *markColor = [NSColor redColor];
	[titleString addAttribute:NSForegroundColorAttributeName value:markColor range:range];
	[self setAttributedTitle:titleString];
	[titleString release];
}

#pragma mark highlighting
- (void)mouseEntered:(NSEvent *)event
{
	//[self setHovered:YES];

	/*
	PATagButton *button = [self controlView];
	[[button superview] setActiveButton:button];
	[[button superview] setNeedsDisplay:YES];
	 */
}

- (void)mouseExited:(NSEvent *)event
{
	//[self setHovered:NO];
}

@end
