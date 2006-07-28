#import "PATagButton.h"

@implementation PATagButton
- (id)initWithTag:(PATag*)tag rating:(float)aRating
{
    self = [super initWithFrame:NSMakeRect(0,0,0,0)];
    if (self) 
	{
		[self setCell:[[PATagButtonCell alloc] initWithTag:tag rating:aRating]];
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

#pragma mark functionality
- (PATag*)fileTag
{
	return [[self cell] fileTag];
}

- (void)setFileTag:(PATag*)aTag
{
	[[self cell] setFileTag:aTag];
}

#pragma mark accessors
- (BOOL)isHovered
{
	return [[self cell] isHovered];
}

- (void)setHovered:(BOOL)flag
{
	[[self cell] setHovered:flag];
}

- (void)setRating:(float)aRating
{
	[[self cell] setRating:aRating];
}

@end
