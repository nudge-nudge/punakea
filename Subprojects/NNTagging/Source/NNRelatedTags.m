// Copyright (c) 2006-2013 nudge:nudge (Johannes Hoffart & Daniel Bär). All rights reserved.
// 
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "NNRelatedTags.h"

#import "lcl.h"

@interface NNRelatedTags (PrivateAPI)

- (void)updateRelatedTags;
- (NNTag*)getTagWithBestAbsoluteRating:(NSArray*)tags;

- (void)setUpdating:(BOOL)flag;

- (void)setRelatedTags:(NSMutableArray*)otherTags;

- (void)addTag:(NNTag*)aTag;
- (void)addTags:(NSArray*)someTags;

- (void)removeTag:(NNTag*)aTag;
- (void)removeTags:(NSArray*)someTags;

@end

@implementation NNRelatedTags

#pragma mark init + dealloc

- (id)initWithQuery:(NNQuery*)aQuery;
{
	if (self = [super init])
	{	
		tags = [NNTags sharedTags];
		
		[self setUpdating:NO];
		
		[self setQuery:aQuery];
		[self setRelatedTags:[NSMutableArray array]];
		
		//register with notificationcenter - listen for changes in the query results -- activeFiles is the query
		nc = [NSNotificationCenter defaultCenter];
		[nc addObserver:self selector:@selector(queryNote:) name:nil object:query];
	}
	return self;
}

- (void)dealloc 
{
	[nc removeObserver:self];
	[relatedTags release];
	[query release];
	[super dealloc];
}

#pragma mark accessors
- (void)addTag:(NNTag*)aTag
{
	[relatedTags addObject:aTag];
	
	[nc postNotificationName:@"NNRelatedTagsHaveChanged" object:self];
}

- (void)addTags:(NSArray*)someTags
{
	[relatedTags addObjectsFromArray:someTags];
	
	[nc postNotificationName:@"NNRelatedTagsHaveChanged" object:self];
}

- (void)removeTag:(NNTag*)aTag
{
	if ([relatedTags count] > 0)
	{
		[relatedTags removeObject:aTag];
		
		[nc postNotificationName:@"NNRelatedTagsHaveChanged" object:self];
	}
}

- (void)removeTags:(NSArray*)someTags
{
	NSUInteger beforeCount = [self count];
	
	[relatedTags removeObjectsInArray:someTags];
	
	// post notification if something was removed
	if ([self count] < beforeCount)
		[nc postNotificationName:@"NNRelatedTagsHaveChanged" object:self];
}

- (BOOL)isUpdating
{
	return updating;
}

- (void)setUpdating:(BOOL)flag
{
	updating = flag;
}

- (BOOL)containsTag:(NNTag*)aTag
{
	return [relatedTags containsObject:aTag];
}

- (void)setQuery:(NNQuery*)aQuery 
{
	[aQuery retain];
	[query release];
	query = aQuery;
}

- (NSArray*)relatedTagArray
{
	return relatedTags;
}

- (NSMutableArray*)relatedTags;
{
	return relatedTags;
}

- (NSUInteger)count
{
	return [relatedTags count];
}

- (void)setRelatedTags:(NSMutableArray*)otherTags
{
	[otherTags retain];
	[relatedTags release];
	relatedTags = otherTags;
	
	[nc postNotificationName:@"NNRelatedTagsHaveChanged" object:self];
}

- (void)removeAllTags
{
	if ([self count] > 0)
	{
		[relatedTags removeAllObjects];
		
		[nc postNotificationName:@"NNRelatedTagsHaveChanged" object:self];
	}
}

#pragma mark logic
//act on query notifications -- relatedTags need to be kept in sync with files
- (void)queryNote:(NSNotification*)note 
{
	// check if objects are available
	if ([note name] == nil)
	{
		lcl_log(lcl_cnntagging, lcl_vError, @"Notificaton name not available");
		return;
	}
	
	// do the work
	if ([[note name] isEqualToString:NNQueryDidStartGatheringNotification])
	{
		[self setUpdating:YES];
	}
	else if ([[note name] isEqualToString:NNQueryGatheringProgressNotification] 
			 || [[note name] isEqualToString:NNQueryDidUpdateNotification]) 
	{
		[self updateRelatedTags];
	}
	else if ([[note name] isEqualToString:NNQueryDidFinishGatheringNotification])
	{
		[self updateRelatedTags];
		[self setUpdating:NO];
		
		// if no tags what so ever have been found, post notification so that tag cloud
		// can update its message
		if ([self count] == 0)
		{
			[nc postNotificationName:@"NNRelatedTagsHaveChanged" object:self];
		}
	}
	else if ([[note name] isEqualToString:NNQueryDidResetNotification])
	{
		[self removeAllTags];
	}
}

- (void)updateRelatedTags
{
	[query disableUpdates];
	
	NSMutableArray *newRelatedTags = [NSMutableArray array];
	
	for (NNTaggableObject* taggableObject in [query flatPlainResults])
	{
		//get the related tags to the current results
		for (NNTag* tag in [taggableObject tags]) 
		{
			if (![newRelatedTags containsObject:tag])
			{
				// only add if not already present
				[newRelatedTags addObject:tag];
			}
		}
	}
	
	// remove old related Tags which are not present anymore
	NSMutableArray *tagsToDelete = [NSMutableArray array];
	
	for (NNTag* oldRelatedTag in relatedTags)
	{
		if (![newRelatedTags containsObject:oldRelatedTag])
		{
			// old related tag could not be found anymore,
			// maybe a relation was deleted
			// or the selected tags have changed completely
			[tagsToDelete addObject:oldRelatedTag];
		}
		else
		{
			// otherwise remove the tag from the new tags
			[newRelatedTags removeObject:oldRelatedTag];
		}
	}
	// newRelatedTags now holds only newly found related tags ;)
	
	// remove tags from selected tags from newRelatedTags
	NNSelectedTags *selectedTags = [query tags];
	[newRelatedTags removeObjectsInArray:[selectedTags selectedTags]];
	
	// remove tags in tagsToDelete from related Tags - post a single notification
	[self removeTags:tagsToDelete];
	
	// add new tags if there are any
	if ([newRelatedTags count] > 0)
		[self addTags:newRelatedTags];
	
	// reenable the query
	[query enableUpdates];
}

- (NSString*)description
{
	return [NSString stringWithFormat:@"Related Tags: %@",relatedTags];
}

@end
