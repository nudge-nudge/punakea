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
	return [self initWithTags:[NSMutableArray array]];
}

- (id)initWithTags:(NSArray*)tags
{
	if (self = [super init])
	{
		[self setSelectedTags:[tags mutableCopy]];
	}
	return self;
}

- (void)dealloc
{
	[selectedTags release];
	[super dealloc];
}

#pragma mark accessors
- (NSMutableArray*)selectedTags
{
	return selectedTags;
}

- (void)setSelectedTags:(NSMutableArray*)otherTags
{
	[otherTags retain];
	[selectedTags release];
	selectedTags = otherTags;
}

- (void)insertObject:(PATag *)tag inSelectedTagsAtIndex:(unsigned int)i
{
	[selectedTags insertObject:tag atIndex:i];
}

- (void)removeObjectFromSelectedTagsAtIndex:(unsigned int)i
{
	[selectedTags removeObjectAtIndex:i];
}

#pragma mark additional
- (unsigned int)count
{
	return [selectedTags count];
}
	
- (void)addTag:(PATag*)aTag
{
	[self insertObject:aTag inSelectedTagsAtIndex:[selectedTags count]];
}

- (void)removeTag:(PATag*)aTag
{
	unsigned int i = [selectedTags indexOfObject:aTag];
	[self removeObjectFromSelectedTagsAtIndex:i];
}

- (void)removeAllObjectsFromSelectedTags
{
	for (int i=0;i<[selectedTags count];i++)
	{
		[self removeObjectFromSelectedTagsAtIndex:i];
	}
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

- (BOOL)containsObject:(PATag*)aTag
{
	return [selectedTags containsObject:aTag];
}

- (NSEnumerator*)objectEnumerator
{
	return [selectedTags objectEnumerator];
}

- (PATag*)tagAtIndex:(unsigned int)i
{
	return [selectedTags objectAtIndex:i];
}

@end
