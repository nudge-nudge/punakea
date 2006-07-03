#import "PATagButtonCell.h"

@implementation PATagButtonCell

#pragma mark init
- (id)initWithTag:(PATag*)aTag attributes:(NSDictionary*)attributes
{
	if (self = [super init])
	{
		[self setAction:@selector(tagButtonClicked:)];
		[self setFileTag:aTag];

		//title
		NSAttributedString *titleString = [[NSAttributedString alloc] initWithString:[fileTag name] attributes:attributes];
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
	if ([self isHovered])
	{
		[[NSColor redColor] set];
		[NSBezierPath fillRect:cellFrame];
	}
	else
	{
		[[NSColor whiteColor] set];
		[NSBezierPath fillRect:cellFrame];
	}
	[super drawInteriorWithFrame:cellFrame inView:controlView];
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
	if (isHovered != flag)
	{
		//TODO
	}
	isHovered = flag;
}

#pragma mark highlighting
- (void)mouseEntered:(NSEvent *)event
{
	[self setHovered:YES];
	NSLog(@"enter");
}

- (void)mouseExited:(NSEvent *)event
{
	[self setHovered:NO];
	NSLog(@"exit");
}

@end
