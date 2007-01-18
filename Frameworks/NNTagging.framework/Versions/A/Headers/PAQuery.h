//
//  PAQuery.h
//  punakea
//
//  Created by Daniel on 21.05.06.
//  Copyright 2006 nudge:nudge. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PATag.h"
#import "PATaggableObject.h"
#import "PAFile.h"

#import "PAQueryBundle.h"
#import "PASelectedTags.h"
#import "NSFileManager+TrashFile.h"


/*@interface NSObject (PAQueryDelegate)

- (id)metadataQuery:(PAQuery *)query replacementValueForAttribute:(NSString *)attrName value:(id)attrValue;

@end*/


/** Posted when the receiver begins with the initial result-gathering phase of the query. */
extern NSString * const PAQueryDidStartGatheringNotification;

/** Posted when new results have been found */
extern NSString * const PAQueryGatheringProgressNotification;

/** Posted when the receiver’s results have changed during the live-update phase of the query. */
extern NSString * const PAQueryDidUpdateNotification;

/** Posted when the receiver has finished with the initial result-gathering phase of the query. */
extern NSString * const PAQueryDidFinishGatheringNotification;

/** Posted when the query is reset - needed when results are emptied */
extern NSString * const PAQueryDidResetNotification;

/** Posted when the receiver's grouping attributes have changed. */
//extern NSString * const PAQueryGroupingAttributesDidChange;


/**
wrapper for NSMetadataQuery. searching for tags, no predicate needed
 */
@interface PAQuery : NSObject
{
	id						delegate;
	NSMetadataQuery			*mdquery;
	
	NSDictionary			*simpleGrouping;
	
	PASelectedTags			*tags;
	
	NSPredicate				*predicate;
	
	NSMutableDictionary		*bundles;
	NSArray					*bundlingAttributes;
	
	NSMutableDictionary		*filterDict;
	
	NSMutableArray			*plainResults;
	NSMutableArray			*flatPlainResults;
	NSMutableArray			*filteredResults;
	NSMutableArray			*flatFilteredResults;
	
	NSWindow				*errorWindow;
}

/**
initializer
 @param otherTags tags to search for
 */
- (id)initWithTags:(PASelectedTags*)otherTags;

- (PASelectedTags*)tags;
- (void)setTags:(PASelectedTags*)otherTags;

//wrapper methods
- (BOOL)startQuery;
- (void)stopQuery;
- (void)disableUpdates;
- (void)enableUpdates;

- (BOOL)isStarted;
- (BOOL)isGathering;
- (BOOL)isStopped;

- (unsigned)resultCount;
- (id)resultAtIndex:(unsigned)idx;
- (NSArray *)results;
- (NSArray *)flatResults;

- (NSDictionary *)simpleGrouping;
- (void)setSimpleGrouping:(NSDictionary *)aDictionary;
- (NSPredicate *)predicate;
- (void)setPredicate:(NSPredicate *)aPredicate;

- (NSArray *)bundlingAttributes;
- (void)setBundlingAttributes:(NSArray *)attributes;

- (NSArray *)sortDescriptors;
- (void)setSortDescriptors:(NSArray *)descriptors;

- (void)createQuery;
- (void)setMdquery:(NSMetadataQuery*)query;
- (BOOL)startQuery;
- (void)stopQuery;
- (void)disableUpdates;
- (void)enableUpdates;

-   (void)filterResults:(BOOL)flag
			usingValues:(NSArray *)filterValues
   forBundlingAttribute:(NSString *)attribute
  newBundlingAttributes:(NSArray *)newAttributes;
- (void)filterResults;
- (BOOL)hasResultsUsingFilterWithValues:(NSArray *)filterValues
                   forBundlingAttribute:(NSArray *)attribute;

- (void)trashItems:(NSArray *)items errorWindow:(NSWindow *)window;

//- (id)delegate;
//- (void)setDelegate:(id)aDelegate;

- (BOOL)hasFilter;

@end