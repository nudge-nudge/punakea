//
//  PATaggableObject.m
//  punakea
//
//  Created by Johannes Hoffart on 19.12.06.
//  Copyright 2006 nudge:nudge. All rights reserved.
//

#import "PATaggableObject.h"

NSString * const PATaggableObjectUpdate = @"PATaggableObjectUpdate";

@implementation PATaggableObject

#pragma marg init
- (id)init
{
	return [self initWithTags:[NSMutableSet set]];
}

// designated init
- (id)initWithTags:(NSSet*)someTags
{
	if (self = [super init])
	{
		globalTags = [PATags sharedTags];
		
		[self setTags:someTags];
		nc = [NSNotificationCenter defaultCenter];
	}
	return self;
}

- (void)dealloc
{
	[tags release];
	[super dealloc];
}

#pragma mark accessors
- (NSSet*)tags
{
	return tags;
}

- (void)setTags:(NSSet*)someTags
{
	[tags release];
	tags = [someTags mutableCopy];
	
	[nc postNotificationName:PATaggableObjectUpdate object:self userInfo:nil];
}

#pragma mark functionality
- (void)addTag:(PATag*)tag
{
	[tags addObject:tag];
	
	[nc postNotificationName:PATaggableObjectUpdate object:self userInfo:nil];
}

- (void)addTags:(NSArray*)someTags
{
	[tags addObjectsFromArray:someTags];
	
	[nc postNotificationName:PATaggableObjectUpdate object:self userInfo:nil];
}

- (void)removeTag:(PATag*)tag
{
	[tags removeObject:tag];
	
	[nc postNotificationName:PATaggableObjectUpdate object:self userInfo:nil];
}

- (void)removeTags:(NSArray*)someTags
{
	[tags minusSet:[NSSet setWithArray:someTags]];
	
	[nc postNotificationName:PATaggableObjectUpdate object:self userInfo:nil];
}

- (void)removeAllTags
{
	[tags removeAllObjects];
	
	[nc postNotificationName:PATaggableObjectUpdate object:self userInfo:nil];
}

- (void)saveTags
{
	// does nothing, must be implemented by subclass
	return;
}

@end
