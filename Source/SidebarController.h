#import <Cocoa/Cocoa.h>
#import "PATagging/PATag.h"
#import "TaggerController.h"
#import "PAFileBox.h"
#import "PASidebarTableViewDropController.h"
#import "PATagTextFieldCell.h"
#import "PARecentTagGroup.h"
#import "PAPopularTagGroup.h"
#import "PADropManager.h"

@interface SidebarController : NSWindowController {
	PATags *tags;
	
	PARecentTagGroup *recentTagGroup;
	PAPopularTagGroup *popularTagGroup;
	
	PADropManager *dropManager;
	
	IBOutlet PAFileBox *fileBox;
	
    IBOutlet NSArrayController *popularTags;
    IBOutlet NSArrayController *recentTags;
	
	IBOutlet NSTableView *popularTagsTable;
	IBOutlet NSTableView *recentTagsTable;
	
	PASidebarTableViewDropController *popularTagTableController;
	PASidebarTableViewDropController *recentTagTableController;
	
	TaggerController *taggerController; /**< there is at most one instance at any time */
}

- (void)newTaggableObjectsHaveBeenDropped;

@end
