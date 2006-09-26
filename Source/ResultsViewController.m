//
//  ResultsViewController.m
//  punakea
//
//  Created by Daniel on 26.09.06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "ResultsViewController.h"


@implementation ResultsViewController

#pragma mark Init + Dealloc
- (id)init
{
	if(self = [super init])
	{
		query = [[PAQuery alloc] init];
		[query setBundlingAttributes:[NSArray arrayWithObjects:@"kMDItemContentTypeTree", nil]];
		[query setSortDescriptors:[NSArray arrayWithObject:[[[NSSortDescriptor alloc] initWithKey:(id)kMDItemFSName ascending:YES] autorelease]]];
	}
	return self;
}

- (void)dealloc
{
	if(query) [query release];
	[super dealloc];
}

// TODO: Copy data source and delegate methods from BrowserViewController

@end
