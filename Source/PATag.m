//
//  PATag.m
//  punakea
//
//  Created by Johannes Hoffart on 15.02.06.
//  Copyright 2006 nudge:nudge. All rights reserved.
//

#import "PATag.h"

@implementation PATag 

#pragma mark init
- (id)init
{
	return [self initWithName:NSLocalizedString(@"default tag name",@"tag")];
}

//designated initializer
- (id)initWithName:(NSString*)aName 
{
	if (self = [super init]) 
	{
		[self setName:aName];
		
		clickCount = 0;
		useCount = 0;
	}
	return self;
}

- (void)dealloc 
{
	[lastUsed release];
	[lastClicked release];
	[name release];
	[query release];
	[super dealloc];
}

#pragma mark nscoding
- (id)initWithCoder:(NSCoder*)coder 
{
	self = [super init];
	if (self) 
	{
		[self setName:[coder decodeObjectForKey:@"name"]];
		[self setQuery:[coder decodeObjectForKey:@"query"]];
		lastClicked = [[coder decodeObjectForKey:@"lastClicked"] retain];
		lastUsed = [[coder decodeObjectForKey:@"lastUsed"] retain];
		[coder decodeValueOfObjCType:@encode(unsigned long)	at:&clickCount];
		[coder decodeValueOfObjCType:@encode(unsigned long)	at:&useCount];
	}
	return self;
}

- (void)encodeWithCoder:(NSCoder*)coder 
{
	[coder encodeObject:name forKey:@"name"];
	[coder encodeObject:query forKey:@"query"];
	[coder encodeObject:lastClicked forKey:@"lastClicked"];
	[coder encodeObject:lastUsed forKey:@"lastUsed"];
	[coder encodeValueOfObjCType:@encode(unsigned long) at:&clickCount];
	[coder encodeValueOfObjCType:@encode(unsigned long) at:&useCount];
}

#pragma mark accessors
- (void)setName:(NSString*)aName 
{
	[aName retain];
	[name release];
	name = aName;
}

- (void)setQuery:(NSString*)aQuery 
{
	[aQuery retain];
	[query release];
	query = aQuery;
}

- (void)incrementClickCount 
{
	clickCount++;
	[self setLastClicked:[NSCalendarDate calendarDate]];
}

- (void)incrementUseCount 
{
	useCount++;
	[self setLastUsed:[NSCalendarDate calendarDate]];
}

- (void)decrementUseCount 
{
	useCount--;
}

- (void)setUseCount:(int)count
{
	useCount = count;
}

- (void)setClickCount:(int)count
{
	clickCount = count;
}

- (NSString*)name 
{
	return name;
}

- (NSString*)query 
{
	return query;
}

- (NSString*)queryInSpotlightSyntax
{
	return @""; // TODO
}

- (NSCalendarDate*)lastClicked 
{
	return lastClicked;
}

- (void)setLastClicked:(NSCalendarDate*)clickDate
{
	[clickDate retain];
	[lastClicked release];
	lastClicked = clickDate;
}

- (NSCalendarDate*)lastUsed 
{
	return lastUsed;
}

- (void)setLastUsed:(NSCalendarDate*)useDate
{
	[useDate retain];
	[lastUsed release];
	lastUsed = useDate;
}

- (unsigned long)clickCount 
{
	return clickCount;
}

- (unsigned long)useCount 
{
	return useCount;
}

- (float)absoluteRating
{
	return 0;
}

- (float)relativeRatingToTag:(PATag*)otherTag
{	
	return 0;
}

#pragma mark drawing
- (NSMutableDictionary*)viewAttributes
{
	return nil;
}

#pragma mark euality testing
- (BOOL)isEqual:(id)other
{
	return NO;
}

- (unsigned)hash 
{
	return 0;
}

- (id)copyWithZone:(NSZone *)zone
{
	return nil;
}

#pragma mark description
- (NSString*)description 
{
	return [NSString stringWithFormat:@"tag:%@",name];
}

@end