//
//  PAQueryBundle.m
//  punakea
//
//  Created by Daniel on 31.07.06.
//  Copyright 2006 nudge:nudge. All rights reserved.
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

+ (PAQueryBundle *)bundle
{
	return [[[PAQueryBundle alloc] init] autorelease];
}


#pragma mark Comparing
- (BOOL)isEqual:(id)object
{
	return [self isEqualTo:object];
}

- (BOOL)isEqualTo:(id)object
{
	if(self == object) return YES;
	if(!object || ![object isMemberOfClass:[self class]]) return NO;

	return [[self value] isEqualTo:[object value]];
}

- (unsigned)hash 
{
	return [[self value] hash];
}


#pragma mark Actions
- (void)addObject:(id)anItem
{
	[results addObject:anItem];
}

- (void)removeObject:(id)anItem
{
	[results removeObject:anItem];
}

- (NSString *)stringValue
{
	NSMutableString *str = [NSMutableString stringWithString:@"["];
	str = (NSMutableString *)[str stringByAppendingString:value];
	str = (NSMutableString *)[str stringByAppendingString:@": "];

	NSEnumerator *enumerator = [results objectEnumerator];
	id object;
	while(object = [enumerator nextObject])
	{
		str = (NSMutableString *)[str stringByAppendingString:[object stringValue]];
	}
	
	return [str stringByAppendingString:@"]"];
}

- (unsigned)resultCount
{
	return [results count];
}

- (id)resultAtIndex:(unsigned)idx
{
	return [results objectAtIndex:idx];
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
