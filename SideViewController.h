#import <Cocoa/Cocoa.h>
#import "Controller.h"
#import "PATag.h"
#import "PATagger.h"
#import "PAFileBox.h"

@interface SideViewController : NSWindowController {
	PATagger *tagger;
	
	IBOutlet PAFileBox *fileBox;
	IBOutlet NSTextField *tagField;
	
    IBOutlet Controller *controller; /**< tag controller for all tags */
    IBOutlet NSArrayController *popularTags;
    IBOutlet NSArrayController *recentTags;
    IBOutlet NSArrayController *fileTags;
}

- (void)controlTextDidEndEditing:(NSNotification *)aNotification;
- (void)newFileHaveBeenDropped;

- (void)addPopularTag;
- (void)addRecentTag;
- (void)removeTagFromFile;

@end
