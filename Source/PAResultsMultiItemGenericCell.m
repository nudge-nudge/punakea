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
- (id)initTextCell:(PATaggableObject *)anItem
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


#pragma mark Class methods
/*+ (NSSize)cellSize
{
	return NSMakeSize(0, 0);
}

+ (NSSize)intercellSpacing
{
	return NSMakeSize(0, 0);
}*/


#pragma mark Accessors
- (PATaggableObject *)item
{
	return item;
}

- (void)setItem:(PATaggableObject *)anItem
{
	if(item) [item release];
	item = [anItem retain];
}

@end
