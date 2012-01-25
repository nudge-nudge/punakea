// Copyright (c) 2006-2012 nudge:nudge (Johannes Hoffart & Daniel Bär). All rights reserved.
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
#import "TagAutoCompleteController.h"
#import "NNTagging/NNTaggableObject.h"
#import "NNTagging/NNTagging.h"
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
	
	IBOutlet NSTextField				*suggestionField;
	
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
