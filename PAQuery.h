//
//  PAQuery.h
//  punakea
//
//  Created by Daniel on 21.05.06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PATag.h"
#import "PASelectedTags.h"


/** Posted when the receiver begins with the initial result-gathering phase of the query. */
extern NSString * const PAQueryDidStartGatheringNotification;

/** Posted when new results have been found */
extern NSString * const PAQueryGatheringProgressNotification;

/** Posted when the receiver’s results have changed during the live-update phase of the query. */
extern NSString * const PAQueryDidUpdateNotification;

/** Posted when the receiver has finished with the initial result-gathering phase of the query. */
extern NSString * const PAQueryDidFinishGatheringNotification;

/** Posted when the receiver's grouping attributes have changed. */
extern NSString * const PAQueryGroupingAttributesDidChange;

/**
wrapper for NSMetadataQuery. searching for tags, no predicate needed
 */
@interface PAQuery : NSObject
{
	id delegate;
	NSMetadataQuery *mdquery;
	
	NSMutableArray *tags;
	
	NSPredicate *predicate;
	NSArray *groupingAttributes;
	
	NSMutableArray *results;
}

/**
initializer
 @param otherTags tags to search for
 */
- (id)initWithTags:(PASelectedTags*)otherTags;

- (PASelectedTags*)tags;
- (void)setTags:(PASelectedTags*)otherTags;
- (void)insertObject:(PATag *)tag inTagsAtIndex:(unsigned int)i;
- (void)removeObjectFromTagsAtIndex:(unsigned int)i;

//wrapper methods
- (BOOL)startQuery;
- (void)stopQuery;
- (void)disableUpdates;
- (void)enableUpdates;

- (BOOL)isStarted;

- (unsigned)resultCount;
- (id)resultAtIndex:(unsigned)index;
- (NSArray*)results;

- (NSArray*)groupedResults;

- (NSArray *)groupingAttributes;
- (void)setGroupingAttributes:(NSArray *)attributes;

- (NSArray *)sortDescriptors;
- (void)setSortDescriptors:(NSArray *)descriptors;

@end


/** Posted when one of the receiver's result groups did update. The userInfo dictionary
	contains the corresponding result group. */
extern NSString * const PAQueryResultGroupDidUpdate;

@interface PAQueryResultGroup : NSObject
{
	NSString *identifier;
	NSArray *subgroups;
}

@end