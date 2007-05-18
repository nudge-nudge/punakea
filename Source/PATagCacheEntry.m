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
	}
	return self;
}

- (void)dealloc
{
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
	[dic retain];
	[assignedFiletypes release];
	assignedFiletypes = dic;
}

- (NSMutableDictionary*)assignedFiletypes
{
	return assignedFiletypes;
}

#pragma mark function
- (void)setHasFiletype:(NSString*)filetype toValue:(BOOL)hasFiletype
{
	NSArray *values = [NSArray arrayWithObjects:[NSCalendarDate date],[NSNumber numberWithBool:hasFiletype],nil];
	
	[assignedFiletypes setObject:values forKey:filetype];
}		

- (PACacheResult)hasFiletype:(NSString*)filetype forDate:(NSCalendarDate*)date
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