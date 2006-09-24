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
#import "PAQueryBundle.h"
#import "PAQueryItem.h"
#import "PATypeAheadFind.h"
#import "PAResultsOutlineView.h"
#import "PATypeAheadView.h"
#import "PAViewController.h"
#import "PABrowserViewMainControllerProtocol.h"

@class PATagCloud;

@interface BrowserViewController : PAViewController {
	IBOutlet PATagCloud *tagCloud;
	IBOutlet PAResultsOutlineView *outlineView;
	IBOutlet PATypeAheadView *typeAheadView;
		
	PAViewController <PABrowserViewMainControllerProtocol> *mainController;
	
	PATagger *tagger;
	PATags *tags;
	
	PARelatedTags *relatedTags;
	PASelectedTags *selectedTags;
	
	PATag *currentBestTag; /**< holds the tag with the highest absolute rating currently in visibleTags */
	
	NSMutableArray *visibleTags; /**< holds tags for TagCloud */
	
	PATypeAheadFind *typeAheadFind; /**< used for type ahead find */
	
	PAQuery *query;
	
	// buffer for user input (browser)
	NSString *buffer;
	
	NSMutableDictionary *tagCloudSettings;
	
	NSNotificationCenter *nc;
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

- (NSString*)buffer;
- (void)setBuffer:(NSString*)string;

//for PAQuery
- (PAQuery *)query;
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context;

/**
is called when a tag is clicked. increments the tag click count and
 adds to selectedTags
 */
- (IBAction)tagButtonClicked:(id)sender;

- (IBAction)clearSelectedTags:(id)sender;

- (void)resetBuffer;

// Temp
- (IBAction)setGroupingAttributes:(id)sender;

// tag management
- (void)manageTags;

@end
