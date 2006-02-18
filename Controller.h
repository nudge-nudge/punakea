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
	
	// For OutlineView Bindings
	NSMutableArray *_fileGroups;
}
- (IBAction)danielTest:(id)sender;
- (IBAction)hoffartTest:(id)sender;

// For OutlineView Bindings
- (NSMutableArray *) fileGroups;
@end
