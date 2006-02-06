/* Controller */

#import <Cocoa/Cocoa.h>
#import "TaggerInterface.h"

@interface Controller : NSWindowController
{
    IBOutlet id drawer;
	NSView *sidebarNibView;
	TaggerInterface *ti;
}

-(IBAction)hoffartTest:(id)sender;

@end