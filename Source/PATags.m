//
//  PATags.m
//  punakea
//
//  Created by Johannes Hoffart on 18.04.06.
//  Copyright 2006 nudge:nudge. All rights reserved.
//

#import "PATags.h"

NSString * const PATagOperation = @"PATagOperation";

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
	NSEnumerator *e = [self objectEnumerator];
	PATag *resultTag = nil;
	PATag *tag;
	
	while (tag = [e nextObject])
	{
		if ([[tag name] caseInsensitiveCompare:tagName] == NSOrderedSame)
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
	NSDictionary *userInfo = [NSDictionary dictionaryWithObject:changeOperation forKey:PATagOperation];
	[nc postNotificationName:@"PATagsHaveChanged" object:self userInfo:userInfo];
}

#pragma mark additional
- (void)addTag:(PATag*)aTag
{
	[self observeTag:aTag];
	[tags addObject:aTag];
	
	NSNumber *changeOperation = [NSNumber numberWithInt:PATagAddOperation];
	NSDictionary *userInfo = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:changeOperation,aTag,nil] 
														 forKeys:[NSArray arrayWithObjects:PATagOperation,@"tag",nil]];
	[nc postNotificationName:@"PATagsHaveChanged" object:self userInfo:userInfo];
}

- (void)removeTag:(PATag*)aTag
{
	[self stopObservingTag:aTag];
	[tags removeObject:aTag];
	
	NSNumber *changeOperation = [NSNumber numberWithInt:PATagRemoveOperation];
	NSDictionary *userInfo = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:changeOperation,aTag,nil] 
														 forKeys:[NSArray arrayWithObjects:PATagOperation,@"tag",nil]];
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

- (PATag*)tagAtIndex:(unsigned int)idx
{
	return [tags objectAtIndex:idx];
}

- (void)sortUsingDescriptors:(NSArray *)sortDescriptors
{
	[tags sortUsingDescriptors:sortDescriptors];
}

- (PATag*)currentBestTag
{
	PATag *bestTag = nil;
	float currentBestRating = 0.0;
	
	NSEnumerator *e = [self objectEnumerator];
	PATag *tag;
	
	while (tag = [e nextObject])
	{
		if ([tag absoluteRating] > currentBestRating)
		{
			currentBestRating = [tag absoluteRating];
			bestTag = tag;
		}
	}
	
	return bestTag;
}

#pragma mark tag observing
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	NSNumber *changeOperation;
	
	if ([keyPath isEqualTo:@"name"])
	{
		changeOperation = [NSNumber numberWithInt:PATagNameChangeOperation];
	}
	else if ([keyPath isEqualTo:@"lastUsed"])
	{
		changeOperation = [NSNumber numberWithInt:PATagUseIncrementOperation];
	}
	else if ([keyPath isEqualTo:@"lastClicked"])
	{
		changeOperation = [NSNumber numberWithInt:PATagClickIncrementOperation];
	}
	
	NSDictionary *userInfo = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:changeOperation,object,nil] 
														 forKeys:[NSArray arrayWithObjects:PATagOperation,@"tag",nil]];
	[nc postNotificationName:@"PATagsHaveChanged" object:self userInfo:userInfo];
}

- (void)observeTag:(PATag*)tag
{
	[tag addObserver:self forKeyPath:@"name" options:nil context:NULL];
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
	[tag removeObserver:self forKeyPath:@"name"];
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

- (NSString*)description
{
	return [tags description];
}

@end
