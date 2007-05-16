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


@interface BrowserController : NSWindowController 
{
	
	IBOutlet PATagSetPanel						*tagSetPanel;
	
	BrowserViewController						*browserViewController;
	
	IBOutlet NSView								*mainPlaceholderView;
	IBOutlet PASplitView						*verticalSplitView;
	IBOutlet PASplitView						*horizontalSplitView;
	
	IBOutlet PAStatusBar						*sourcePanelStatusBar;
	IBOutlet PASourcePanel						*sourcePanel;
	IBOutlet PATabPanel							*tabPanel;
	
	NSTabView									*infoPane;
	IBOutlet NSView								*infoPanePlaceholderView;
	IBOutlet PAInfoPaneSingleSelectionView		*infoPaneSingleSelectionView;
	IBOutlet PAInfoPaneMultipleSelectionView	*infoPaneMultipleSelectionView;

}

- (IBAction)confirmSheet:(id)sender;
- (IBAction)cancelSheet:(id)sender;

- (BrowserViewController*)browserViewController;
- (PASplitView *)verticalSplitView;
- (PASplitView *)horizontalSplitView;
- (PAStatusBar *)sourcePanelStatusBar;
- (PASourcePanel *)sourcePanel;

@end
