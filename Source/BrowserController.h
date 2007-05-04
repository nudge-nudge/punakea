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

@interface BrowserController : NSWindowController 
{
	
	IBOutlet PATagSetPanel			*tagSetPanel;
	
	BrowserViewController			*browserViewController;
	
	IBOutlet NSView					*mainPlaceholderView;
	IBOutlet NSSplitView			*verticalSplitView;
	
	IBOutlet PAStatusBar			*sourcePanelStatusBar;
	IBOutlet PASourcePanel			*sourcePanel;

}

- (IBAction)confirmSheet:(id)sender;
- (IBAction)cancelSheet:(id)sender;

- (BrowserViewController*)browserViewController;

@end
