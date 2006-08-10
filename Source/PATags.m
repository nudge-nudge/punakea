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
		[self setTags:[NSMutableDictionary dictionary]];
		
		nc = [NSNotificationCenter defaultCenter];
	}
	return self;
}

- (void)dealloc
{
	[tags release];
	[super dealloc];
}

#pragma mark accessors
- (NSArray*)tagArray
{
	return [tags allValues];
}

- (PATag*)tagForName:(NSString*)tagName
{
	return [tags objectForKey:tagName];
}

- (NSMutableDictionary*)tags
{
	return tags;
}

- (void)setTags:(NSMutableDictionary*)otherTags
{
	[otherTags retain];
	[tags release];
	tags = otherTags;
	
	[nc postNotificationName:@"PATagsHaveChanged" object:self];
}

#pragma mark additional
- (void)addTag:(PATag*)aTag
{
	[tags setObject:aTag forKey:[aTag name]];
	
	[nc postNotificationName:@"PATagsHaveChanged" object:self];
}

- (void)removeTag:(PATag*)aTag
{
	[tags removeObjectForKey:[aTag name]];
	
	[nc postNotificationName:@"PATagsHaveChanged" object:self];
}

- (NSEnumerator*)objectEnumerator
{
	return [tags objectEnumerator];
}

@end
