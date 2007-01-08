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
		
		retryCount = 0;
		
		nc = [NSNotificationCenter defaultCenter];
	}
	return self;
}

- (void)dealloc
{
	[self saveTags];
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

	if ([self shouldManageFiles])
		[self handleFileManagement];
	
	[nc postNotificationName:PATaggableObjectUpdate object:self userInfo:nil];
}

- (int)retryCount
{
	return retryCount;
}

- (void)incrementRetryCount
{
	retryCount++;
}

- (void)resetRetryCount
{
	retryCount = 0;
}

#pragma mark functionality
- (void)addTag:(PATag*)tag
{
	[tags addObject:tag];
	
	if ([self shouldManageFiles])
		[self handleFileManagement];
	
	[nc postNotificationName:PATaggableObjectUpdate object:self userInfo:nil];
}

- (void)addTags:(NSArray*)someTags
{
	[tags addObjectsFromArray:someTags];
	
	if ([self shouldManageFiles])
		[self handleFileManagement];
	
	[nc postNotificationName:PATaggableObjectUpdate object:self userInfo:nil];
}

- (void)removeTag:(PATag*)tag
{
	[tags removeObject:tag];
	
	if ([self shouldManageFiles])
		[self handleFileManagement];
	
	[nc postNotificationName:PATaggableObjectUpdate object:self userInfo:nil];
}

- (void)removeTags:(NSArray*)someTags
{
	[tags minusSet:[NSSet setWithArray:someTags]];
	
	if ([self shouldManageFiles])
		[self handleFileManagement];
	
	[nc postNotificationName:PATaggableObjectUpdate object:self userInfo:nil];
}

- (void)removeAllTags
{
	[tags removeAllObjects];
	
	if ([self shouldManageFiles])
		[self handleFileManagement];
	
	[nc postNotificationName:PATaggableObjectUpdate object:self userInfo:nil];
}

- (void)initiateSave
{
	[nc postNotificationName:PATaggableObjectUpdate object:self userInfo:nil];
}

- (BOOL)saveTags
{
	// does nothing, must be implemented by subclass
}

- (void)handleFileManagement
{
	// does nothing, must be implemented by subclass
}

- (BOOL)shouldManageFiles
{
	// only manage if there are some tags on the file
	return [[NSUserDefaults standardUserDefaults] boolForKey:@"General.ManageFiles"] && ([tags count] > 0);
}

@end
