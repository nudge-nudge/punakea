/* TaggerViewController */

#import <Cocoa/Cocoa.h>
#import "PATagger.h"
#import "PATag.h"

@interface TaggerViewController : NSWindowController {
    IBOutlet NSTextField *filePath;
    IBOutlet NSArrayController *tagController;
	PATagger *tagger;
}
- (IBAction)setTagsForFile:(id)sender;
@end
