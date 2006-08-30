//
//  PATagCloudController.m
//  punakea
//
//  Created by Johannes Hoffart on 29.03.06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "PATagCloudController.h"

@implementation BrowserViewController (PATagCloudController)

- (IBAction)tagButtonClicked:(id)sender
{
	PATag *tag = [sender fileTag];
	[selectedTags addTag:tag];
	[tag incrementClickCount];
}

@end
