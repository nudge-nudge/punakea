//
//  PAFilterButton.m
//  punakea
//
//  Created by Daniel on 06.09.06.
//  Copyright 2006 nudge:nudge. All rights reserved.
//

#import "PAFilterButton.h"


@implementation PAFilterButton

#pragma mark Init + Dealloc
- (id)initWithFrame:(NSRect)frame
{
	self = [super initWithFrame:frame];
	if(self)
	{
		[self setFilter:[NSMutableDictionary dictionary]];
	}	
	return self;
}

- (void)dealloc
{
	[filter release];
	[super dealloc];
}

#pragma mark Accessors
- (NSMutableDictionary *)filter
{
	return filter;
}

- (void)setFilter:(NSDictionary *)dictionary
{
	[filter release];
	filter = [dictionary mutableCopy];
}

@end
