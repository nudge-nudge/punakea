//
//  PAStringFilter.m
//  punakea
//
//  Created by Johannes Hoffart on 11.01.10.
//  Copyright 2010 nudge:nudge. All rights reserved.
//

#import "PAStringFilter.h"


@implementation PAStringFilter

#pragma mark init
- (id)initWithFilter:(NSString*)filterString
{
	if (self = [super init])
	{
		weight = 1;
		filter = [[filterString lowercaseString] copy];
	}
	return self;
}

- (void)dealloc
{
	[filter release];
	[super dealloc];
}

#pragma mark accessors
- (NSString*)filter
{
	return filter;
}

#pragma mark function
- (void)filterObject:(id)object
{
	NSString *tagName = [object name];
	
	if (!NSEqualRanges([tagName rangeOfString:filter options:(NSCaseInsensitiveSearch | NSDiacriticInsensitiveSearch)], 
					   NSMakeRange(NSNotFound,0)))
	{
		[self objectFiltered:object];
	}
}

- (NSString*)description
{
	return [NSString stringWithFormat:@"StringFilter: %@",filter];
}

@end
