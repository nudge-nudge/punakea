//
//  PAQueryBundle.m
//  punakea
//
//  Created by Daniel on 31.07.06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "PAQueryBundle.h"


NSString * const PAQueryBundleDidUpdate = @"PAQueryBundleDidUpdate";


@implementation PAQueryBundle

#pragma mark Init + Dealloc
- (id)init
{
	self = [super init];
	if(self)
	{
		results = [[NSMutableArray alloc] init];
	}
	return self;
}

- (void)dealloc
{
	if(value) [value release];
	if(results) [results release];
	[super dealloc];
}


#pragma mark Actions
- (void)addResultItem:(id)anItem
{
	[results addObject:anItem];
}

- (NSString *)stringValue
{
	NSMutableString *str = [NSMutableString stringWithString:@"["];
	str = [str stringByAppendingString:value];
	str = [str stringByAppendingString:@": "];

	NSEnumerator *enumerator = [results objectEnumerator];
	NSObject *object;
	while(object = [enumerator nextObject])
	{
		str = [str stringByAppendingString:[object stringValue]];
	}
	
	return [str stringByAppendingString:@"]"];
}

- (unsigned)resultCount
{
	return [results count];
}

- (id)resultAtIndex:(unsigned)index
{
	return [results objectAtIndex:index];
}


#pragma mark Accessors
- (NSArray *)results
{
	return results;
}

- (void)setResults:(NSArray *)newResults
{
	if(results) [results release];
	results = [newResults retain];
}

- (NSString *)value
{
	return value;
}

- (void)setValue:(NSString *)newValue
{
	if(value) [value release];
	value = [newValue retain];
}

- (NSString *)bundlingAttribute
{
	return bundlingAttribute;
}

- (void)setBundlingAttribute:(NSString *)attribute
{
	[bundlingAttribute release];
	bundlingAttribute = [attribute retain];
}
@end
