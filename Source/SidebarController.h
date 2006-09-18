#import <Cocoa/Cocoa.h>
#import "PATag.h"
#import "PATagger.h"
#import "TaggerController.h"
#import "PAFileBox.h"
#import "PASidebarTableViewDropController.h"
#import "PATagTextFieldCell.h"
#import "PARecentTagGroup.h"
#import "PAPopularTagGroup.h"

@interface SidebarController : NSWindowController {
	PATagger *tagger;
	PATags *tags;
	
	PARecentTagGroup *recentTagGroup;
	PAPopularTagGroup *popularTagGroup;
	
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
