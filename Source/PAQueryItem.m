//
//  PAQueryItem.m
//  punakea
//
//  Created by Daniel on 31.07.06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "PAQueryItem.h"


@implementation PAQueryItem

#pragma mark Init + Dealloc
- (id)init
{
	self = [super init];
	if(self)
	{
		valueDict = [[NSMutableDictionary alloc] init];
	}
	return self;
}

- (void)dealloc
{
	if(valueDict) [valueDict release];
	[super dealloc];
}


#pragma mark NSCopying
/*- (id)copyWithZone:(NSZone *)zone
{
	PAQueryItem *newItem = [[[self class] allocWithZone:zone] init];
	newItem->valueDict = [valueDict retain];
}*/


#pragma mark Actions
- (NSString *)stringValue
{
	return [valueDict objectForKey:@"value"];
}


#pragma mark Accessors
- (NSString *)valueForAttribute:(NSString *)attribute
{
	[valueDict objectForKey:attribute];
}

- (void)setValue:(NSString *)value forAttribute:(NSString *)attribute
{
	[valueDict setObject:value forKey:attribute];
}

@end
