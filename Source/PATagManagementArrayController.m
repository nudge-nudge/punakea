//
//  PATagManagementArrayController.m
//  punakea
//
//  Created by Johannes Hoffart on 26.08.06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "PATagManagementArrayController.h"


@implementation PATagManagementArrayController

- (void)remove:(id)sender
{
	NSArray *tags = [self selectedObjects];
	[controller removeTags:tags];
	[super remove:sender];
}

@end
