//
//  PATagManagementViewController.h
//  punakea
//
//  Created by Johannes Hoffart on 13.07.06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PABrowserViewMainController.h"
#import "PATagger.h"
#import "PATags.h"
#import "PATag.h"

@interface PATagManagementViewController : PABrowserViewMainController {
	IBOutlet NSTextField *tagNameField;
	
	IBOutlet NSView *simpleTagManagementView;
	IBOutlet NSView *currentView;
	
	PATag *currentEditedTag;
	
	PATagger *tagger;
	PATags *tags;
}

- (NSView*)currentView;
- (void)setCurrentView:(NSView*)aView;

- (PATag*)currentEditedTag;
- (void)setCurrentEditedTag:(PATag*)aTag;
- (BOOL)isWorking;

- (IBAction)removeTag:(id)sender;
- (void)renameTag:(PATag*)oldTag toTagName:(NSString*)newTagName;

@end
