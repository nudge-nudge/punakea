#import "PATagButton.h"

@implementation PATagButton

- (id)initWithFrame:(NSRect)frame Tag:(PATag*)tag 
{
    self = [super initWithFrame:frame];
    if (self) {
		PATagButtonCell *cell = [[PATagButtonCell alloc] initWithTag:tag];
		[self setCell:cell];
		[cell release];
    }
    return self;
}

- (PATag*)fileTag
{
	return [[self cell] fileTag];
}

- (void)setFileTag:(PATag*)aTag
{
	[[self cell] setFileTag:aTag];
}

@end
