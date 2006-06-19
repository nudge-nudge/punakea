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

@interface PARelatedTags : NSObject {
	NSNotificationCenter *nf;
	
	PAQuery *paquery;
	//TODO switch to PAQuery
	NSMetadataQuery *query;
	
	NSMutableArray *selectedTags;
	NSMutableArray *relatedTags;
	
	PATags *tags; /**<all tags*/
}

- (id)initWithTags:(PATags*)otherTags selectedTags:(NSMutableArray*)otherSelectedTags;
- (id)initWithQuery:(NSMetadataQuery*)aQuery tags:(PATags*)otherTags;

- (void)setQuery:(NSMetadataQuery*)aQuery;
- (void)setTags:(PATags*)otherTags;

- (NSMutableArray*)relatedTags;
- (void)setRelatedTags:(NSMutableArray*)otherTags;
- (void)insertObject:(PATag *)tag inRelatedTagsAtIndex:(unsigned int)i;
- (void)removeObjectFromRelatedTagsAtIndex:(unsigned int)i;

- (void)removeAllObjectsFromRelatedTags;

- (NSMutableArray*)selectedTags;
- (void)setSelectedTags:(NSMutableArray*)otherTags;
- (void)insertObject:(PATag *)tag inSelectedTagsAtIndex:(unsigned int)i;
- (void)removeObjectFromSelectedTagsAtIndex:(unsigned int)i;

@end