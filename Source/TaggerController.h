/* TaggerController */

#import <Cocoa/Cocoa.h>
#import "PATagAutocompleteWindowController.h"
#import "NNTagging/NNTaggableObject.h"
#import "PATypeAheadFind.h"
#import "PADropManager.h"
#import "PATaggerItemCell.h"
#import "PATaggerHeaderCell.h"
#import "PAThumbnailItem.h"

@interface TaggerController : PATagAutocompleteWindowController
{	
	IBOutlet NSTableView		*tableView;
	
	PATaggerItemCell			*fileCell;
	PATaggerHeaderCell			*headerCell;
	
	NSMutableArray				*items;

	PADropManager				*dropManager;
	
}

- (void)addTaggableObject:(NNTaggableObject *)anObject;
- (void)addTaggableObjects:(NSArray *)theObjects;
- (void)setTaggableObjects:(NSArray *)theObjects;

@end
