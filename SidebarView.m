#import "SidebarView.h"

@implementation SidebarView

- (id)initWithFrame:(NSRect)frameRect
{
	if ((self = [super initWithFrame:frameRect]) != nil) {
		[self setNextResponder:tableView];
	}
	return self;
}

- (void)drawRect:(NSRect)rect
{
}

@end
