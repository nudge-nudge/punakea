//
//  BrowserController.h
//  punakea
//
//  Created by Johannes Hoffart on 04.07.06.
//  Copyright 2006 nudge:nudge. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "BrowserViewController.h"
#import "PAQuery.h"
#import "PATagCloud.h"

@class Core;

@interface BrowserController : NSWindowController 
{
	Core							*core;
	BrowserViewController			*browserViewController;
}

- (id)initWithCore:(Core*)aCore;
- (BrowserViewController*)browserViewController;

@end
