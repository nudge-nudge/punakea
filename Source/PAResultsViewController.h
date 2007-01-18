//
//  PAResultsViewController.h
//  punakea
//
//  Created by Johannes Hoffart on 26.09.06.
//  Copyright 2006 nudge:nudge. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PABrowserViewMainController.h"

#import "NNTagging/NSFileManager+TrashFile.h"

#import "NNTagging/PATags.h"
#import "NNTagging/PATag.h"
#import "NNTagging/PARelatedTags.h"
#import "NNTagging/PASelectedTags.h"
#import "NNTagging/PAQuery.h"

#import "PAResultsOutlineView.h"
#import "PADropManager.h"
#import "PATagButton.h"
#import "PAThumbnailItem.h"

@interface PAResultsViewController : PABrowserViewMainController {
	
	IBOutlet PAResultsOutlineView		*outlineView;
	IBOutlet NSProgressIndicator		*progressIndicator;
	
	PATags								*tags;
	PARelatedTags						*relatedTags;
	PASelectedTags						*selectedTags;
	
	PADropManager						*dropManager;
	PAQuery								*query;
	
	NSNotificationCenter				*nc;
	
	NSArray								*draggedItems;
}

- (void)handleTagActivation:(PATag*)tag;

- (PARelatedTags*)relatedTags;
- (void)setRelatedTags:(PARelatedTags*)otherRelatedTags;
- (PASelectedTags*)selectedTags;
- (void)setSelectedTags:(PASelectedTags*)otherSelectedTags;

- (void)removeLastTag;

- (NSArray*)draggedItems;
- (void)setDraggedItems:(NSArray*)someItems;

- (PAQuery *)query;

- (IBAction)clearSelectedTags:(id)sender;

- (IBAction)setGroupingAttributes:(id)sender;

- (void)deleteDraggedItems;
- (void)deleteFilesForVisibleSelectedItems:(id)sender;

- (PAResultsOutlineView *)outlineView;

//- (NSArray *)selectedItems;
//- (NSArray *)selectedItems:(id)sender;

@end
