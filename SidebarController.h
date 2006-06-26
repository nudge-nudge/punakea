#import <Cocoa/Cocoa.h>
#import "Controller.h"
#import "PATag.h"
#import "PATagger.h"
#import "TaggerController.h"
#import "PAFileBox.h"
#import "PATableViewDropController.h"
#import "PASidebarTagCell.h"

@interface SidebarController : NSWindowController {
	PATagger *tagger;
	
	IBOutlet PAFileBox *fileBox;
	
    IBOutlet Controller *controller; /**< tag controller for all tags */
    IBOutlet NSArrayController *popularTags;
    IBOutlet NSArrayController *recentTags;
	
	IBOutlet NSTableView *popularTagsTable;
	IBOutlet NSTableView *recentTagsTable;
	
	PATableViewDropController *popularTagTableController;
	PATableViewDropController *recentTagTableController;
	
	TaggerController *taggerController; /**< there is at most one instance at any time */
}

- (void)newFilesHaveBeenDropped;

@end
