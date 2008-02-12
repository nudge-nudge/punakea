//
//  PAContentTypeFilter.m
//  NNTagging
//
//  Created by Johannes Hoffart on 19.04.07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "PAContentTypeFilter.h"

@interface PAContentTypeFilter (PrivateAPI)

- (void)createFiltersForContentType:(NSString*)contentType;

@end

@implementation PAContentTypeFilter

#pragma mark init
- (id)initWithContentType:(NSString*)type
{
	if (self = [super init])
	{
		weight = 10;
		contentType = [type copy];
		
		tagCache = [PATagCache sharedInstance];
		
		selectedTags = [[NNSelectedTags alloc] init];
		query = [[NNQuery alloc] initWithTags:selectedTags];

		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(queryNote:) 
													 name:NNQueryGatheringProgressNotification 
												   object:query];
		
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(queryNote:) 
													 name:NNQueryDidFinishGatheringNotification 
												   object:query];
		
		filterLock = [[NSLock alloc] init];
		
		NNContentTypeTreeQueryFilter *filter = [NNContentTypeTreeQueryFilter contentTypeTreeQueryFilterForType:type];
		[query addFilter:filter];
	}
	return self;
}

- (void)dealloc
{
	[filterLock release];
	[query release];
	[selectedTags release];
	[contentType release];
	[super dealloc];
}

+ (PAContentTypeFilter*)filterWithContentType:(NSString*)type
{
	PAContentTypeFilter* filter = [[PAContentTypeFilter alloc] initWithContentType:type];
	return [filter autorelease];
}

#pragma mark accessors
- (NSString*)contentType
{
	return contentType;
}

#pragma mark function
- (void)filterObject:(id)object
{
	[super filterObject:object];
	
	// look if cache can satisfy request
	PACacheResult result = [tagCache checkFiletype:[self contentType] forTag:object];
	
	if (result & PACacheIsValid)
	{
		if (result & PACacheSatisfiesRequest)
		{
			// cache was valid and object is good to go			
			[self objectFiltered:object];
		}
	}
	else
	{
		// execute a query with the given tag to see if it has any files
		// matching the content type
		[selectedTags setSelectedTags:[NSArray arrayWithObject:object]];
		NSArray *results = [query executeSynchronousQuery];
		
		if ([results count] > 0)
		{
			// update cache
			[tagCache updateCacheForTag:object
							setFiletype:[self contentType]
								toValue:YES];
			
			[self objectFiltered:object];
		}
		else
		{
			// update cache
			[tagCache updateCacheForTag:object
							setFiletype:[self contentType]
								toValue:NO];
		}
	}
}

- (NSString*)description
{
	return [NSString stringWithFormat:@"PAContentTypeFilter: %@",contentType];
}

@end
