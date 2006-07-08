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

 use this class if you want performance, it uses a query passed from the outside
  (i.e. from the browser)

 for a version with integrated query use PARelatedTagsStandalone
 */
@interface PARelatedTags : NSObject {
	PATagger *tagger;
	PATags *tags;
	
	NSMutableArray *relatedTags;

	NSNotificationCenter *nf;
	PAQuery *query;
	PASelectedTags *selectedTags;
}

- (id)initWithSelectedTags:(PASelectedTags*)otherSelectedTags query:(PAQuery*)aQuery;

- (PASelectedTags*)selectedTags;
- (void)setSelectedTags:(PASelectedTags*)otherTags;

- (void)setQuery:(PAQuery*)aQuery;

- (NSMutableArray*)relatedTags;
- (void)setRelatedTags:(NSMutableArray*)otherTags;
- (void)insertObject:(PATag *)tag inRelatedTagsAtIndex:(unsigned int)i;
- (void)removeObjectFromRelatedTagsAtIndex:(unsigned int)i;
- (void)removeAllObjects;

@end