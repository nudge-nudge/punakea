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
	
	NSEnumerator *e = [tags objectEnumerator];
	PATag *tag;
	
	while (tag = [e nextObject])
	{
		if ([[tag name] hasPrefix:prefix])
		{
			[matchingTags addObject:tag];
		}
	}
}

@end
