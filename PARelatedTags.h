//
//  PARelatedTags.h
//  punakea
//
//  Created by Johannes Hoffart on 11.03.06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PATagger.h"
#import "PATag.h"
#import "PATags.h"
#import "PAQuery.h"
#import "PASelectedTags.h"

/**
finds related tags for a given query or a given selection of tags.
use either initWithTags: selectedTags and set the selectedTags when needed (used by the tagger)
 OR initWithTags: query: and pass a query from the outside (used by the browser)
 */
@interface PARelatedTags : NSObject {
	NSMutableArray *relatedTags;

	NSNotificationCenter *nf;
	PAQuery *query;
	PASelectedTags *selectedTags;
	PATags *tags; /**<all tags*/
}

- (id)initWithTags:(PATags*)otherTags selectedTags:(NSMutableArray*)otherSelectedTags;
- (id)initWithTags:(PATags*)otherTags query:(PAQuery*)aQuery;

- (void)setQuery:(PAQuery*)aQuery;
- (void)setTags:(PATags*)otherTags;

- (NSMutableArray*)relatedTags;
- (void)setRelatedTags:(NSMutableArray*)otherTags;
- (void)insertObject:(PATag *)tag inRelatedTagsAtIndex:(unsigned int)i;
- (void)removeObjectFromRelatedTagsAtIndex:(unsigned int)i;

- (void)removeAllObjectsFromRelatedTags;

- (PASelectedTags*)selectedTags;
- (void)setSelectedTags:(PASelectedTags*)otherTags;
- (void)insertObject:(PATag *)tag inSelectedTagsAtIndex:(unsigned int)i;
- (void)removeObjectFromSelectedTagsAtIndex:(unsigned int)i;

@end