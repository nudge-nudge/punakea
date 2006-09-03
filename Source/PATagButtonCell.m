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
	[self setHighlighted:flag];
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
}

@end
