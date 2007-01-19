/* TaggerController */

#import <Cocoa/Cocoa.h>
#import "NNTagging/NNTaggableObject.h"
#import "NNTagging/NNTags.h"
#import "NNTagging/NNRelatedTagsStandalone.h"
#import "PATypeAheadFind.h"
#import "PADropManager.h"
#import "PATaggerItemCell.h"
#import "PATaggerHeaderCell.h"
#import "PAThumbnailItem.h"

@interface TaggerController : NSWindowController
{	
	IBOutlet NSTableView		*tableView;
	
	PATaggerItemCell			*fileCell;
	PATaggerHeaderCell			*headerCell;
	
	IBOutlet NSTokenField		*tagField; /**< shows tags which are on all selected files */
	
	NSMutableArray				*items;
	
	NNSelectedTags				*currentCompleteTagsInField; /**< holds the relevant tags of tagField (as a copy) */
	NSString					*restDisplayString;

	PATypeAheadFind				*typeAheadFind;
	PADropManager				*dropManager;
	
	NNTags						*globalTags;
}

- (void)addTaggableObject:(NNTaggableObject *)anObject;
- (void)addTaggableObjects:(NSArray *)theObjects;

- (NNSelectedTags*)currentCompleteTagsInField;
- (void)setCurrentCompleteTagsInField:(NNSelectedTags*)newTags;

@end
