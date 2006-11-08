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
	}
	return self;
}


#pragma mark Misc
- (BOOL)trackMouse:(NSEvent *)theEvent inRect:(NSRect)cellFrame ofView:(NSView *)controlView untilMouseUp:(BOOL)untilMouseUp
{
	// Disable mouse tracking to let our button handle the dragging
	return NO;
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
