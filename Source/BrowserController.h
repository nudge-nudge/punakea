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
#import "BrowserViewController.h"
#import "NNTagging/NNTag.h"
#import "NNTagging/NNTagSet.h"
#import "NNTagging/NNTags.h"
#import "NNTagging/NNQuery.h"
#import "PATagCloud.h"
#import "PAStatusBar.h"
#import "PAStatusBarButton.h"
#import "PASourcePanel.h"
#import "PASourceItem.h"
#import "PASourcePanelController.h"
#import "PATagSetPanel.h"
#import "PASplitView.h"
#import "PATabPanel.h"
#import "PAInfoPaneSubview.h"
#import "PAInfoPaneSingleSelectionView.h"
#import "PAInfoPaneMultipleSelectionView.h"
#import "PATagsPaneTagsView.h"
#import "PADropManager.h"

extern NSString * const FILENAME_FAVORITES_PLIST;
extern NSUInteger const VERSION_FAVORITES_PLIST;


@interface BrowserController : NSWindowController 
{
	
	IBOutlet PATagSetPanel						*tagSetPanel;
	
	BrowserViewController						*browserViewController;
	
	IBOutlet NSView								*rightContentView;			/**< Contains mainPlaceholderView and a status bar */
	IBOutlet NSView								*mainPlaceholderView;		/**< Placeholder for the view that BrowserViewController provides */
	
	IBOutlet PASplitView						*verticalSplitView;
	IBOutlet PASplitView						*horizontalSplitView;
	
	IBOutlet PAStatusBar						*rightStatusBar;
	PAStatusBarProgressIndicator				*statusBarProgressIndicator;
	
	IBOutlet PAStatusBar						*sourcePanelStatusBar;
	
	NSTextView									*sourcePanelFieldEditor;
	
	IBOutlet PASourcePanel						*sourcePanel;
	IBOutlet PATabPanel							*tabPanel;
	
	NSTabView									*infoPane;					/**< A pane may contain multiple tabs like placeholder view, single selection view, multiple selection view, ... */
	IBOutlet NSView								*infoPanePlaceholderView;
	IBOutlet PAInfoPaneSingleSelectionView		*infoPaneSingleSelectionView;
	IBOutlet PAInfoPaneMultipleSelectionView	*infoPaneMultipleSelectionView;
	NSTabView									*tagsPane;					/**< A pane may contain multiple tabs like quick drop view, tags view, ... */
	IBOutlet NSView								*tagsPanePlaceholderView;
	IBOutlet PATagsPaneTagsView					*tagsPaneTagsView;
	
	NSSearchField								*searchField;

}

- (IBAction)confirmSheet:(id)sender;
- (IBAction)cancelSheet:(id)sender;

- (IBAction)editTagSet:(id)sender;
- (IBAction)addTagSet:(id)sender;
- (IBAction)removeTagSet:(id)sender;

- (void)toggleInfoPane:(id)sender;
- (void)toggleTagsPane:(id)sender;

- (BOOL)infoPaneIsVisible;
- (BOOL)tagsPaneIsVisible;

- (void)saveFavorites;

- (void)startProgressAnimationWithDescription:(NSString *)aString;
- (void)stopProgressAnimation;

- (BrowserViewController*)browserViewController;
- (PASplitView *)verticalSplitView;
- (PASplitView *)horizontalSplitView;
- (PAStatusBar *)sourcePanelStatusBar;
- (PAStatusBar *)rightStatusBar;
- (PASourcePanel *)sourcePanel;

@end
