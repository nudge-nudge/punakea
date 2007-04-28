//
//  BrowserController.h
//  punakea
//
//  Created by Johannes Hoffart on 04.07.06.
//  Copyright 2006 nudge:nudge. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "BrowserViewController.h"
#import "NNTagging/NNQuery.h"
#import "PATagCloud.h"
#import "PAStatusBar.h"
#import "PASimpleStatusBarButton.h"

@interface BrowserController : NSWindowController 
{
	
	BrowserViewController			*browserViewController;
	
	IBOutlet NSView					*mainPlaceholderView;
	IBOutlet NSSplitView			*verticalSplitView;
	
	IBOutlet PAStatusBar			*sourcePanelStatusBar;

}

- (BrowserViewController*)browserViewController;

@end
