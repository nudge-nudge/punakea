//
//  BrowserController.h
//  punakea
//
//  Created by Johannes Hoffart on 04.07.06.
//  Copyright 2006 nudge:nudge. All rights reserved.
//

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
#import "PADropManager.h"


extern NSString * const FILENAME_FAVORITES_PLIST;
extern unsigned const VERSION_FAVORITES_PLIST;


@interface BrowserController : NSWindowController 
{
	
	IBOutlet PATagSetPanel						*tagSetPanel;
	
	BrowserViewController						*browserViewController;
	
	IBOutlet NSView								*rightContentView;			/**< Contains mainPlaceholderView and a status bar */
	IBOutlet NSView								*mainPlaceholderView;		/**< Placeholder for the view that BrowserViewController provides */
	
	IBOutlet PASplitView						*verticalSplitView;
	IBOutlet PASplitView						*horizontalSplitView;
	
	IBOutlet PAStatusBar						*rightStatusBar;
	IBOutlet PAStatusBar						*sourcePanelStatusBar;
	
	NSTextView									*sourcePanelFieldEditor;
	
	IBOutlet PASourcePanel						*sourcePanel;
	IBOutlet PATabPanel							*tabPanel;
	
	NSTabView									*infoPane;
	IBOutlet NSView								*infoPanePlaceholderView;
	IBOutlet PAInfoPaneSingleSelectionView		*infoPaneSingleSelectionView;
	IBOutlet PAInfoPaneMultipleSelectionView	*infoPaneMultipleSelectionView;
	
	NSSearchField								*searchField;

}

- (IBAction)confirmSheet:(id)sender;
- (IBAction)cancelSheet:(id)sender;

- (IBAction)editTagSet:(id)sender;
- (IBAction)removeTagSet:(id)sender;

- (void)saveFavorites;

- (BrowserViewController*)browserViewController;
- (PASplitView *)verticalSplitView;
- (PASplitView *)horizontalSplitView;
- (PAStatusBar *)sourcePanelStatusBar;
- (PASourcePanel *)sourcePanel;

@end
