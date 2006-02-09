#import "SubViewController.h"
#import "Controller.h"


@implementation SubViewController

// This method initializes a new instance of this class which loads in nibs and facilitates the communcation between the nib and the controller of the main window.
-(id)initWithNibName:(NSString*)nibName andOwner:(id)owner{
    self = [super init];
    if(self)
	{
			_owner = owner;  // Here we store a pointer to the object's owner.  
						 // This is normally not done because it hinders
						 // code reusability but this class is for a specific 
						 // purpose.
		[NSBundle loadNibNamed:nibName owner:self];
	}
    return self;
}

// This method releases the pointer to the view in the nib.
- (void)dealloc{
    [super dealloc];
    [view release];
}

// This method returns a pointer to the view in the nib loaded.
-(NSView*)view{
	return view;
    }
	
@end
