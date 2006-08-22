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
	if (self = [super initTextCell:[aTag name]])
	{
		[self setAction:@selector(tagButtonClicked:)];
		[self setFileTag:aTag];
		[self setRating:aRating];
		
		//state
		[self setSelected:NO];
	}
	return self;
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

- (BOOL)isSelected
{
	return selected;
}

- (void)setSelected:(BOOL)flag
{	
	selected = flag;
}

- (float)rating
{
	return rating;
}

- (void)setRating:(float)aRating
{
	rating = aRating;
	
	int newFontSize = MAX_FONT_SIZE * [self rating];
	if (newFontSize < MIN_FONT_SIZE)
		newFontSize = MIN_FONT_SIZE;
	
	[self setFontSize:newFontSize];
	
	// TODO [self buildTitle];
}

/*
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
*/

@end
