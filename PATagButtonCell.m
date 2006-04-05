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
		//[self setBezelStyle:NSRecessedBezelStyle];
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

@end
