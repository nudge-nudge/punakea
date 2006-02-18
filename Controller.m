#import "Controller.h"
#import "SubViewController.h"
#import "PATaggerInterface.h"
#import "FileGroup.h"

@implementation Controller

- (void)awakeFromNib
{
	[self setupToolbar];
	
	sidebarNibView = [[self viewFromNibWithName:@"Sidebar"] retain];
	[drawer setContentView:sidebarNibView];
	[drawer toggle:self];
	
	//hoffart test code
	ti = [PATaggerInterface new];
}

- (void)setupToolbar
{
    NSToolbar *toolbar = [[NSToolbar alloc] initWithIdentifier:@"mainToolbar"];
    [toolbar setDelegate:self];
    [toolbar setAllowsUserCustomization:YES];
    [toolbar setAutosavesConfiguration:YES];
    [[self window] setToolbar:[toolbar autorelease]];
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

-(IBAction)hoffartTest:(id)sender {
	[ti addTagToFile:[textfieldJohannes stringValue] filePath:@"/Users/darklight/Desktop/punakea_test"];
}

// For OutlineView Bindings
- (id) init
{
    if (self = [super init])
    {
        fileGroups = [[NSMutableArray alloc] init];
		myString = @"My String";
    }
    return self;
}

- (void) dealloc
{
    [fileGroups release];
    
    [super dealloc];
}

/*- (void) setFileGroups: (NSArray *)newFileGroups
{
    if (fileGroups != newFileGroups)
    {
        [fileGroups autorelease];
        fileGroups = [[NSMutableArray alloc] initWithArray: newFileGroups];
    }
}*/
@end
