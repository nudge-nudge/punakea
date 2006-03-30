#import "PATagButton.h"

@implementation PATagButton

/**
designated initializer
 */
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

/**
should be overridden according to apple docs
 */
+ (Class) cellClass
{
    return [PATagButtonCell class];
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
