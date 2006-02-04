#import "Controller.h"
#import "SubViewController.h"

@implementation Controller

- (void)awakeFromNib
{
	sidebarNibView = [[self viewFromNibWithName:@"Sidebar"] retain];
	[drawer setContentView:sidebarNibView];
	[drawer toggle:self];
}

-(NSView*)viewFromNibWithName:(NSString*)nibName{
    NSView * 		newView;
    SubViewController *	subViewController;
    
    subViewController = [SubViewController alloc];
    // Creates an instance of SubViewController which loads the specified nib.
    [subViewController initWithNibName:nibName andOwner:self];
    newView = [subViewController view];
    return newView;
}
@end
