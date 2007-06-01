/* TaggerController */

#import <Cocoa/Cocoa.h>
#import "PATagAutocompleteWindowController.h"
#import "NNTagging/NNTaggableObject.h"
#import "PATypeAheadFind.h"
#import "PADropManager.h"
#import "PATaggerItemCell.h"
#import "PATaggerHeaderCell.h"
#import "PAThumbnailItem.h"
#import "PAStatusBar.h"


@interface TaggerController : PATagAutocompleteWindowController
{	
	IBOutlet NSTableView		*tableView;
	IBOutlet PAStatusBar		*statusBar;
	
	IBOutlet NSButton			*manageFilesButton;
	BOOL						manageFiles;
	BOOL						manageFilesAutomatically;
	BOOL						showsManageFiles;
	
	PATaggerItemCell			*fileCell;
	PATaggerHeaderCell			*headerCell;
	
	NSMutableArray				*items;

	PADropManager				*dropManager;
	
}

- (void)addTaggableObject:(NNTaggableObject *)anObject;
- (void)addTaggableObjects:(NSArray *)theObjects;
- (void)setTaggableObjects:(NSArray *)theObjects;

- (void)resizeTokenField;

- (IBAction)changeManageFilesFlag:(id)sender;

- (void)setManageFiles:(BOOL)flag;
- (void)setShowsManageFiles:(BOOL)flag;

@end
