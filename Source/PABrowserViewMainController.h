//
//  PABrowserViewMainController.h
//  punakea
//
//  Created by Johannes Hoffart on 24.09.06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PATag.h"
#import "PAViewController.h"

@interface PABrowserViewMainController : PAViewController {
	id delegate;
	BOOL working;
}

- (NSView*)mainView;
- (void)handleTagActivation:(PATag*)tag;
- (id)delegate;
- (void)setDelegate:(id)anObject;
- (BOOL)isWorking;
- (void)setWorking:(BOOL)flag;

@end