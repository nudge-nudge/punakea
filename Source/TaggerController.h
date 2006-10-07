/* TaggerController */

#import <Cocoa/Cocoa.h>
#import "PATags.h"
#import "PATagger.h"
#import "PARelatedTagsStandalone.h"
#import "PATypeAheadFind.h"
#import "PADropManager.h"

@interface TaggerController : NSWindowController
{	
	IBOutlet NSTableView *tableView;
	IBOutlet NSTokenField *tagField; /**< shows tags which are on all selected files */
	
	IBOutlet NSArrayController *fileController;
	
	PASelectedTags *currentCompleteTagsInField; /**< holds the relevant tags of tagField (as a copy) */
	NSString *restDisplayString;

	PATagger *tagger;
	PATags *tags; /**< reference to all tags (same as in controller) */
	
	PATypeAheadFind *typeAheadFind;
	PADropManager *dropManager;
}

- (id)initWithWindowNibName:(NSString*)windowNibName;

/**
adds new files to the fileController
 @param newFiles files to add
 */
- (void)addFiles:(NSMutableArray*)newFiles;
- (NSArray*)files;

- (void)setRestDisplayString:(NSString*)aString;

- (PASelectedTags*)currentCompleteTagsInField;
- (void)setCurrentCompleteTagsInField:(PASelectedTags*)newTags;

@end
