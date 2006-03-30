#import "PATagButtonCell.h"

@implementation PATagButtonCell

#pragma mark init

- (id)initWithTag:(PATag*)aTag
{
	if (self = [super init])
	{
		[self setAction:@selector(tagButtonClicked:)];
		[self setFileTag:aTag];
		[self setTitle:[aTag name]];
	}
	return self;
}

#pragma mark drawing
/*
- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
	NSLog(@"%@: draw main",fileTag);
	[super drawWithFrame:cellFrame inView:controlView];
}

- (void)drawInteriorWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
	NSLog(@"%@: draw interior",fileTag);
	[super drawInteriorWithFrame:cellFrame inView:controlView];
}
*/

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
