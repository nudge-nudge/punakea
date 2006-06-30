#import "PATagButton.h"

@implementation PATagButton
- (id)initWithTag:(PATag*)tag attributes:(NSDictionary*)attributes
{
	NSRect nilRect = NSMakeRect(0,0,0,0);
	return [self initWithFrame:nilRect Tag:tag attributes:attributes];
}

/**
designated initializer
 */
- (id)initWithFrame:(NSRect)frame Tag:(PATag*)tag attributes:(NSDictionary*)attributes
{
    self = [super initWithFrame:frame];
    if (self) 
	{
		[self setCell:[[PATagButtonCell alloc] initWithTag:tag attributes:attributes]];
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

// TODO this is a hack, so that the view behind doesn't get redrawn
- (BOOL)isOpaque
{
	return YES;
}
@end
