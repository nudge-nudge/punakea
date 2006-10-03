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

extern NSString * const PATagManagementOperation;
extern NSString * const PATagManagementRenameOperation;
extern NSString * const PATagManagementRemoveOperation;

@interface PATagManagementViewController : PABrowserViewMainController {
	IBOutlet NSTextField *tagNameField;
	
	IBOutlet NSView *simpleTagManagementView;
	
	PATag *currentEditedTag;
	
	PATagger *tagger;
	PATags *tags;
}

- (PATag*)currentEditedTag;
- (void)setCurrentEditedTag:(PATag*)aTag;
- (BOOL)isWorking;

- (IBAction)renameOperation:(id)sender;
- (IBAction)removeOperation:(id)sender;

- (void)removeEditedTag;
- (void)renameEditedTagTo:(NSString*)newTagName;

- (IBAction)endTagManagement:(id)sender;

@end
