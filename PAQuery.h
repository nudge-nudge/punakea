//
//  PAQuery.h
//  punakea
//
//  Created by Daniel on 21.05.06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


/** Posted when the receiver begins with the initial result-gathering phase of the query. */
extern NSString * const PAQueryDidStartGatheringNotification;

/** Posted when the receiver’s results have changed during the live-update phase of the query. */
extern NSString * const PAQueryDidUpdateNotification;

/** Posted when the receiver has finished with the initial result-gathering phase of the query. */
extern NSString * const PAQueryDidFinishGatheringNotification;

/** Posted when the receiver's grouping attributes have changed. */
extern NSString * const PAQueryGroupingAttributesDidChange;

@interface PAQuery : NSObject
{
	id delegate;
	NSMetadataQuery *mdquery;
	
	NSPredicate *predicate;
	NSArray *groupingAttributes;
	
	NSMutableArray *results;

}

- (BOOL)startQuery;
- (void)stopQuery;

- (unsigned)resultCount;
- (id)resultAtIndex:(unsigned)index;

- (NSPredicate *)predicate;
- (void)setPredicate:(NSPredicate *)aPredicate;

- (NSArray *)groupingAttributes;
- (void)setGroupingAttributes:(NSArray *)attributes;

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