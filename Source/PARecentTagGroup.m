//
//  PARecentTagGroup.m
//  punakea
//
//  Created by Johannes Hoffart on 18.09.06.
//  Copyright 2006 nudge:nudge. All rights reserved.
//

#import "PARecentTagGroup.h"


@implementation PARecentTagGroup

- (id)init
{
	if (self = [super init])
	{
		NSSortDescriptor *recentDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"lastUsed" ascending:NO] autorelease];
		NSArray *recentSortDescriptors = [NSArray arrayWithObject:recentDescriptor];
		[self setSortDescriptors:recentSortDescriptors];
		
		[self tagsHaveChanged];
	}
	
	return self;
}

@end
