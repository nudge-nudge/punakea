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

@interface PARelatedTags : NSObject {
	NSNotificationCenter *nf;
	NSMetadataQuery *query;
	NSMutableArray *relatedTags;
}

- (id)initWithQuery:(NSMetadataQuery*)aQuery;

- (void)setQuery:(NSMetadataQuery*)aQuery;

- (NSMutableArray*)relatedTags;
- (void)setRelatedTags:(NSMutableArray*)otherTags;
- (void)insertObject:(PATag *)tag inRelatedTagsAtIndex:(unsigned int)i;
- (void)removeObjectFromRelatedTagsAtIndex:(unsigned int)i;

@end