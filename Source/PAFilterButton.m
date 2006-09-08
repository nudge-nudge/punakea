//
//  PAFilterButton.m
//  punakea
//
//  Created by Daniel on 06.09.06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "PAFilterButton.h"


@implementation PAFilterButton

#pragma mark Init + Dealloc
- (id)initWithFrame:(NSRect)frame
{
	self = [super initWithFrame:frame];
	if(self)
	{
		filter = [[NSMutableDictionary alloc] init];
	}	
	return self;
}

- (void)dealloc
{
	if(filter) [filter release];
	[super dealloc];
}

#pragma mark Accessors
- (NSDictionary *)filter
{
	return filter;
}

- (void)setFilter:(NSDictionary *)dictionary
{
	if(filter) [filter release];
	filter = [dictionary mutableCopy];
}

@end
