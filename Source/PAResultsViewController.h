//
//  PAResultsViewController.h
//  punakea
//
//  Created by Johannes Hoffart on 26.09.06.
//  Copyright 2006 nudge:nudge. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PABrowserViewMainController.h"

#import "NSFileManager+TrashFile.h"

#import "PATagger.h"
#import "PATags.h"
#import "PATag.h"
#import "PARelatedTags.h"
#import "PASelectedTags.h"
#import "PAQuery.h"
#import "PAQueryBundle.h"
#import "PAQueryItem.h"
#import "PAResultsOutlineView.h"
#import "PADropManager.h"
#import "PATagButton.h"

@interface PAResultsViewController : PABrowserViewMainController {
	
	IBOutlet PAResultsOutlineView		*outlineView;
	
	PATagger							*tagger;
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

- (PAResultsOutlineView *)outlineView;

@end
