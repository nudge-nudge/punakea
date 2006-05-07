#import <Cocoa/Cocoa.h>
#import "Controller.h"
#import "PATag.h"
#import "PATagger.h"
#import "PAFileBox.h"
#import "PATableViewDropController.h"

@interface SideViewController : NSWindowController {
	PATagger *tagger;
	
	IBOutlet PAFileBox *fileBox;
	IBOutlet NSTextField *tagField;
	
    IBOutlet Controller *controller; /**< tag controller for all tags */
    IBOutlet NSArrayController *popularTags;
    IBOutlet NSArrayController *recentTags;
    IBOutlet NSArrayController *fileTags;
	
	IBOutlet NSTableView *popularTagsTable;
	IBOutlet NSTableView *recentTagsTable;
	
	PATableViewDropController *popularTagTableController;
	PATableViewDropController *recentTagTableController;
}

- (void)controlTextDidEndEditing:(NSNotification *)aNotification;
- (void)newFilesHaveBeenDropped;

- (void)addPopularTag;
- (void)addRecentTag;
- (void)removeTagFromFile;

@end
