/* Controller */

#import <Cocoa/Cocoa.h>
#import "PATaggerInterface.h"

@interface Controller : NSWindowController
{
    IBOutlet id drawer;
	NSView *sidebarNibView;
	PATaggerInterface *ti;
}

-(IBAction)hoffartTest:(id)sender;

@end