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
#import "PASplitView.h"

#import "PASourcePanelController.h"

#import "NNFilterEngine.h"
#import "PAStringPrefixFilter.h"
#import "PAContentTypeFilter.h"
#import "PADropManager.h"


typedef enum _PATagCloudSortKey {
	PATagCloudNameSortKey = 0,
	PATagCloudRatingSortKey = 1
} PATagCloudSortKey;


@class PATagCloud;


extern float const SPLITVIEW_PANEL_MIN_HEIGHT;


@interface BrowserViewController : PAViewController <NNBVCServerProtocol>
{
	IBOutlet PATagCloud					*tagCloud;
	IBOutlet PASplitView				*splitView;
	IBOutlet NSView						*controlledView;
			
	PABrowserViewMainController			*mainController;
	
	NNTags								*tags;
	
	NSMutableArray						*visibleTags;			/**< holds the (filtered) tags for TagCloud */
	NNTag								*currentBestTag;		/**< holds the tag with the highest absolute rating currently in visibleTags */
	
	IBOutlet PATypeAheadView			*typeAheadView;
	IBOutlet NSSearchField				*searchField;
	NSString							*searchFieldString;
			
	NNFilterEngine						*filterEngine;
	NSConnection						*filterEngineConnection;
	PAStringPrefixFilter				*activePrefixFilter;
	NSArray								*activeContentTypeFilters;
	BOOL								filterEngineIsWorking;
	
	NSArray								*contentTypeFilterIdentifiers;
	
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

- (void)setSearchFieldString:(NSString*)string;

- (void)searchForTag:(NNTag*)aTag;
- (void)searchForTags:(NSArray*)someTags;

- (void)manageTags;
- (void)showResults;

- (void)switchMainControllerTo:(PABrowserViewMainController*)controller;

- (void)reset;
- (void)resetToEmptyCloud;

- (void)unbindAll;

- (void)reloadData;

- (PATagCloud *)tagCloud;
- (NSArray *)allTags; /**< needed by tagcloud - this will be gone as soon as the tag cloud is a proper view and has no app logic anymore*/

- (NSArray*)activeContentTypeFilters;
- (void)setActiveContentTypeFilters:(NSArray*)filters;
- (void)removeAllFilters;

- (NSArray*)contentTypeFilterIdentifiers;
- (void)setContentTypeFilterIdentifiers:(NSArray*)identifiers;

@end
