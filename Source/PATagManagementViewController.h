//
//  PATagManagementViewController.h
//  punakea
//
//  Created by Johannes Hoffart on 13.07.06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PAViewController.h"
#import "PABrowserViewMainController.h"
#import "PATagger.h"
#import "PATags.h"

@interface PATagManagementViewController : PAViewController <PABrowserViewMainController> {
	id delegate;
	IBOutlet NSTextField *tagNameField;
	
	PATag *currentEditedTag;
	
	PATagger *tagger;
	PATags *tags;
	
	BOOL working;
}

- (void)handleTagActivation:(PATag*)tag;

- (id)delegate;
- (void)setDelegate:(id)anObject;
- (PATag*)currentEditedTag;
- (void)setCurrentEditedTag:(PATag*)aTag;
- (BOOL)isWorking;
- (void)setWorking:(BOOL)flag;

- (IBAction)removeTag:(id)sender;

@end
