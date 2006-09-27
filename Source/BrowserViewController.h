//
//  BrowserViewController.h
//  punakea
//
//  Created by Johannes Hoffart on 27.06.06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PAViewController.h"

#import "PATypeAheadFind.h"
#import "PATypeAheadView.h"
#import "PABrowserViewMainController.h"
#import "PATagManagementViewController.h"
#import "PAResultsViewController.h"

@class PATagCloud;

@interface BrowserViewController : PAViewController {
	IBOutlet PATagCloud *tagCloud;
	IBOutlet NSView *controlledView;
		
	PABrowserViewMainController *mainController;
	
	PATagger *tagger;
	PATags *tags;
	
	NSMutableArray *visibleTags; /**< holds tags for TagCloud */
	PATag *currentBestTag; /**< holds the tag with the highest absolute rating currently in visibleTags */
	
	IBOutlet PATypeAheadView *typeAheadView;
	PATypeAheadFind *typeAheadFind; /**< used for type ahead find */
	NSString *buffer;
		
	NSMutableDictionary *tagCloudSettings;
}

// events
- (void)keyDown:(NSEvent *)event;

- (NSMutableArray*)visibleTags;
- (void)setVisibleTags:(NSMutableArray*)otherTags;
- (PATag*)currentBestTag;
- (void)setCurrentBestTag:(PATag*)otherTag;

- (NSString*)buffer;
- (void)setBuffer:(NSString*)string;
- (PABrowserViewMainController*)mainController;
- (void)setMainController:(PABrowserViewMainController*)aController;

- (NSView*)controlledView;

//for PAQuery

/**
is called when a tag is clicked. increments the tag click count and
 adds to selectedTags
 */
- (IBAction)tagButtonClicked:(id)sender;


- (void)resetBuffer;

// Temp

// tag management
- (void)manageTags;

- (void)switchMainControllerTo:(PABrowserViewMainController*)controller;

@end
