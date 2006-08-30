//
//  PATagCloudController.h
//  punakea
//
//  Created by Johannes Hoffart on 29.03.06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "BrowserViewController.h"

/**
controller for the tagCloud
 */
@interface BrowserViewController (PATagCloudController)

/**
is called when a tag is clicked. increments the tag click count and
 adds to selectedTags
 */
- (IBAction)tagButtonClicked:(id)sender;

@end
