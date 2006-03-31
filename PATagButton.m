#import "PATagButton.h"

@implementation PATagButton

/**
designated initializer
 */
- (id)initWithFrame:(NSRect)frame Tag:(PATag*)tag 
{
    self = [super initWithFrame:frame];
    if (self) {
		[self setCell:[[PATagButtonCell alloc] initWithTag:tag]];
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

// TODO this is a hack, so that the view behind doesn't get redrawn
- (BOOL)isOpaque
{
	return YES;
}

@end
