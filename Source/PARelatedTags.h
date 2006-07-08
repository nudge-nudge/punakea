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
 
 TODO make related tags need to know which tags are selected. this class is far from perfect!!
 */
@interface PARelatedTags : NSObject {
	PATagger *tagger;
	PATags *tags;
	
	NSMutableArray *relatedTags;

	NSNotificationCenter *nf;
	PAQuery *query;
	PASelectedTags *selectedTags;
}

- (id)initWithSelectedTags:(PASelectedTags*)otherSelectedTags;
- (id)initWithQuery:(PAQuery*)aQuery;

- (PASelectedTags*)selectedTags;
- (void)setSelectedTags:(PASelectedTags*)otherTags;

- (void)setQuery:(PAQuery*)aQuery;

- (NSMutableArray*)relatedTags;
- (void)setRelatedTags:(NSMutableArray*)otherTags;
- (void)insertObject:(PATag *)tag inRelatedTagsAtIndex:(unsigned int)i;
- (void)removeObjectFromRelatedTagsAtIndex:(unsigned int)i;
- (void)removeAllObjects;

@end