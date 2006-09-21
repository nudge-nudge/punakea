//
//  PATagManagementArrayController.h
//  punakea
//
//  Created by Johannes Hoffart on 26.08.06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PATagManagementViewController.h"
#import "PATag.h"

@interface PATagManagementArrayController : NSArrayController {
	IBOutlet PATagManagementViewController *controller;
}

@end
