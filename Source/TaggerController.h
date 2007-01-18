/* TaggerController */

#import <Cocoa/Cocoa.h>
#import "NNTagging/PATaggableObject.h"
#import "NNTagging/PATags.h"
#import "NNTagging/PARelatedTagsStandalone.h"
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
	
	PASelectedTags				*currentCompleteTagsInField; /**< holds the relevant tags of tagField (as a copy) */
	NSString					*restDisplayString;

	PATypeAheadFind				*typeAheadFind;
	PADropManager				*dropManager;
	
	PATags						*globalTags;
}

- (void)addTaggableObject:(PATaggableObject *)anObject;
- (void)addTaggableObjects:(NSArray *)theObjects;

- (PASelectedTags*)currentCompleteTagsInField;
- (void)setCurrentCompleteTagsInField:(PASelectedTags*)newTags;

@end
