/* TaggerViewController */

#import <Cocoa/Cocoa.h>
#import "PATaggerInterface.h"
#import "PATag.h"

@interface TaggerViewController : NSWindowController {
    IBOutlet NSTextField *filePath;
    IBOutlet NSTextField *tagList;
	PATaggerInterface *ti;
}
- (IBAction)setTagsForFile:(id)sender;
@end
