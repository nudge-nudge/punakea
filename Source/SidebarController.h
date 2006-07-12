#import <Cocoa/Cocoa.h>
#import "PATag.h"
#import "PATagger.h"
#import "TaggerController.h"
#import "PAFileBox.h"
#import "PASidebarTableViewDropController.h"
#import "PASidebarTagCell.h"

@interface SidebarController : NSWindowController {
	PATagger *tagger;
	PATags *tags;
	
	IBOutlet PAFileBox *fileBox;
	
    IBOutlet NSArrayController *popularTags;
    IBOutlet NSArrayController *recentTags;
	
	IBOutlet NSTableView *popularTagsTable;
	IBOutlet NSTableView *recentTagsTable;
	
	PASidebarTableViewDropController *popularTagTableController;
	PASidebarTableViewDropController *recentTagTableController;
	
	TaggerController *taggerController; /**< there is at most one instance at any time */
}

- (void)newFilesHaveBeenDropped;

@end