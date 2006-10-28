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

@interface BrowserViewController : PAViewController {
	IBOutlet PATagCloud *tagCloud;
	IBOutlet NSSplitView *splitView;
	IBOutlet NSView *controlledView;
	
	PABrowserViewControllerState state;
		
	PABrowserViewMainController *mainController;
	
	PATagger *tagger;
	PATags *tags;
	
	NSMutableArray *visibleTags; /**< holds tags for TagCloud */
	PATag *currentBestTag; /**< holds the tag with the highest absolute rating currently in visibleTags */
	
	IBOutlet PATypeAheadView *typeAheadView;
	IBOutlet NSSearchField *searchField;
	PATypeAheadFind *typeAheadFind; /**< used for type ahead find */
	NSString *buffer;
		
	NSMutableDictionary *tagCloudSettings;
	
	PATagCloudSortKey sortKey;
	NSSortDescriptor *sortDescriptor;
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
 @param tag tag to highligh
 */
- (void)displaySelectedTag:(PATag*)tag;
- (void)removeActiveTagButton;

- (PABrowserViewMainController*)mainController;

- (NSView*)controlledView;
- (void)makeControlledViewFirstResponder;

/**
is called when a tag is clicked. increments the tag click count and
 adds to selectedTags
 */
- (IBAction)tagButtonClicked:(id)sender;
- (IBAction)findFieldAction:(id)sender;

- (void)manageTags;
- (void)showResults;

- (void)switchMainControllerTo:(PABrowserViewMainController*)controller;

- (void)reset;

@end
