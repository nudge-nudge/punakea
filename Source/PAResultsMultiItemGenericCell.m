//
//  PAResultsMultiItemGenericCell.m
//  punakea
//
//  Created by Daniel on 24.10.06.
//  Copyright 2006 nudge:nudge. All rights reserved.
//

#import "PAResultsMultiItemGenericCell.h"


@implementation PAResultsMultiItemGenericCell

#pragma mark Init + Dealloc
- (id)initTextCell:(PAQueryItem *)anItem
{
	self = [super initTextCell:@""];
	if (self)
	{
		item = [anItem retain];	
	}	
	return self;
}

- (void)dealloc
{
	if(item) [item release];
	[super dealloc];
}


#pragma mark Accessors
- (PAQueryItem *)item
{
	return item;
}

- (void)setItem:(PAQueryItem *)anItem
{
	if(item) [item release];
	item = [anItem retain];
}

@end
