//
//  PAQueryItem.m
//  punakea
//
//  Created by Daniel on 31.07.06.
//  Copyright 2006 nudge:nudge. All rights reserved.
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
- (id)copyWithZone:(NSZone *)zone
{
	PAQueryItem *newItem = [[[self class] allocWithZone:zone] init];
	newItem->valueDict = [valueDict retain];
	
	return newItem;
}


#pragma mark Comparing
- (BOOL)isEqual:(id)object
{
	return [self isEqualTo:object];
}

- (BOOL)isEqualTo:(id)object
{
	if(self == object) return YES;
	if(![object isMemberOfClass:[self class]]) return NO;

	return [[self valueForAttribute:(id)kMDItemPath] isEqualTo:[object valueForAttribute:(id)kMDItemPath]];
}


#pragma mark Actions
- (NSString *)stringValue
{
	return [valueDict objectForKey:@"value"];
}


#pragma mark Accessors
- (id)valueForAttribute:(NSString *)attribute
{
	return [valueDict objectForKey:attribute];
}

- (void)setValue:(NSString *)value forAttribute:(NSString *)attribute
{
	[valueDict setObject:value forKey:attribute];
}

@end
