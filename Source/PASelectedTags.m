//
//  PASelectedTags.m
//  punakea
//
//  Created by Johannes Hoffart on 18.04.06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "PASelectedTags.h"


@implementation PASelectedTags

#pragma mark init + dealloc
- (id)init
{
	return [self initWithTags:[NSDictionary dictionary]];
}

- (id)initWithTags:(NSDictionary*)tags
{
	if (self = [super init])
	{
		[self setSelectedTags:[tags mutableCopy]];
		nc = [NSNotificationCenter defaultCenter];
	}
	return self;
}

- (void)dealloc
{
	[selectedTags release];
	[super dealloc];
}

#pragma mark accessors
- (NSArray*)selectedTagArray
{
	return [selectedTags allValues];
}

- (NSMutableDictionary*)selectedTags
{
	return selectedTags;
}

- (void)setSelectedTags:(NSMutableDictionary*)otherTags
{
	[otherTags retain];
	[selectedTags release];
	selectedTags = otherTags;
	
	[nc postNotificationName:@"PASelectedTagsHaveChanged" object:self];
}

#pragma mark additional
- (unsigned int)count
{
	return [selectedTags count];
}
	
- (void)addTag:(PATag*)aTag
{
	[selectedTags setObject:aTag forKey:[aTag name]];
	
	[nc postNotificationName:@"PASelectedTagsHaveChanged" object:self];
}

- (void)removeTag:(PATag*)aTag
{
	[selectedTags removeObjectForKey:[aTag name]];
	
	[nc postNotificationName:@"PASelectedTagsHaveChanged" object:self];
}

- (void)removeAllObjects
{
	[selectedTags removeAllObjects];
	
	[nc postNotificationName:@"PASelectedTagsHaveChanged" object:self];
}

- (void)addObjectsFromArray:(NSArray*)array 
{
	NSEnumerator *e = [array objectEnumerator];
	PATag *tag;
	
	while (tag = [e nextObject])
	{
		[self addTag:tag];
	}
}

- (void)removeObjectsInArray:(NSArray*)array
{
	NSEnumerator *e = [array objectEnumerator];
	PATag *tag;
	
	while (tag = [e nextObject])
	{
		[self removeTag:tag];
	}
}

- (BOOL)containsTag:(PATag*)aTag
{
	return ([selectedTags objectForKey:[aTag name]] != nil);
}

- (NSEnumerator*)objectEnumerator
{
	return [selectedTags objectEnumerator];
}

@end
