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
	return [self initWithTags:[NSMutableArray array]];
}

- (id)initWithTags:(NSMutableArray*)otherTags
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
		[mdquery setPredicate:[NSPredicate predicateWithFormat:queryString]];
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

- (NSMutableArray*)tags
{
	return tags;
}

- (void)setTags:(NSMutableArray*)otherTags
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
