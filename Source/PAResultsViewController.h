//
//  PAResultsViewController.h
//  punakea
//
//  Created by Johannes Hoffart on 26.09.06.
//  Copyright 2006 nudge:nudge. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PABrowserViewMainController.h"

#import "NNTagging/NSFileManager+Extensions.h"

#import "NNTagging/NNTags.h"
#import "NNTagging/NNTag.h"
#import "NNTagging/NNRelatedTags.h"
#import "NNTagging/NNSelectedTags.h"
#import "NNTagging/NNQuery.h"
#import "NNTagging/NNContentTypeTreeQueryFilter.h"

#import "PAResultsOutlineView.h"
#import "PADropManager.h"
#import "PATagButton.h"
#import "PAThumbnailItem.h"

#import "FVColorMenuView.h"
#import "FVFinderLabel.h"


@interface PAResultsViewController : PABrowserViewMainController {
	
	IBOutlet PAResultsOutlineView		*outlineView;
	IBOutlet NSButton					*groupingButton;
	
	NNTags								*tags;
	NNRelatedTags						*relatedTags;
	NNSelectedTags						*selectedTags;
	
	IBOutlet NSMenuItem					*colorLabelMenuItem;
	
	BOOL								bundleQueryResults;
	
	PADropManager						*dropManager;
	NNQuery								*query;
	
	NSArray								*draggedItems;
}

- (void)handleTagActivation:(NNTag*)tag;

- (NNRelatedTags*)relatedTags;
- (void)setRelatedTags:(NNRelatedTags*)otherRelatedTags;
- (NNSelectedTags*)selectedTags;
- (void)setSelectedTags:(NNSelectedTags*)otherSelectedTags;

- (IBAction)emptySelectedTags:(id)senders;

- (void)removeLastTag;

- (NSArray*)draggedItems;
- (void)setDraggedItems:(NSArray*)someItems;

- (NNQuery *)query;

- (IBAction)setGroupingAttributes:(id)sender;
- (void)arrangeBy:(NSString*)type;

- (IBAction)changeFinderLabel:(id)sender;

- (void)deleteDraggedItems;
- (IBAction)deleteFilesForSelectedItems:(id)sender;
- (IBAction)openFiles:(id)sender;
- (IBAction)revealInFinder:(id)sender;
- (IBAction)getInfo:(id)sender;

- (PAResultsOutlineView *)outlineView;

@end
