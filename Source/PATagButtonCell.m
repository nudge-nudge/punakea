#import "PATagButtonCell.h"

int const MIN_FONT_SIZE = 12;
int const MAX_FONT_SIZE = 25;

@interface PATagButtonCell (PrivateAPI)

- (void)drawHoverEffectWithFrame:(NSRect)cellFrame;
- (void)buildTitle;

@end

@implementation PATagButtonCell

#pragma mark init
- (id)initWithTag:(PATag*)aTag rating:(float)aRating
{
	if (self = [super init])
	{
		[self setAction:@selector(tagButtonClicked:)];
		[self setFileTag:aTag];
		[self setRating:aRating];
		
		//looks
		[self setBordered:NO];
		
		//state
		[self setHovered:NO];
		
		[self buildTitle];
	}
	return self;
}

#pragma mark drawing
- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
	[self drawInteriorWithFrame:cellFrame inView:controlView];
}


- (void)drawInteriorWithFrame:(NSRect)cellFrame inView:(NSView*)controlView
{
	if ([self isHovered])
	{	
		[self drawHoverEffectWithFrame:cellFrame];
	}
	
	//TODO drawing error
	[[self attributedTitle] drawInRect:cellFrame];
}

- (void)drawHoverEffectWithFrame:(NSRect)cellFrame
{
	[[NSColor selectedControlColor] set];
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
	return hovered;
}

- (void)setHovered:(BOOL)flag
{	
	hovered = flag;
	[self buildTitle];
}

- (float)rating
{
	return rating;
}

- (void)setRating:(float)aRating
{
	rating = aRating;
	[self buildTitle];
}

- (void)buildTitle
{
	NSString *tagName = [fileTag name];
	
	// Attributed string for value
	NSMutableAttributedString *titleString = [[[NSMutableAttributedString alloc] initWithString:tagName] autorelease];
	
	// determine fontSize
	int fontSize = MAX_FONT_SIZE * [self rating];
	if (fontSize < MIN_FONT_SIZE)
		fontSize = MIN_FONT_SIZE;
	
	[titleString addAttribute:NSFontAttributeName
				  value:[NSFont systemFontOfSize:fontSize]
				  range:NSMakeRange(0, [titleString length])];
	
	if ([self isHovered])
	{
		[titleString addAttribute:NSForegroundColorAttributeName
					  value:[NSColor selectedTextColor]
					  range:NSMakeRange(0, [titleString length])];
	} 
	else 
	{
		[titleString addAttribute:NSForegroundColorAttributeName
					  value:[NSColor textColor]
					  range:NSMakeRange(0, [titleString length])];
	}
	
	BrowserViewController *controller = [[[self controlView] superview] controller];
	
	// if controller is set, check buffer for prefix coloring
	if (controller && [[controller buffer] length] > 0)
	{
		// TODO externalize
		NSColor *markColor = [NSColor redColor];
		[titleString addAttribute:NSForegroundColorAttributeName value:markColor range:NSMakeRange(0,[[controller buffer] length])];
	}
	
	NSMutableParagraphStyle *paraStyle = [[[NSParagraphStyle defaultParagraphStyle] mutableCopy] autorelease];
	[paraStyle setAlignment:NSCenterTextAlignment];
	[titleString addAttribute:NSParagraphStyleAttributeName
						value:paraStyle
						range:NSMakeRange(0, [titleString length])];
	
	[self setAttributedTitle:titleString];
}

#pragma mark highlighting
- (void)mouseEntered:(NSEvent *)event
{
	NSLog(@"entered");

	//TODO check if visible
	NSScrollView *scrollView = [[self controlView] enclosingScrollView];
	PATagButton *button = [self controlView];

	if (scrollView && NSIntersectsRect([button frame],[scrollView documentVisibleRect]))
	{
		[[button superview] setActiveButton:button];
	}
}

- (void)mouseExited:(NSEvent *)event
{
	//nothing
}

@end
