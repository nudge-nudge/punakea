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

#import "NNSelectedTags.h"


@interface NNSelectedTags (PrivateAPI)

// nothing ...

@end

NSString * const NNSelectedTagsHaveChangedNotification = @"NNSelectedTagsHaveChanged";


@implementation NNSelectedTags

#pragma mark init + dealloc
- (id)init
{
	return [self initWithTags:[NSArray array]];
}

- (id)initWithTags:(NSArray*)tags
{
	if (self = [super init])
	{
		[self setSelectedTags:[[tags mutableCopy] autorelease]];
		negatedTags = [[NSMutableSet alloc] init];
		
		nc = [NSNotificationCenter defaultCenter];
	}
	return self;
}

- (void)dealloc
{
	[negatedTags release];
	[selectedTags release];
	[super dealloc];
}


#pragma mark Copying
- (id)copyWithZone:(NSZone *)zone
{
	NNSelectedTags *newSelectedTags = [[NNSelectedTags alloc] init];
	
	[newSelectedTags setSelectedTags:[self selectedTags]];
	
	return newSelectedTags;
}


#pragma mark accessors
- (NSMutableArray*)selectedTags
{
	return selectedTags;
}

- (void)setSelectedTags:(NSArray*)otherTags
{
	// make sure the selected tags exist
	// TODO
	
	[selectedTags release];
	selectedTags = [otherTags mutableCopy];
	
	[nc postNotificationName:NNSelectedTagsHaveChangedNotification object:self];
}

#pragma mark additional
- (NSUInteger)count
{
	return [selectedTags count];
}
	
- (void)addTag:(NNTag*)aTag
{
	[self addTag:aTag negated:NO];
}

- (void)addTag:(NNTag*)aTag negated:(BOOL)negated
{
	if (![self containsTag:aTag])
	{
		[selectedTags addObject:aTag];
		
		if (negated)
		{
			[negatedTags addObject:aTag];
		}
		
		[nc postNotificationName:NNSelectedTagsHaveChangedNotification object:self];
	}
}

- (void)addTags:(NSArray*)someTags
{
	NSEnumerator *e = [someTags objectEnumerator];
	NNTag *tag;
	BOOL added = NO;
	
	while (tag = [e nextObject])
	{
		if (![self containsTag:tag])
		{
			added = YES;
			[selectedTags addObject:tag];
		}
	}
	
	if (added)
		[nc postNotificationName:NNSelectedTagsHaveChangedNotification object:self];
}

- (void)removeTag:(NNTag*)aTag
{
	if ([self count] > 0)
	{
		[selectedTags removeObject:aTag];
		[negatedTags removeObject:aTag];
		
		[nc postNotificationName:NNSelectedTagsHaveChangedNotification object:self];
	}
}

- (void)negateTag:(NNTag*)aTag
{
	[negatedTags addObject:aTag];
	
	[nc postNotificationName:NNSelectedTagsHaveChangedNotification object:self];
}

- (void)toggleTagNegation:(NNTag*)aTag
{
	if ([negatedTags containsObject:aTag])
	{
		[negatedTags removeObject:aTag];
	}
	else
	{
		[negatedTags addObject:aTag];
	}
	
	[nc postNotificationName:NNSelectedTagsHaveChangedNotification object:self];
}

- (BOOL)isNegated:(NNTag*)aTag
{
	BOOL negated = [negatedTags containsObject:aTag];
	return negated;
}

- (void)removeLastTag
{
	if ([self count] > 0)
	{
		[self removeTag:[selectedTags lastObject]];
		
		[nc postNotificationName:NNSelectedTagsHaveChangedNotification object:self];
	}
}

- (void)removeAllTags
{
	if ([self count] > 0)
	{
		[selectedTags removeAllObjects];
		[negatedTags removeAllObjects];
	
		[nc postNotificationName:NNSelectedTagsHaveChangedNotification object:self];
	}
}

- (void)addObjectsFromArray:(NSArray *)array 
{
	if(array && [array count] > 0)
	{
		NSUInteger tagCountBefore = [selectedTags count];		
		[selectedTags addObjectsFromArray:array];
		NSUInteger tagCountAfter = [selectedTags count];
		
		// Only post notification if there have been changes
		if(tagCountBefore < tagCountAfter)
			[nc postNotificationName:NNSelectedTagsHaveChangedNotification object:self];
	}
}

- (void)removeObjectsInArray:(NSArray *)array
{
	if(array && [array count] > 0)
	{
		NSUInteger tagCountBefore = [selectedTags count];
		
		for (NNTag *tag	in array) {
			[selectedTags removeObject:tag];
			[negatedTags removeObject:tag];
		}
		
		NSUInteger tagCountAfter = [selectedTags count];
		
		// Only post notification if there have been changes
		if(tagCountBefore > tagCountAfter)
			[nc postNotificationName:NNSelectedTagsHaveChangedNotification object:self];
	}
}	

- (BOOL)containsTag:(NNTag*)aTag
{
	return [selectedTags containsObject:aTag];
}

- (NSEnumerator*)objectEnumerator
{
	return [selectedTags objectEnumerator];
}

- (NSMutableString*)queryString
{
	NSMutableString *queryString = [NSMutableString stringWithString:@""];
	
	NSEnumerator *tagEnumerator = [selectedTags objectEnumerator];
	NNTag *tag;
	
	if (tag = [tagEnumerator nextObject]) 
	{
		NSString *query = ([self isNegated:tag]) ? [tag negatedQuery] : [tag query];
		
		NSString *anotherTagQuery = [NSString stringWithFormat:@"(%@)",query];
		[queryString appendString:anotherTagQuery];
	}
	
	while (tag = [tagEnumerator nextObject]) 
	{
		NSString *query = ([self isNegated:tag]) ? [tag negatedQuery] : [tag query];
		
		NSString *anotherTagQuery = [NSString stringWithFormat:@" && (%@)",query];
		[queryString appendString:anotherTagQuery];
	}

	return queryString;
}

#pragma mark description
- (NSString*)description
{
	return [NSString stringWithFormat:@"Selected Tags: %@",selectedTags];
}

@end
