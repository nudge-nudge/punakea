//
//  PATags.m
//  punakea
//
//  Created by Johannes Hoffart on 18.04.06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "PATags.h"

@interface PATags (PrivateAPI)

- (void)observeTag:(PATag*)tag;
- (void)observeTags:(NSArray*)someTags;
- (void)stopObservingTag:(PATag*)tag;
- (void)stopObservingTags:(NSArray*)someTags;

@end

@implementation PATags

#pragma mark init + dealloc
- (id)init
{
	if (self = [super init])
	{
		[self setTags:[NSMutableArray array]];
		
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
- (PATag*)tagForName:(NSString*)tagName
{
	// TODO efficient with hash
	NSEnumerator *e = [self objectEnumerator];
	PATag *resultTag = nil;
	PATag *tag;
	
	while (tag = [e nextObject])
	{
		if ([[tag name] isEqualToString:tagName])
		{
			resultTag = tag;
		}
	}
	
	return resultTag;
}

- (NSMutableArray*)tags
{
	return tags;
}

- (void)setTags:(NSMutableArray*)otherTags
{
	[self observeTags:otherTags];
	[otherTags retain];
	[self stopObservingTags:tags];
	[tags release];
	tags = otherTags;
	
	NSNumber *changeOperation = [NSNumber numberWithInt:PATagResetOperation];
	NSDictionary *userInfo = [NSDictionary dictionaryWithObject:changeOperation forKey:@"PATagChangeOperation"];
	[nc postNotificationName:@"PATagsHaveChanged" object:self userInfo:userInfo];
}

#pragma mark additional
- (void)addTag:(PATag*)aTag
{
	[self observeTag:aTag];
	[tags addObject:aTag];
	
	NSNumber *changeOperation = [NSNumber numberWithInt:PATagAddOperation];
	NSDictionary *userInfo = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:changeOperation,aTag,nil] 
														 forKeys:[NSArray arrayWithObjects:@"PATagChangeOperation",@"tag",nil]];
	[nc postNotificationName:@"PATagsHaveChanged" object:self userInfo:userInfo];
}

- (void)removeTag:(PATag*)aTag
{
	[self stopObservingTag:aTag];
	[tags removeObject:aTag];
	
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

#pragma mark tag observing
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	NSNumber *changeOperation = [NSNumber numberWithInt:PATagUpdateOperation];
	NSDictionary *userInfo = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:changeOperation,object,nil] 
														 forKeys:[NSArray arrayWithObjects:@"PATagChangeOperation",@"tag",nil]];
	[nc postNotificationName:@"PATagsHaveChanged" object:self userInfo:userInfo];
}

- (void)observeTag:(PATag*)tag
{
	[tag addObserver:self forKeyPath:@"lastUsed" options:nil context:NULL];
	[tag addObserver:self forKeyPath:@"lastClicked" options:nil context:NULL];
}	

- (void)observeTags:(NSArray*)someTags
{
	NSEnumerator *e = [someTags objectEnumerator];
	PATag *tag;
	
	while (tag = [e nextObject])
	{
		[self observeTag:tag];
	}
}

- (void)stopObservingTag:(PATag*)tag
{
	[tag removeObserver:self forKeyPath:@"lastUsed"];
	[tag removeObserver:self forKeyPath:@"lastClicked"];
}

- (void)stopObservingTags:(NSArray*)someTags
{
	NSEnumerator *e = [someTags objectEnumerator];
	PATag *tag;
	
	while (tag = [e nextObject])
	{
		[self stopObservingTag:tag];
	}
}

@end
