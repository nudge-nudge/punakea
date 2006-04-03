//
//  PATagCloudController.h
//  punakea
//
//  Created by Johannes Hoffart on 29.03.06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Controller.h"

/**
controller for the tagCloud
 */
@interface Controller (PATagCloudController)

/**
is called when a tag is clicked. increments the tag click count and
 adds to selectedTags
 */
- (IBAction)tagButtonClicked:(id)sender;

@end
