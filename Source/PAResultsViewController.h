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

#import "NNTagging/NNTags.h"
#import "NNTagging/NNTag.h"
#import "NNTagging/NNRelatedTags.h"
#import "NNTagging/NNSelectedTags.h"
#import "NNTagging/NNQuery.h"

#import "PAResultsOutlineView.h"
#import "PADropManager.h"
#import "PATagButton.h"
#import "PAThumbnailItem.h"

@interface PAResultsViewController : PABrowserViewMainController {
	
	IBOutlet PAResultsOutlineView		*outlineView;
	IBOutlet NSProgressIndicator		*progressIndicator;
	
	NNTags								*tags;
	NNRelatedTags						*relatedTags;
	NNSelectedTags						*selectedTags;
	
	PADropManager						*dropManager;
	NNQuery								*query;
	
	NSNotificationCenter				*nc;
	
	NSArray								*draggedItems;
}

- (void)handleTagActivation:(NNTag*)tag;

- (NNRelatedTags*)relatedTags;
- (void)setRelatedTags:(NNRelatedTags*)otherRelatedTags;
- (NNSelectedTags*)selectedTags;
- (void)setSelectedTags:(NNSelectedTags*)otherSelectedTags;

- (void)removeLastTag;

- (NSArray*)draggedItems;
- (void)setDraggedItems:(NSArray*)someItems;

- (NNQuery *)query;

- (IBAction)clearSelectedTags:(id)sender;

- (IBAction)setGroupingAttributes:(id)sender;

- (void)deleteDraggedItems;
- (void)deleteFilesForVisibleSelectedItems:(id)sender;

- (PAResultsOutlineView *)outlineView;

//- (NSArray *)selectedItems;
//- (NSArray *)selectedItems:(id)sender;

@end
