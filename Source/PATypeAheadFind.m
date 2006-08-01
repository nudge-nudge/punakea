//
//  PATypeAheadFind.m
//  punakea
//
//  Created by Johannes Hoffart on 06.05.06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "PATypeAheadFind.h"

@interface PATypeAheadFind (PrivateAPI)

- (void)updateMatchingTags;

@end

@implementation PATypeAheadFind

#pragma mark init + dealloc
- (id)init
{
	if (self = [super init])
	{
		tags = [[PATagger sharedInstance] tags];
		matchingTags = [[NSMutableArray alloc] init];
	}
	return self;
}

- (void)dealloc
{
	[matchingTags release];
	[tags release];
	[super dealloc];
}

#pragma mark accessors
- (NSArray*)activeTags
{
	return activeTags;
}

- (void)setActiveTags:(NSArray*)someTags
{
	[someTags retain];
	[activeTags release];
	activeTags = someTags;
}

- (NSString*)prefix
{
	return prefix;
}

- (void)setPrefix:(NSString*)newPrefix
{
	[newPrefix retain];
	[prefix release];
	prefix = newPrefix;
	
	[self updateMatchingTags];
}

- (NSMutableArray*)matchingTags
{
	return matchingTags;
}

#pragma mark functionality
- (void)updateMatchingTags
{
	//TODO make more efficient
	[matchingTags removeAllObjects];
	
	NSEnumerator *e;
	
	// if active tags are set, look there, otherwise check in all tags
	if ([activeTags count] > 0)
	{
		e = [activeTags objectEnumerator];
	}
	else
	{
		e = [tags objectEnumerator];
	}
	
	PATag *tag;
	
	while (tag = [e nextObject])
	{
		if ([[tag name] hasPrefix:prefix])
		{
			[matchingTags addObject:tag];
		}
	}
}

- (BOOL)hasTagsForPrefix:(NSString*)prefix
{
	NSEnumerator *e;
	
	// if active tags are set, look there, otherwise check in all tags
	if ([activeTags count] > 0)
	{
		e = [activeTags objectEnumerator];
	}
	else
	{
		e = [tags objectEnumerator];
	}
	
	PATag *tag;
	
	while (tag = [e nextObject])
	{
		if ([[tag name] hasPrefix:prefix])
		{
			return true;
		}
	}
		
	// returns false if no tag was matching
	return false;
}

- (NSArray*)tagsForPrefix:(NSString*)prefix
{
	return [self tagsForPrefix:prefix inTags:tags];
}

- (NSArray*)tagsForPrefix:(NSString*)prefix inTags:(NSArray*)tags
{
	NSMutableArray *result = [NSMutableArray array];
	
	NSEnumerator *e = [tags objectEnumerator];
	PATag *tag;
	
	while (tag = [e nextObject])
	{
		if ([[tag name] hasPrefix:prefix])
		{
			[result addObject:tag];
		}
	}
	
	return result;
}

@end
