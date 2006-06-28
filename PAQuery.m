//
//  PAQuery.m
//  punakea
//
//  Created by Daniel on 21.05.06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "PAQuery.h"

NSString * const PAQueryDidStartGatheringNotification = @"PAQueryDidStartGatheringNotification";
NSString * const PAQueryGatheringProgressNotification = @"PAQueryGatheringProgressNotification";
NSString * const PAQueryDidUpdateNotification = @"PAQueryDidUpdateNotification";
NSString * const PAQueryDidFinishGatheringNotification = @"PAQueryDidFinishGatheringNotification";

NSString * const PAQueryGroupingAttributesDidChange = @"PAQueryGroupingAttributesDidChange";

@interface PAQuery (PrivateAPI)

- (void)tagsHaveChanged:(NSNotification *)note;
- (void)updateQueryFromTags;

- (NSPredicate *)predicate;
- (void)setPredicate:(NSPredicate *)aPredicate;

@end 

@implementation PAQuery

#pragma mark Init + Dealloc
- (id)init
{
	return [self initWithTags:[[PASelectedTags alloc] init]];
}

- (id)initWithTags:(PASelectedTags*)otherTags
{
	if (self = [super init])
	{
		mdquery = [[NSMetadataQuery alloc] init];
		[mdquery setDelegate:self];
		[mdquery setNotificationBatchingInterval:0.3];
		
		NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
		[nc addObserver:self
		       selector:@selector(metadataQueryNote:)
			       name:nil
				 object:mdquery];
		
		[self setTags:otherTags];
	}
	return self;
}

- (void)dealloc
{
	if ([self isStarted]) [self stopQuery];	
	if(mdquery) [mdquery release];
	if(groupingAttributes) [groupingAttributes release];
	if(predicate) [predicate release];
	[super dealloc];
}

#pragma mark Actions
- (BOOL)startQuery
{
	// TODO: Smart caching!
	
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

- (void)disableUpdates
{
	[mdquery disableUpdates];
}

- (void)enableUpdates
{
	[mdquery enableUpdates];
}

- (BOOL)isStarted
{
	return [mdquery isStarted];
}

- (unsigned)resultCount
{
	return [mdquery resultCount];
}

- (id)resultAtIndex:(unsigned)index
{
	return [mdquery resultAtIndex:index];
}

- (NSArray*)results
{
	return [mdquery results];
}

- (NSArray*)groupedResults
{
	return [mdquery groupedResults];
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

- (void)updateQueryFromTags
{
	NSMutableString *queryString = [NSMutableString stringWithString:@""];
	
	NSEnumerator *e = [tags objectEnumerator];
	PATag *tag;
	
	if (tag = [e nextObject]) 
	{
		NSString *anotherTagQuery = [NSString stringWithFormat:@"(%@)",[tag query]];
		[queryString appendString:anotherTagQuery];
	}
	
	while (tag = [e nextObject]) 
	{
		NSString *anotherTagQuery = [NSString stringWithFormat:@" && (%@)",[tag query]];
		[queryString appendString:anotherTagQuery];
	}
	
	if (![queryString isEqualToString:@""])
	{
		[self setPredicate:[NSPredicate predicateWithFormat:queryString]];
	}
	
	if (![self isStarted])
	{
		[self startQuery];
	}
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
		//TODO implement result wrapping
		//[results removeAllObjects];
		[nc postNotificationName:PAQueryDidStartGatheringNotification object:self];
	}
	
	if([[note name] isEqualTo:NSMetadataQueryGatheringProgressNotification])
	{
		[self synchronizeResults];
		[nc postNotificationName:PAQueryGatheringProgressNotification object:self];
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
	return [mdquery groupingAttributes];
}

- (void)setGroupingAttributes:(NSArray *)attributes
{
	[mdquery setGroupingAttributes:attributes];
	
	// Post notification
	[[NSNotificationCenter defaultCenter] postNotificationName:PAQueryGroupingAttributesDidChange
														object:self];
}

- (NSArray *)sortDescriptors
{
	return [mdquery sortDescriptors];
}


- (void)setSortDescriptors:(NSArray *)descriptors
{
	[mdquery setSortDescriptors:descriptors];
}

- (PASelectedTags*)tags
{
	return tags;
}

- (void)setTags:(PASelectedTags*)otherTags
{
	[otherTags retain];
	[tags release];
	tags = otherTags;
	
	[self updateQueryFromTags];
}

- (void)insertObject:(PATag *)tag inTagsAtIndex:(unsigned int)i
{
	[tags insertObject:tag atIndex:i];
	
	[self updateQueryFromTags];
}

- (void)removeObjectFromTagsAtIndex:(unsigned int)i
{
	[tags removeObjectAtIndex:i];
	
	[self updateQueryFromTags];
}
@end
