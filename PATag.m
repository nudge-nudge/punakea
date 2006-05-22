//
//  PATag.m
//  punakea
//
//  Created by Johannes Hoffart on 15.02.06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
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
		lastClicked = [[NSCalendarDate alloc] init];
		lastUsed = [[NSCalendarDate alloc] init];
		
		clickCount = 0;
		useCount = 0;
	}
	return self;
}

- (void)dealloc 
{
	[name release];
	[query release];
	[lastUsed release];
	[lastClicked release];
	[super dealloc];
}

//NSCoding
- (id)initWithCoder:(NSCoder*)coder 
{
	return nil;
}

- (void)encodeWithCoder:(NSCoder*)coder 
{
	//nothing
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
	[lastClicked release];
	lastClicked = [[NSCalendarDate alloc] init];
}

- (void)incrementUseCount 
{
	useCount++;
	[lastUsed release];
	lastUsed = [[NSCalendarDate alloc] init];
}

- (void)decrementUseCount 
{
	useCount--;
}

- (NSString*)name 
{
	return name;
}

- (NSString*)query 
{
	return query;
}

- (NSCalendarDate*)lastClicked 
{
	return lastClicked;
}

- (NSCalendarDate*)lastUsed 
{
	return lastUsed;
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

#pragma mark description
- (NSString*)description 
{
	return [NSString stringWithFormat:@"tag:%@",name];
}

@end