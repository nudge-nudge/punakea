//
//  PATypeAheadFind.m
//  punakea
//
//  Created by Johannes Hoffart on 06.05.06.
//  Copyright 2006 nudge:nudge. All rights reserved.
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
	}
	return self;
}

- (void)dealloc
{
	[super dealloc];
}

#pragma mark accessors
- (NSMutableArray*)activeTags
{
	return activeTags;
}

- (void)setActiveTags:(NSMutableArray*)someTags
{
	[someTags retain];
	[activeTags release];
	activeTags = someTags;
}

#pragma mark functionality
- (BOOL)hasTagsForPrefix:(NSString*)prefix
{
	// handle nil/empty prefix
	if (!prefix || [prefix isEqualToString:@""])
	{
		return YES;
	}
	
	NSEnumerator *e;
	
	// if active tags are set, look there, otherwise check in all tags
	if (activeTags)
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
		if (!NSEqualRanges([[tag name] rangeOfString:prefix options:(NSCaseInsensitiveSearch | NSAnchoredSearch)],
						   NSMakeRange(NSNotFound,0)))
		{
			return true;
		}
	}
		
	// returns false if no tag was matching
	return false;
}

- (NSMutableArray*)tagsForPrefix:(NSString*)prefix
{
	if ([activeTags count] > 0)
	{
		return [self tagsForPrefix:prefix inTags:activeTags];
	}
	else
	{
		return [self tagsForPrefix:prefix inTags:[tags tags]];
	}
}

- (NSMutableArray*)tagsForPrefix:(NSString*)prefix inTags:(NSArray*)someTags
{
	NSMutableArray *result = [NSMutableArray array];
	
	NSEnumerator *e = [someTags objectEnumerator];
	PATag *tag;
	
	while (tag = [e nextObject])
	{
		if (!NSEqualRanges([[tag name] rangeOfString:prefix options:(NSCaseInsensitiveSearch | NSAnchoredSearch)],
						   NSMakeRange(NSNotFound,0)))
		{
			[result addObject:tag];
		}
	}
	
	return result;
}

@end
