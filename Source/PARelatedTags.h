//
//  PARelatedTags.h
//  punakea
//
//  Created by Johannes Hoffart on 11.03.06.
//  Copyright 2006 nudge:nudge. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PATagging/PAFile.h"
#import "PATagging/PATag.h"
#import "PATagging/PATags.h"
#import "PAQuery.h"
#import "PASelectedTags.h"

/**
finds related tags for a given query or a given selection of tags.

 use this class if you want performance, it uses a query passed from the outside and observes its changes
  (i.e. from the browser)

 for a version with integrated query use PARelatedTagsStandalone
 
 posts PARelatedTagsHaveChanged notification on update
 */
@interface PARelatedTags : NSObject {
	PATags *tags;
	
	NSMutableArray *relatedTags;
	BOOL updating;

	NSNotificationCenter *nc;
	PAQuery *query;
	PASelectedTags *selectedTags;
}

/**
initializes related tags with some selected tags and a query
 @param otherSelectedTags is needed because related tags cannot contains tags from selected tags
 @param aQuery the query passed from the outside is observed and related tags adjusted periodically
 */
- (id)initWithSelectedTags:(PASelectedTags*)otherSelectedTags query:(PAQuery*)aQuery;

- (BOOL)isUpdating;
- (void)setUpdating:(BOOL)flag;

- (BOOL)containsTag:(PATag*)aTag;

- (PASelectedTags*)selectedTags;
- (void)setSelectedTags:(PASelectedTags*)otherTags;

- (void)setQuery:(PAQuery*)aQuery;

- (NSMutableArray*)relatedTags;
- (void)setRelatedTags:(NSMutableArray*)otherTags;

- (void)removeAllTags;

@end