/* TaggerController */

#import <Cocoa/Cocoa.h>
#import "TagAutoCompleteController.h"
#import "NNTagging/NNTaggableObject.h"
#import "PATypeAheadFind.h"
#import "PADropManager.h"
#import "PATaggerItemCell.h"
#import "PATaggerHeaderCell.h"
#import "PAThumbnailItem.h"
#import "PAStatusBar.h"
#import "NSImage+QuickLook.h"

@interface TaggerController : NSWindowController
{	
	IBOutlet NSTableView				*tableView;
	IBOutlet NSImageView				*quickLookPreviewImage;
	
	IBOutlet NSButton					*manageFilesButton;
	
	IBOutlet TagAutoCompleteController	*tagAutoCompleteController;
	
	NSArray								*initialTags;						/**< Tags that are present before editing. */
	
	BOOL								manageFiles;
	BOOL								manageFilesAutomatically;
	BOOL								showsManageFiles;
	
	PATaggerItemCell					*fileCell;
	
	NSMutableArray						*taggableObjects;

	PADropManager						*dropManager;
	
}

- (void)addTaggableObject:(NNTaggableObject *)anObject;
- (void)addTaggableObjects:(NSArray *)theObjects;
- (void)setTaggableObjects:(NSArray *)theObjects;
- (void)removeTaggableObjects:(id)sender;

- (IBAction)changeManageFilesFlag:(id)sender;
- (IBAction)confirmTags:(id)sender;

- (void)setManageFiles:(BOOL)flag;
- (void)setShowsManageFiles:(BOOL)flag;
- (BOOL)isEditingTagsOnFiles;

@end
