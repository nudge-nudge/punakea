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
	}
	return self;
}

#pragma mark drawing
- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
	[self drawInteriorWithFrame:cellFrame inView:controlView];
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

#pragma mark highlighting
- (void)mouseEntered:(NSEvent *)event
{
	//TODO nothing yet
}

- (void)mouseExited:(NSEvent *)event
{
	//TODO nothing yet
}
@end
