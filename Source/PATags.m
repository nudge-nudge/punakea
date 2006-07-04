//
//  PATags.m
//  punakea
//
//  Created by Johannes Hoffart on 18.04.06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "PATags.h"


@implementation PATags

#pragma mark init + dealloc
- (id)init
{
	if (self = [super init])
	{
		[self setTags:[[NSMutableArray alloc] init]];
		simpleTagFactory = [[PASimpleTagFactory alloc] init];
	}
	return self;
}

- (void)dealloc
{
	[simpleTagFactory release];
	[tags release];
	[super dealloc];
}

#pragma mark accessors
- (NSMutableArray*)tags
{
	return tags;
}

- (void)setTags:(NSMutableArray*)otherTags
{
	[otherTags retain];
	[tags release];
	tags = otherTags;
}

- (void)insertObject:(PATag *)tag inTagsAtIndex:(unsigned int)i
{
	[tags insertObject:tag atIndex:i];
}

- (void)removeObjectFromTagsAtIndex:(unsigned int)i
{
	[tags removeObjectAtIndex:i];
}

#pragma mark additional
- (void)addTag:(PATag*)aTag
{
	[self insertObject:aTag inTagsAtIndex:[tags count]];
}

- (NSEnumerator*)objectEnumerator
{
	return [tags objectEnumerator];
}

@end
