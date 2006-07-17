//
//  BrowserViewController.h
//  punakea
//
//  Created by Johannes Hoffart on 27.06.06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PAViewController.h"

#import "PATagger.h"
#import "PARelatedTags.h"
#import "PASelectedTags.h"
#import "PAQuery.h"
#import "PATypeAheadFind.h"
#import "PAResultsOutlineView.h"

@class PATagCloud;

@interface BrowserViewController : PAViewController {
	IBOutlet PATagCloud *tagCloud;
	IBOutlet PAResultsOutlineView *outlineView;
	
	PATagger *tagger;
	PATags *tags;
	
	PARelatedTags *relatedTags;
	PASelectedTags *selectedTags;
	
	PATag *currentBestTag; /**< holds the tag with the highest absolute rating currently in visibleTags */
	
	NSMutableArray *visibleTags; /**< holds tags for TagCloud */
	
	PATypeAheadFind *typeAheadFind; /**< used for type ahead find */
	
	PAQuery *query;
	
	// buffer for user input (browser)
	NSMutableString *buffer;
}

- (id)initWithNibName:(NSString*)nibName;

// events
- (void)keyDown:(NSEvent *)event;

- (PARelatedTags*)relatedTags;
- (void)setRelatedTags:(PARelatedTags*)otherRelatedTags;
- (PASelectedTags*)selectedTags;
- (void)setSelectedTags:(PASelectedTags*)otherSelectedTags;

- (NSMutableArray*)visibleTags;
- (void)setVisibleTags:(NSMutableArray*)otherTags;
- (PATag*)currentBestTag;
- (void)setCurrentBestTag:(PATag*)otherTag;

//for PAQuery
- (PAQuery *)query;
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context;

//for adding to selected
- (IBAction)clearSelectedTags:(id)sender;

// Temp
- (IBAction)setGroupingAttributes:(id)sender;

@end
