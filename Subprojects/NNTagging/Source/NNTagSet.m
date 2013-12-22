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

#import "NNTagSet.h"

@implementation NNTagSet

#pragma mark Init + Dealloc
- (id)init {
	return [self initWithTags:nil name:nil];
}

- (id)initWithTags:(NSArray*)newTags {
	return [self initWithTags:newTags name:nil];
}

- (id)initWithName:(NSString*)aName {
	return [self initWithTags:nil name:aName];
}

// designated initializer
- (id)initWithTags:(NSArray*)newTags name:(NSString*)aName {
	self = [super init];
	if (self) {
		if (!newTags) newTags = [NSMutableArray array];
		if (!aName) aName = NSLocalizedString(@"default tagset name","new TagSet");

		tags = [[NSMutableArray alloc] initWithArray:newTags];
		name = [aName copy];
	}
	return self;
}

+ (NNTagSet *)setWithTags:(NSArray *)newTags
{
	return [NNTagSet setWithTags:newTags name:nil];
}

+ (NNTagSet *)setWithName:(NSString *)aName
{
	return [NNTagSet setWithTags:nil name:aName];
}

+ (NNTagSet *)setWithTags:(NSArray *)newTags name:(NSString *)aName
{
	NNTagSet *newSet = [[NNTagSet alloc] initWithTags:newTags name:aName];
	return [newSet autorelease];
}

-(void)dealloc {
	[tags release];
	[name release];
	[super dealloc];
}


#pragma mark Equality
- (BOOL)isEqual:(id)other 
{
	return [self isEqualTo:other];
}

- (BOOL)isEqualTo:(id)other
{
	if (!other || ![other isKindOfClass:[self class]]) 
        return NO;
    if (other == self)
        return YES;
	
	if(![tags isEqualTo:[other tags]])
		return NO;
	
    return [name isEqualTo:[other name]];
}

- (NSUInteger)hash 
{
	return [tags hash] + [name hash];
}


#pragma mark Copying
- (id)copyWithZone:(NSZone *)zone
{
	NNTagSet *newSet = [[NNTagSet alloc] init];
	
	// abstract class instance vars
	[newSet setTags:[self tags]];
	[newSet setName:[self name]];
	
	return newSet;
}

#pragma mark Misc
- (void)addTag:(NNTag *)aTag
{
	// Avoid duplicates
	if(![tags containsObject:aTag])
		[tags addObject:aTag];
}

- (void)addTags:(NSArray *)newTags
{
	// Avoid duplicates
	NSEnumerator *enumerator = [newTags objectEnumerator];
	NNTag *newTag;
	
	while(newTag = [enumerator nextObject])
	{
		[self addTag:newTag];
	}
}

- (void)removeTag:(NNTag *)aTag
{
	[tags removeObject:aTag];
}

- (BOOL)containsTag:(NNTag *)aTag
{
	return [tags containsObject:aTag];
}

- (BOOL)intersectsTagSet:(NNTagSet *)otherSet
{
	NSEnumerator *enumerator = [[otherSet tags] objectEnumerator];
	NNTag *otherTag;
	
	while(otherTag = [enumerator nextObject])
	{
		if([self containsTag:otherTag])
			return YES;
	}
	
	return NO;
}


#pragma mark Accessors
- (NSMutableArray *)tags
{
	return tags;
}

- (void)setTags:(NSArray *)newTags
{
	[tags release];
	tags = [[NSMutableArray alloc] initWithArray:newTags];
}

- (NSString *)name
{
	return name;
}

- (void)setName:(NSString *)aName
{
	[name release];
	name = [aName retain];
}

- (NSString*)description
{
	return [NSString stringWithFormat:@"TagSet: %@",tags];
}

@end