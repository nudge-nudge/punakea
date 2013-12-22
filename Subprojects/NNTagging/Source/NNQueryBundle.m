// Copyright (c) 2006-2013 nudge:nudge (Johannes Hoffart & Daniel Bär). All rights reserved.
// 
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "NNQueryBundle.h"


NSString * const NNQueryBundleDidUpdate = @"NNQueryBundleDidUpdate";


@implementation NNQueryBundle

#pragma mark Init + Dealloc
- (id)init
{
	self = [super init];
	if(self)
	{
		results = [[NSMutableArray alloc] init];
		
		// Set fix sort order for bundles
		sortOrderArray = [[NSMutableArray alloc] init];
		[sortOrderArray addObject:@"DOCUMENTS"];
		[sortOrderArray addObject:@"BOOKMARKS"];
		[sortOrderArray addObject:@"PDF"];
		[sortOrderArray addObject:@"IMAGES"];
		[sortOrderArray addObject:@"PRESENTATIONS"];
		[sortOrderArray addObject:@"CONTACT"];
		[sortOrderArray addObject:@"MUSIC"];
		[sortOrderArray addObject:@"MOVIES"];
	}
	return self;
}

- (void)dealloc
{
	[sortOrderArray release];
	if(value) [value release];
	if(results) [results release];
	[super dealloc];
}

+ (NNQueryBundle *)bundle
{
	return [[[NNQueryBundle alloc] init] autorelease];
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

- (NSUInteger)hash 
{
	return [[self value] hash];
}

- (NSComparisonResult)compare:(id)otherBundle
{
	NSUInteger indexSelf = [sortOrderArray indexOfObject:[self value]];
	NSUInteger indexOtherBundle = [sortOrderArray indexOfObject:[otherBundle value]];
	
	if(indexSelf < indexOtherBundle)
		return NSOrderedAscending;
	else
		return NSOrderedDescending;
}


#pragma mark Actions
- (void)addObject:(id)anItem
{
	[results addObject:anItem];
}

- (BOOL)containsObject:(id)anItem
{
	return [results containsObject:anItem];
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

- (NSUInteger)resultCount
{
	return [results count];
}

- (id)resultAtIndex:(NSUInteger)idx
{
	return [results objectAtIndex:idx];
}

- (void)sortUsingSelector:(SEL)comparator
{
	[results sortUsingSelector:comparator];
}

- (void)sortUsingDescriptors:(NSArray*)sortDescriptors
{
	[results sortUsingDescriptors:sortDescriptors];
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

- (NSString *)displayName
{
	return NSLocalizedStringFromTableInBundle([self value],@"MDSimpleGrouping",[NSBundle bundleWithIdentifier:@"eu.nudgenudge.nntagging"],nil);
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
