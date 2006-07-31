//
//  PAQuery.h
//  punakea
//
//  Created by Daniel on 21.05.06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PATag.h"
#import "PATagger.h"
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
	
	PASelectedTags *tags;
	
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

//synchronous searching
- (NSArray*)filesForTag:(PASimpleTag*)tag;

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