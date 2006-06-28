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
	if (self = [super init])
	{
		[self setSelectedTags:[[NSMutableArray alloc] init]];
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

- (void)removeAllObjects
{
	[self setSelectedTags:[NSMutableArray array]];
}

- (void)addObjectsFromArray:(NSArray*)array 
{
	NSEnumerator *e;
	PATag *tag;
	
	while (tag = [e nextObject])
	{
		[self addTag:tag];
	}
}

- (void)removeObjectsInArray:(NSArray*)array
{
	NSEnumerator *e;
	PATag *tag;
	
	while (tag = [e nextObject])
	{
		[self removeTag:tag];
	}
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
