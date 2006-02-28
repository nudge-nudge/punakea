/* TaggerViewController */

#import <Cocoa/Cocoa.h>
#import "PATagger.h"
#import "PATag.h"

@interface TaggerViewController : NSWindowController {
    IBOutlet NSTextField *filePath;
    IBOutlet NSTextField *tagList;
	PATagger *tagger;
}
- (IBAction)setTagsForFile:(id)sender;
@end
