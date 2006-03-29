#import "PATagButtonCell.h"

@implementation PATagButtonCell

#pragma mark init
- (id)initWithTag:(PATag*)aTag
{
	if (self = [super init])
	{
		[self setAction:@selector(tagButtonClicked:)];
		[self setFileTag:aTag];
		[self setBordered:NO];
	}
	return self;
}

#pragma mark drawing
- (void)drawInteriorWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
	NSDictionary *attributes = [fileTag viewAttributes];
	[[fileTag name] drawInRect:cellFrame withAttributes:attributes];
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

@end
