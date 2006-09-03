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
	return [self initWithTags:[NSArray array]];
}

- (id)initWithTags:(NSArray*)tags
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
- (PATag*)lastTag
{
	return lastTag;
}

- (void)setLastTag:(PATag*)aTag
{
	[aTag retain];
	[lastTag release];
	lastTag = aTag;
}

- (NSMutableArray*)selectedTags
{
	return selectedTags;
}

- (void)setSelectedTags:(NSMutableArray*)otherTags
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
	[selectedTags addObject:aTag];
	
	[nc postNotificationName:@"PASelectedTagsHaveChanged" object:self];
}

- (void)removeTag:(PATag*)aTag
{
	[selectedTags removeObject:aTag];
	
	[nc postNotificationName:@"PASelectedTagsHaveChanged" object:self];
}

- (void)removeLastTag
{
	[selectedTags removeLastObject];
	
	[nc postNotificationName:@"PASelectedTagsHaveChanged" object:self];
}

- (void)removeAllTags
{
	[selectedTags removeAllObjects];
	
	[nc postNotificationName:@"PASelectedTagsHaveChanged" object:self];
}

- (void)addObjectsFromArray:(NSArray*)array 
{
	[selectedTags addObjectsFromArray:array];
}

- (void)removeObjectsInArray:(NSArray*)array
{
	[selectedTags removeObjectsInArray:array];
}

- (BOOL)containsTag:(PATag*)aTag
{
	return [selectedTags containsObject:aTag];
}

- (NSEnumerator*)objectEnumerator
{
	return [selectedTags objectEnumerator];
}

@end
