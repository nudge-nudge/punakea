//
//  PAQuery.m
//  punakea
//
//  Created by Daniel on 21.05.06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "PAQuery.h"


NSString * const PAQueryDidStartGatheringNotification = @"PAQueryDidStartGatheringNotification";
NSString * const PAQueryDidUpdateNotification = @"PAQueryDidUpdateNotification";
NSString * const PAQueryDidFinishGatheringNotification = @"PAQueryDidFinishGatheringNotification";

NSString * const PAQueryGroupingAttributesDidChange = @"PAQueryGroupingAttributesDidChange";

@implementation PAQuery

#pragma mark Init + Dealloc
- (id)init
{
	if(self = [super init])
	{
		mdquery = [[NSMetadataQuery alloc] init];
		[mdquery setDelegate:self];
		[mdquery setNotificationBatchingInterval:0.3];
		
		NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
		[nc addObserver:self
		       selector:@selector(metadataQueryNote:)
			       name:nil
				 object:mdquery];
	}
	return self;
}

- (void)dealloc
{
	if(mdquery) [mdquery release];
	if(groupingAttributes) [groupingAttributes release];
	if(predicate) [predicate release];
	[super dealloc];
}


#pragma mark Actions
- (BOOL)startQuery
{
	// TODO: Smart caching!
	
	[mdquery setPredicate:predicate];
	
	// Finally, post notification
	[[NSNotificationCenter defaultCenter] postNotificationName:PAQueryDidStartGatheringNotification
														object:self];
	return [mdquery startQuery];
}

- (void)stopQuery
{
	// TODO
	
	// Finally, post notification
	[[NSNotificationCenter defaultCenter] postNotificationName:PAQueryDidUpdateNotification
														object:self];
}

- (unsigned)resultCount
{
	return [results count];
}

- (id)resultAtIndex:(unsigned)index
{
	return [results objectAtIndex:index];
}

/**
	Synchronizes results of MetadataQuery
*/
- (void)synchronizeResults
{
	// TODO: Wrap NSMetadataQueryResultGroups and NSMetadataItems and create own results array

	//if(results) [results release];
	results = [NSMutableArray arrayWithArray:[mdquery results]];
}


#pragma mark Notifications
/**
	Wrap, process and forward notifications of NSMetadataQuery
*/
- (void)metadataQueryNote:(NSNotification *)note
{
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	
	if([[note name] isEqualTo:NSMetadataQueryDidStartGatheringNotification])
	{
		[results removeAllObjects];
		[nc postNotificationName:PAQueryDidStartGatheringNotification object:self];
	}
		
	if([[note name] isEqualTo:NSMetadataQueryDidUpdateNotification])
	{
		[self synchronizeResults];
		[nc postNotificationName:PAQueryDidUpdateNotification object:self];
	}
		
	if([[note name] isEqualTo:NSMetadataQueryDidFinishGatheringNotification])
	{
		[self synchronizeResults];
		[nc postNotificationName:PAQueryDidFinishGatheringNotification object:self];
	}
}


#pragma mark Accessors
- (id)delegate
{
	return delegate;
}

- (void)setDelegate:(id)aDelegate
{
	delegate = aDelegate;
}

- (NSPredicate *)predicate
{
	return predicate;
}

- (void)setPredicate:(NSPredicate *)aPredicate
{
	predicate = aPredicate;
	[mdquery setPredicate:aPredicate];
}

- (NSArray *)groupingAttributes
{
	return groupingAttributes;
}

- (void)setGroupingAttributes:(NSArray *)attributes
{
	groupingAttributes = attributes;
	
	// Post notification
	[[NSNotificationCenter defaultCenter] postNotificationName:PAQueryGroupingAttributesDidChange
														object:self];
}
@end
