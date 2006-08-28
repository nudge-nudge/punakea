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
		cellClass = [PAResultsMultiItemThumbnailCell class];
	}	
	return self;
}

- (void)dealloc
{
	if(items) [items release];
	if(tag) [tag release];
	[super dealloc];
}


#pragma mark Actions
- (BOOL)isEqual:(id)anObject
{
	return [self isEqualTo:anObject];
}

- (BOOL)isEqualTo:(id)anObject
{
	if(self == anObject)
	{
		return YES;
	} else if([self isMemberOfClass:[anObject class]])
	{
		if([[self items] isEqualTo:[anObject items]])
			return YES;
	}
	
	return NO;
}

- (void)addItem:(PAQueryItem *)anItem
{
	[items addObject:anItem];
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

- (Class)cellClass
{
	return cellClass;
}

- (void)setCellClass:(Class)class
{
	cellClass = class;
}

- (int)numberOfItems
{
	return [items count];
}

- (id)objectAtIndex:(unsigned)index
{
	return [items objectAtIndex:index];
}

// TODO: - (int)heightOfItem

@end
