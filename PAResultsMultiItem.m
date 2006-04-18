//
//  PAResultsMultiItem.m
//  punakea
//
//  Created by Daniel on 15.04.06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "PAResultsMultiItem.h"


@implementation PAResultsMultiItem

#pragma mark Init + Dealloc
- (id)init
{
	self = [super init];
	if (self)
	{
		items = [[NSMutableArray alloc] init];
		tag = [[NSMutableDictionary alloc] init];
	}	
	return self;
}

- (void)dealloc
{
	if(items) [items release];
	if(tag) [tag release];
	[super dealloc];
}


#pragma mark Accessors
- (NSArray *)items
{
	return items;
}

- (void)setItems:(NSArray *)theItems
{
	items = [theItems retain];
}

- (NSDictionary *)tag
{
	return tag;
}

- (void)setTag:(NSDictionary *)aTag
{
	tag = [aTag retain];
}

// TODO: - (int)heightOfItem

@end
