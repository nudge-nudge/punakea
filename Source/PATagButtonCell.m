#import "PATagButtonCell.h"

@interface PATagButtonCell (PrivateAPI)

- (void)drawHoverEffectWithFrame:(NSRect)cellFrame;
- (void)setTitleColor:(NSColor*)color;

@end

@implementation PATagButtonCell

#pragma mark init
- (id)initWithTag:(PATag*)aTag attributes:(NSDictionary*)attributes
{
	if (self = [super init])
	{
		[self setAction:@selector(tagButtonClicked:)];
		[self setFileTag:aTag];

		//title
		[self setTitleAttributes:attributes];
		
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
	[[NSColor selectedTextBackgroundColor] set];
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

- (void)setTitleAttributes:(NSDictionary*)attributes;
{
	NSMutableAttributedString *titleString = [[NSMutableAttributedString alloc] initWithString:[fileTag name] attributes:attributes];
	BrowserViewController *controller = [[[self controlView] superview] controller];
	
	// if controller is set, check buffer for prefix coloring
	if (controller && [[controller buffer] length] > 0)
	{
		// TODO externalize
		NSColor *markColor = [NSColor redColor];
		[titleString addAttribute:NSForegroundColorAttributeName value:markColor range:NSMakeRange(0,[[controller buffer] length])];
	}
	
	[self setAttributedTitle:titleString];
	[titleString release];
}

#pragma mark highlighting
- (void)mouseEntered:(NSEvent *)event
{
	PATagButton *button = [self controlView];
	[[button superview] setActiveButton:button];
}

- (void)mouseExited:(NSEvent *)event
{
	//nothing
}

@end
