// Copyright (c) 2006-2011 nudge:nudge (Johannes Hoffart & Daniel Bär). All rights reserved.
// 
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

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

@class Core;


@interface PAResultsViewController : PABrowserViewMainController {
	
	IBOutlet PAResultsOutlineView		*outlineView;
	IBOutlet NSButton					*groupingButton;
	
	IBOutlet NSPopUpButton				*sortingButton;
	NSSortDescriptor					*sortDescriptor;
	NSImage								*sortAscIcon;
	NSImage								*sortDescIcon;
	
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
