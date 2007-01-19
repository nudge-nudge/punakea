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
- (id)initTextCell:(NNTaggableObject *)anItem
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
- (NNTaggableObject *)item
{
	return item;
}

- (void)setItem:(NNTaggableObject *)anItem
{
	if(item) [item release];
	item = [anItem retain];
}

@end
