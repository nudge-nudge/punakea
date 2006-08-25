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
	
	NSNumber *changeOperation = [NSNumber numberWithInt:PATagResetOperation];
	NSDictionary *userInfo = [NSDictionary dictionaryWithObject:changeOperation forKey:@"PATagChangeOperation"];
	[nc postNotificationName:@"PATagsHaveChanged" object:self userInfo:userInfo];
}

#pragma mark additional
- (void)addTag:(PATag*)aTag
{
	[tags setObject:aTag forKey:[aTag name]];
	
	NSNumber *changeOperation = [NSNumber numberWithInt:PATagAddOperation];
	NSDictionary *userInfo = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:changeOperation,aTag,nil] 
														 forKeys:[NSArray arrayWithObjects:@"PATagChangeOperation",@"tag",nil]];
	[nc postNotificationName:@"PATagsHaveChanged" object:self userInfo:userInfo];
}

- (void)removeTag:(PATag*)aTag
{
	[tags removeObjectForKey:[aTag name]];
	
	NSNumber *changeOperation = [NSNumber numberWithInt:PATagRemoveOperation];
	NSDictionary *userInfo = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:changeOperation,aTag,nil] 
														 forKeys:[NSArray arrayWithObjects:@"PATagChangeOperation",@"tag",nil]];
	[nc postNotificationName:@"PATagsHaveChanged" object:self userInfo:userInfo];
}

- (NSEnumerator*)objectEnumerator
{
	return [tags objectEnumerator];
}

- (int)count
{
	return [tags count];
}

@end
