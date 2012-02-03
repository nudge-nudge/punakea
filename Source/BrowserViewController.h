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
#import "PAViewController.h"

#import "PATypeAheadFind.h"
#import "PATypeAheadView.h"
#import "PABrowserViewMainController.h"
#import "PATagManagementViewController.h"
#import "PAResultsViewController.h"
#import "TaggerController.h"
#import "PASplitView.h"

#import "PATitleBarSearchButton.h"

#import "PASourcePanelController.h"

#import "NNFilterEngine/NNFilterEngine.h"
#import "PAStringFilter.h"
#import "PAStringPrefixFilter.h"
#import "PAContentTypeFilter.h"
#import "PADropManager.h"

#import "PATagCloudProtocols.h"

#import "NNTagging/NNSimpleQueryFilter.h"
#import "NNTagging/NNMultipleAttributesQueryFilter.h"

#import "lcl.h"

@class PATagCloud;

typedef enum _PATagCloudSortKey {
	PATagCloudNameSortKey = 0,
	PATagCloudRatingSortKey = 1
} PATagCloudSortKey;

typedef enum _PASearchType {
	PATagPrefixSearchType = 0,
	PATagSearchType = 1,
	PAFullTextSearchType = 2
} PASearchType;

extern CGFloat const SPLITVIEW_PANEL_MIN_HEIGHT;


@interface BrowserViewController : PAViewController <PATagCloudDelegate, PATagCloudDataSource, NNFilterEngineDelegate, NSTextFieldDelegate>
{
	IBOutlet PATagCloud					*tagCloud;
	IBOutlet PASplitView				*splitView;
	IBOutlet NSView						*controlledView;
	IBOutlet NSMenu						*tagButtonContextualMenu;
			
	PABrowserViewMainController			*mainController;
	
	NNTags								*tags;
	
	NSMutableArray						*activeTags;			/**< holds al the active tags for TagCloud */
	NSMutableArray						*visibleTags;			/**< holds the (filtered) tags for TagCloud */
	
	IBOutlet PATypeAheadView			*typeAheadView;
	NSSearchField						*searchField;
			
	NSOperationQueue					*filterEngineOpQueue;
	BOOL								filterEngineIsWorking;
	
	NSArray								*contentTypeFilterIdentifiers;
	
	PATagCloudSortKey					sortKey;
	NSSortDescriptor					*sortDescriptor;
	
	NSMutableArray						*fulltextQueryFilters;	// We use multiple filters in order to adress cases of search strings with whitespaces in between, e.g. "term1 term2" results in two filters.
}

/** 
delegate method, use this another class needs to update the tag cloud
@param someTags tags to be displayed
*/
- (void)setDisplayTags:(NSMutableArray*)someTags; 

/**
use this method to reset the display tags to all available tags
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

- (void)setSearchField:(NSSearchField*)aSearchField;

- (void)searchForTags:(NSArray*)someTags;

- (void)manageTags;
- (void)showResults;

- (void)switchMainControllerTo:(PABrowserViewMainController*)controller;

- (void)reset;

- (void)reloadData;

// Tag Cloud actions
- (IBAction)includeTag:(id)sender;
- (IBAction)excludeTag:(id)sender;
- (IBAction)editTag:(id)sender;
// --

- (PATagCloud *)tagCloud;
- (NSMenu *)tagButtonContextualMenu;

- (void)setContentTypeFilterIdentifiers:(NSArray*)identifiers;

- (NSArray *)allTags; /**< needed by tagcloud - this will be gone as soon as the tag cloud is a proper view and has no app logic anymore*/

@end
