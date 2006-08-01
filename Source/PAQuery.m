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

//NSString * const PAQueryGroupingAttributesDidChange = @"PAQueryGroupingAttributesDidChange";

@interface PAQuery (PrivateAPI)

- (void)tagsHaveChanged:(NSNotification *)note;
- (void)updateQueryFromTags;
- (NSString*)queryStringForTags:(NSArray*)tags;

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
		[self setDelegate:self];
	
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
	if(bundlingAttributes) [bundlingAttributes release];
	if(predicate) [predicate release];
	[super dealloc];
}

#pragma mark Synchronous Searching
- (NSArray*)filesForTag:(PASimpleTag*)tag
{
	NSString *searchString = [self queryStringForTags:[NSArray arrayWithObjects:tag,nil]];
	MDQueryRef *query = MDQueryCreate(NULL,searchString,NULL,NULL);
	MDQueryExecute(query,kMDQuerySynchronous);
	CFIndex resultCount = MDQueryGetResultCount(query);
	
	NSMutableArray *results = [NSMutableArray array];
	
	for (int i=0;i<resultCount;i++)
	{
		MDItemRef *mditem = MDQueryGetResultAtIndex(query,i);
		NSString *fileName = MDItemCopyAttribute(mditem,@"kMDItemPath");
		[results addObject:fileName];
	}

	return results;
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

- (NSArray *)results
{
	return results;
}


/**
	Synchronizes results of MetadataQuery
*/
- (void)synchronizeResults
{
	if(results) [results release];
	results = [self bundleResults:[mdquery results] byAttributes:bundlingAttributes];	
	
	NSEnumerator *enumerator = [results objectEnumerator];
	id object;
	while(object = [enumerator nextObject])
	{
		NSLog([object stringValue]);
	}
}


/**
	Bundles a flat list of results into a hierarchical structure
	defined by the first item of bundlingAttributes
*/
- (NSArray *)bundleResults:(NSArray *)results byAttributes:(NSArray *)bundlingAttributes
{
	NSMutableDictionary *bundleDict = [NSMutableDictionary dictionary];
	
	NSMutableArray *bundledResults = [NSMutableArray array];
	
	NSString *bundlingAttribute;
	if(bundlingAttributes)
	{
		bundlingAttribute = [bundlingAttributes objectAtIndex:0];
	}

	NSEnumerator *resultsEnumerator = [results objectEnumerator];
	NSMetadataItem *mdItem;
	while(mdItem = [resultsEnumerator nextObject])
	{	
		PAQueryBundle *bundle;
		
		if(bundlingAttribute)
		{
			id valueToBeReplaced = [mdItem valueForAttribute:bundlingAttribute];
			NSString *bundleValue = [delegate metadataQuery:self
							   replacementValueForAttribute:bundlingAttribute
							                          value:valueToBeReplaced];
		
			bundle = [bundleDict objectForKey:bundleValue];
			if(!bundle)
			{
				bundle = [[PAQueryBundle alloc] init];
				[bundle setValue:bundleValue];
				[bundleDict setObject:bundle forKey:bundleValue];
			}			
		}
		
		// Wrap mdItem into PAQueryItem
		PAQueryItem *item = [[PAQueryItem alloc] init];
		[item setValue:[mdItem valueForAttribute:(id)kMDItemDisplayName] forAttribute:@"value"];
		// TODO attributes of item
		
		if(bundlingAttribute)
		{
			[bundle addResultItem:item];
		} else {
			[bundledResults addObject:item];
		}
	}
	
	if(bundlingAttribute)
	{
		NSEnumerator *bundleEnumerator = [bundleDict objectEnumerator];
		PAQueryBundle *bundle;
		while(bundle = [bundleEnumerator nextObject])
		{
			// Bundle at next level if needed
			NSMutableArray *nextBundlingAttributes = [bundlingAttributes mutableCopy];
			[nextBundlingAttributes removeObjectAtIndex:0];
			
			if([nextBundlingAttributes count] > 0)
			{
				NSArray *subResults = [self bundleResults:[bundle results]
											 byAttributes:nextBundlingAttributes];
				[bundle setResults:subResults];
			}
		
			[bundledResults addObject:bundle];
			
			[nextBundlingAttributes release];
		}
	}
	
	return bundledResults;
}

- (void)updateQueryFromTags
{
	NSMutableString *queryString = [self queryStringForTags:[tags selectedTags]];
	
	if (![queryString isEqualToString:@""])
	{
		[self setPredicate:[NSPredicate predicateWithFormat:queryString]];
	}
	
	if (![self isStarted])
	{
		[self startQuery];
	}
}

- (NSString*)queryStringForTags:(NSArray*)tags
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
	
	return queryString;
}


#pragma mark Notifications
/**
	Wrap, process and forward notifications of NSMetadataQuery
*/
- (void)metadataQueryNote:(NSNotification *)note
{
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	
	/*if([[note name] isEqualTo:NSMetadataQueryDidStartGatheringNotification])
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
	}*/
		
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

- (NSArray *)bundlingAttributes
{
	return bundlingAttributes;
}

- (void)setBundlingAttributes:(NSArray *)attributes
{
	if(bundlingAttributes) [bundlingAttributes release];
	bundlingAttributes = [attributes retain];
	
	// Post notification
	//[[NSNotificationCenter defaultCenter] postNotificationName:PAQueryGroupingAttributesDidChange
	//													object:self];
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

@end
