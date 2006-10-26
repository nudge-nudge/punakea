//
//  PARelatedTagsStandalone.m
//  punakea
//
//  Created by Johannes Hoffart on 08.07.06.
//  Copyright 2006 nudge:nudge. All rights reserved.
//

#import "PARelatedTagsStandalone.h"


@implementation PARelatedTagsStandalone

/**
use this init if you want an encapsulated way to get related tags for the
 given selected tags
 @param otherSelectedTags tags for which to find related tags
 */
- (id)initWithSelectedTags:(PASelectedTags*)otherSelectedTags
{
	PAQuery *aQuery = [[PAQuery alloc] initWithTags:otherSelectedTags];
	
	if (self = [super initWithSelectedTags:otherSelectedTags query:aQuery])
	{
		//nothing
	}
	return self;
}

/*
 method overriden. will adjust the query
 */
- (void)setSelectedTags:(PASelectedTags*)otherTags
{
	[otherTags retain];
	[selectedTags release];
	selectedTags = otherTags;
	
	[query setTags:selectedTags];
}

@end
