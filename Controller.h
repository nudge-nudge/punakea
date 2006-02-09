/* Controller */

#import <Cocoa/Cocoa.h>
#import "PATaggerInterface.h"

@interface Controller : NSWindowController
{
    IBOutlet id drawer;
    IBOutlet NSTextField *textfieldDaniel;
    IBOutlet NSTextField *textfieldJohannes;
	NSView *sidebarNibView;
	PATaggerInterface *ti;
}
- (IBAction)danielTest:(id)sender;
- (IBAction)hoffartTest:(id)sender;
@end
