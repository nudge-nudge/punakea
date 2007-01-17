/* TaggerController */

#import <Cocoa/Cocoa.h>
#import "PATagging/PATags.h"
#import "PATagging/PARelatedTagsStandalone.h"
#import "PATypeAheadFind.h"
#import "PADropManager.h"
#import "PAFileCell.h"
#import "PATaggerHeaderCell.h"
#import "PAThumbnailItem.h"

@interface TaggerController : NSWindowController
{	
	IBOutlet NSTableView		*tableView;
	
	PAFileCell					*fileCell;
	PATaggerHeaderCell			*headerCell;
	
	IBOutlet NSTokenField		*tagField; /**< shows tags which are on all selected files */
	
	IBOutlet NSArrayController	*taggableObjectController;
	
	PASelectedTags				*currentCompleteTagsInField; /**< holds the relevant tags of tagField (as a copy) */
	NSString					*restDisplayString;

	PATypeAheadFind				*typeAheadFind;
	PADropManager				*dropManager;
	
	PATags						*globalTags;
}

/**
adds new files to the fileController
 @param newFiles files to add
 */
- (void)addTaggableObjects:(NSArray*)objects;
- (NSArray*)taggableObjects;

- (PASelectedTags*)currentCompleteTagsInField;
- (void)setCurrentCompleteTagsInField:(PASelectedTags*)newTags;

@end
