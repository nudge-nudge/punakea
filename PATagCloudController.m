//
//  PATagCloudController.m
//  punakea
//
//  Created by Johannes Hoffart on 29.03.06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "PATagCloudController.h"


@implementation Controller (PATagCloudController)

- (IBAction)tagButtonClicked:(id)sender
{
	PATag *tag = [sender fileTag];
	[selectedTagsController addObject:tag];
	[tag incrementClickCount];
}

@end
