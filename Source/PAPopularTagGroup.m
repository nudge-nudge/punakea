//
//  PAPopularTagGroup.m
//  punakea
//
//  Created by Johannes Hoffart on 18.09.06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "PAPopularTagGroup.h"


@implementation PAPopularTagGroup

- (id)init
{
	if (self = [super init])
	{
		NSSortDescriptor *popularDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"absoluteRating" ascending:NO] autorelease];
		NSArray *popularSortDescriptors = [NSArray arrayWithObject:popularDescriptor];
		[self setSortDescriptors:popularSortDescriptors];
		
		[self tagsHaveChanged];
	}
	
	return self;
}

@end
