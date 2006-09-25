//
//  PABrowserViewMainController.h
//  punakea
//
//  Created by Johannes Hoffart on 24.09.06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PATag.h"

@protocol PABrowserViewMainController

- (NSView*)mainView;
- (void)handleTagActivation:(PATag*)tag;
- (BOOL)isWorking;

@end