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

@interface PAQuery : NSObject
{
	id delegate;
	NSPredicate *predicate;
	NSMetadataQuery *mdquery;

}

- (BOOL)startQuery;
- (void)stopQuery;

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