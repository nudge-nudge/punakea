//
//  BrowserViewController.h
//  punakea
//
//  Created by Johannes Hoffart on 27.06.06.
//  Copyright 2006 nudge:nudge. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PAViewController.h"

#import "PATypeAheadFind.h"
#import "PATypeAheadView.h"
#import "PABrowserViewMainController.h"
#import "PATagManagementViewController.h"
#import "PAResultsViewController.h"
#import "TaggerController.h"

#import "NNFilterEngine.h"
#import "NNStringPrefixFilter.h"

typedef enum _PABrowserViewControllerState {
	PABrowserViewControllerNormalState = 1,
	PABrowserViewControllerTypeAheadFindState = 2,
	PABrowserViewControllerMainControllerState = 4
} PABrowserViewControllerState;

typedef enum _PATagCloudSortKey {
	PATagCloudNameSortKey = 0,
	PATagCloudRatingSortKey = 1
} PATagCloudSortKey;

@class PATagCloud;

extern float const SPLITVIEW_PANEL_MIN_HEIGHT;

@interface BrowserViewController : PAViewController
{
	IBOutlet PATagCloud					*tagCloud;
	IBOutlet NSSplitView				*splitView;
	IBOutlet NSView						*controlledView;
	
	PABrowserViewControllerState		state;
		
	PABrowserViewMainController			*mainController;
	
	NNTags								*tags;
	
	NSMutableArray						*visibleTags;			/**< holds the (filtered) tags for TagCloud */
	NNTag								*currentBestTag;		/**< holds the tag with the highest absolute rating currently in visibleTags */
	
	IBOutlet PATypeAheadView			*typeAheadView;
	IBOutlet NSSearchField				*searchField;
	NSString							*buffer;
			
	NNFilterEngine						*filterEngine;
	NSConnection						*filterEngineConnection;
	NNStringPrefixFilter				*activePrefixFilter;
	
	PATagCloudSortKey					sortKey;
	NSSortDescriptor					*sortDescriptor;
}

/** 
delegate method, used by browserViewMainController if it needs
to set some tags
@param someTags tags to be displayed
*/
- (void)setDisplayTags:(NSMutableArray*)someTags; 

/**
use this method to tell bvc that mainController doesn't need to
 display tags anymore
 */
- (void)resetDisplayTags;

/**
highlights tag in tagcloud
 @param tag tag to highlight
 */
- (void)displaySelectedTag:(NNTag*)tag;
- (void)removeActiveTagButton;

- (PABrowserViewMainController*)mainController;

- (NSView*)controlledView;
- (void)makeControlledViewFirstResponder;

/**
is called when a tag is clicked
 */
- (IBAction)tagButtonClicked:(id)sender;
- (IBAction)findFieldAction:(id)sender;

- (void)searchForTag:(NNTag*)aTag;
- (void)manageTags;
- (void)showResults;

- (void)switchMainControllerTo:(PABrowserViewMainController*)controller;

- (void)reset;
- (void)unbindAll;

@end
