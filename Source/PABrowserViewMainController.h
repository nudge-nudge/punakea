//
//  PABrowserViewMainController.h
//  punakea
//
//  Created by Johannes Hoffart on 24.09.06.
//  Copyright 2006 nudge:nudge. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "NNTagging/NNTag.h"
#import "PAViewController.h"

@interface NSObject (PATagManagementViewControllerDelegate)

- (void)displaySelectedTag:(NNTag*)tag;
- (NSView*)controlledView;
- (void)removeActiveTagButton;
- (void)displaySelectedTag:(NNTag*)tag;
- (void)showResults;

@end

/**
abstract class, controller for everything except tagcloud in 
 browserview
 */
@interface PABrowserViewMainController : PAViewController {
	IBOutlet NSView *currentView;
	
	id delegate;
	BOOL working;
}

- (NSView*)currentView;
- (void)setCurrentView:(NSView*)aView;
- (NSResponder*)dedicatedFirstResponder;

/**
abstract, must overwrite
 */
- (void)handleTagActivation:(NNTag*)tag;
- (void)handleTagActivations:(NSArray*)someTags;
- (id)delegate;
- (void)setDelegate:(id)anObject;
- (BOOL)isWorking;
- (void)setWorking:(BOOL)flag;

/** is called when reset is needed
	(handle escape key reset here)
	default does nothing
	*/
- (void)reset; 

@end