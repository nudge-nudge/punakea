//
//  PATagCacheEntry.m
//  punakea
//
//  Created by Johannes Hoffart on 11.05.07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "PATagCacheEntry.h"


@implementation PATagCacheEntry

#pragma mark init
- (id)init
{
	if (self = [super init])
	{
		[self setAssignedFiletypes:[NSMutableDictionary dictionary]];
		lock = [[NSLock alloc] init];
	}
	return self;
}

- (void)dealloc
{
	[lock release];
	[assignedFiletypes release];
	[super dealloc];
}

#pragma mark coding
- (id)initWithCoder:(NSCoder*)coder 
{
	self = [super init];
	if (self) 
	{
		[self setAssignedFiletypes:[coder decodeObjectForKey:@"assignedFiletypes"]];
	}
	return self;
}

- (void)encodeWithCoder:(NSCoder*)coder 
{
	[coder encodeObject:assignedFiletypes forKey:@"assignedFiletypes"];
}

#pragma mark accessors
- (void)setAssignedFiletypes:(NSMutableDictionary*)dic
{
	[lock lock];
	[dic retain];
	[assignedFiletypes release];
	assignedFiletypes = dic;
	[lock unlock];
}

- (NSMutableDictionary*)assignedFiletypes
{
	return assignedFiletypes;
}

#pragma mark function
- (void)setHasFiletype:(NSString*)filetype toValue:(BOOL)hasFiletype
{
	NSArray *values = [NSArray arrayWithObjects:[NSCalendarDate date],[NSNumber numberWithBool:hasFiletype],nil];
	
	[lock lock];
	[assignedFiletypes setObject:values forKey:filetype];
	[lock unlock];
}		

- (PACacheResult)hasFiletype:(NSString*)filetype forDate:(NSDate*)date
{
	PACacheResult result = 0;
	
	NSArray *values = [assignedFiletypes objectForKey:filetype];
	
	if (values)
	{
		NSCalendarDate *cacheDate = [values objectAtIndex:0];
		
		if ([cacheDate compare:date] != NSOrderedAscending)
		{
			result = PACacheIsValid;
		}
		
		if ([[values objectAtIndex:1] boolValue])
		{
			result = result | PACacheSatisfiesRequest;
		}
	}
	
	return result;
}

@end
