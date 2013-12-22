// Copyright (c) 2006-2013 nudge:nudge (Johannes Hoffart & Daniel Bär). All rights reserved.
// 
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "NNQuery.h"

#import "NNFile.h"

#import "lcl.h"

NSString * const NNQueryDidStartGatheringNotification = @"NNQueryDidStartGatheringNotification";
NSString * const NNQueryGatheringProgressNotification = @"NNQueryGatheringProgressNotification";
NSString * const NNQueryDidUpdateNotification = @"NNQueryDidUpdateNotification";
NSString * const NNQueryDidFinishGatheringNotification = @"NNQueryDidFinishGatheringNotification";
NSString * const NNQueryDidResetNotification = @"NNQueryDidResetNotification";

@interface NNQuery (PrivateAPI)

- (void)tagsHaveChanged:(NSNotification *)note;
- (void)createQueryFromTags;
- (NSString*)queryStringForTags:(NSArray*)tags;
- (NSString*)dateRestrictionQueryString;

- (void)createQuery;
- (void)setMdquery:(MDQueryRef)query;

- (void)sortResults;
- (void)filterResults;

- (NSDictionary *)synchronizeResults;
- (NSArray *)wrapMetadataQueryResults:(MDQueryRef)query;
- (NSDictionary *)compareNewResults:(NSArray *)newResults toOld:(NSArray *)oldResults;

- (NSPredicate *)predicate;
- (void)setPredicate:(NSPredicate *)aPredicate;

- (NSMutableArray *)plainResults;
- (void)setPlainResults:(NSMutableArray *)newResults;
- (void)setFlatPlainResults:(NSMutableArray *)newFlatResults;
- (NSArray *)filteredResults;
- (void)setFilteredResults:(NSMutableArray *)newResults;
- (NSArray *)flatFilteredResults;
- (void)setFlatFilteredResults:(NSMutableArray *)newResults;

- (NSMutableDictionary *)bundles;
- (void)setBundles:(NSMutableDictionary *)theBundles;

- (void)setStopped:(BOOL)flag;
- (void)setGathering:(BOOL)flag;
- (void)setStarted:(BOOL)flag;

@end 

@implementation NNQuery

#pragma mark Init + Dealloc
- (id)init
{
	return [self initWithTags:[[[NNSelectedTags alloc] init] autorelease]];
}

// designated initializer
- (id)initWithTags:(NNSelectedTags*)otherTags
{
	if (self = [super init])
	{	
		filters = [[NSMutableArray alloc] init];
		
		startDate = nil;
		endDate = nil;
		
		mdquery = NULL;
		
		// configure parameters
		batchingParams.first_max_num = 10000;
		batchingParams.first_max_ms = 1000;
		batchingParams.progress_max_num = 10000;
		batchingParams.progress_max_ms = 1000;
		batchingParams.update_max_num = 10000;
		batchingParams.update_max_ms = 1000;
		
		tagToFileWriter = [[NNTagStoreManager defaultManager] tagToFileWriter];
		tagsSpotlightMetadataField = [tagToFileWriter spotlightMetadataField];
		
		valueListAttrs = [[NSArray alloc] initWithObjects:
						  (id)kMDItemPath,
						  (id)kMDItemDisplayName,
						  (id)kMDItemKind,
						  (id)kMDItemContentType,
						  (id)kMDItemLastUsedDate,
						  (id)kMDItemContentTypeTree,
						  tagsSpotlightMetadataField,
						  nil];
															
		[self setStarted:NO];
		[self setStopped:NO];
		[self setGathering:NO];
		
		metadataCacheFolder = [[@"~/Library/Caches/Metadata" stringByExpandingTildeInPath] retain];
		
		NSSortDescriptor *desc = [[NSSortDescriptor alloc] initWithKey:@"displayName" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
		sortDescriptors = [[NSArray arrayWithObject:desc] retain];
		[desc release];
				
		[self setTags:otherTags];
	}
	return self;
}

- (void)dealloc
{
	[tags release];
	[sortDescriptors release];
	[metadataCacheFolder release];
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	if (mdquery) CFRelease(mdquery);
	[bundlingAttributes release];
	[filterDict release];
	[bundles release];
	[valueListAttrs release];
	if (startDate != nil) [startDate release];
	if (endDate!= nil) [endDate release];
	[filters release];
	[super dealloc];
}

#pragma mark Actions
- (BOOL)startQuery
{
	// Cleanup results
	[self setPlainResults:[NSMutableArray array]];
	[self setFlatPlainResults:[NSMutableArray array]];
	[self setFilteredResults:[NSMutableArray array]];
	[self setFlatFilteredResults:[NSMutableArray array]];
	
	[self setBundles:[NSMutableDictionary dictionary]];
	
	[self createQueryFromTags];
	
	if (mdquery != NULL)
	{
		[self setStopped:NO];
		[self setStarted:YES];
		[self setGathering:YES];
		return MDQueryExecute(mdquery, kMDQueryWantsUpdates);
	}
	else
	{
		return NO;
	}
}

- (NSArray*)executeSynchronousQueryForString:(NSString*)queryString
{
	CFStringRef searchString = (CFStringRef)queryString;
	MDQueryRef synchronousQuery = MDQueryCreate(NULL,searchString,(CFArrayRef)valueListAttrs,NULL);
	
	NSArray *resultArray = nil;
	
	if (synchronousQuery != NULL)
	{
		// Set search scope
		CFArrayRef scope = (CFArrayRef)[NSArray arrayWithObjects:(NSString *)kMDQueryScopeAllIndexed, nil];
		MDQuerySetSearchScope(synchronousQuery, scope, 0);
		
		MDQueryExecute(synchronousQuery,kMDQuerySynchronous);
		resultArray = [self wrapMetadataQueryResults:synchronousQuery]; 
		CFRelease(synchronousQuery);
	}
	else
	{
		lcl_log(lcl_cnntagging, lcl_vWarning, @"Could not create query for '%@'", searchString);
		resultArray = [NSArray array];
	}
	
	return resultArray;
}

- (NSArray *)executeSynchronousQuery
{
	return [self executeSynchronousQueryWithBundlingAttribute:nil];
}

- (NSArray *)executeSynchronousQueryWithBundlingAttribute:(NSString *)attr
{
	CFStringRef searchString = (CFStringRef)[self queryStringForTags:[tags selectedTags]];
	MDQueryRef synchronousQuery = MDQueryCreate(NULL,searchString,(CFArrayRef)valueListAttrs,NULL);
	
	if (synchronousQuery == NULL) 
	{
		lcl_log(lcl_cnntagging, lcl_vWarning, @"Could not create query for '%@'", searchString);
		return [NSArray array];
	}
	
	// Set search scope
	CFArrayRef scope = (CFArrayRef)[NSArray arrayWithObjects:(NSString *)kMDQueryScopeAllIndexed, nil];
	MDQuerySetSearchScope(synchronousQuery, scope, 0);
	
	MDQueryExecute(synchronousQuery,kMDQuerySynchronous);
	
	NSArray *results = [self wrapMetadataQueryResults:synchronousQuery];

	CFRelease(synchronousQuery);

	NSMutableArray *bundledResults = [NSMutableArray array];
	
	// Bundle results
	if(attr)
	{
		// Dictionary that stores key-value pairs for bundles,
		// i.e. "PDF Documents" <-> corresponding bundle
		NSMutableDictionary *theBundles = [NSMutableDictionary dictionary];
		
		for(NNFile *item in results)
		{
			// Add the item to the matching bundle. Subbundles are not supported, yet.
			
			// Value for bundling attribute may not be a string!
			id bundlingAttributeValue = [item valueForAttribute:attr];
			
			NSString *bundleValue;
			if([bundlingAttributeValue isKindOfClass:[NSString class]])
			{
				bundleValue = bundlingAttributeValue;
			} else {
				bundleValue = [NNTaggableObject replaceMetadataValue:bundlingAttributeValue
														forAttribute:attr];
			}
			
			// Create bundle if not exists
			NNQueryBundle *bundle = [theBundles objectForKey:bundleValue];
			if(!bundle)
			{
				bundle = [NNQueryBundle bundle];
				[bundle setValue:bundleValue];
				[bundle setBundlingAttribute:attr];
				[theBundles setObject:bundle forKey:bundleValue];
				
				[bundledResults addObject:bundle];
			}
			
			// Add item to bundle
			if(![bundle containsObject:item])
				[bundle addObject:item];
		}
		
		// Sort items of bundles
		for(NNQueryBundle *bundle in bundledResults)
		{
			[bundle sortUsingDescriptors:sortDescriptors];
		}
	}
		
	return attr ? bundledResults : results;
}

- (void)stopQuery
{	
	[self setGathering:NO];
	[self setStopped:YES];
	MDQueryStop(mdquery);
}

- (void)disableUpdates
{
	[self setGathering:NO];
	MDQueryDisableUpdates(mdquery);
}

- (void)enableUpdates
{
	MDQueryEnableUpdates(mdquery);
	[self setGathering:YES];
}

#pragma mark Notifications

/**
 Wrap, process and forward notifications of MDQuery
 */
void notificationCallback (CFNotificationCenterRef center,
						   void *observer,
						   CFStringRef name,
						   const void *object,
						   CFDictionaryRef userInfo)
{
	if (observer == NULL)
	{
		 lcl_log(lcl_cnntagging, lcl_vError, @"Observer gone");
		 return;
	 }
	
	// wrap notifitcations to NSNotificationCenter
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	
	if (CFStringCompare(name,kMDQueryDidFinishNotification,0) == kCFCompareEqualTo)
	{
		[(NNQuery*)observer setGathering:NO];
		NSDictionary *info = [(NNQuery*)observer synchronizeResults];
		[nc postNotificationName:NNQueryDidFinishGatheringNotification object:(NNQuery*)observer userInfo:info];
	}
	else if (CFStringCompare(name,kMDQueryDidUpdateNotification,0) == kCFCompareEqualTo)
	{
		NSDictionary *info = [(NNQuery*)observer synchronizeResults];
		[nc postNotificationName:NNQueryDidUpdateNotification object:(NNQuery*)observer userInfo:info];
	} 
	else if (CFStringCompare(name,kMDQueryProgressNotification,0) == kCFCompareEqualTo)
	{
		NSDictionary *info = [(NNQuery*)observer synchronizeResults];
		[nc postNotificationName:NNQueryGatheringProgressNotification object:(NNQuery*)observer userInfo:info];
	}
}


#pragma mark query updating
- (void)createQueryFromTags
{
	// remove observer
	CFNotificationCenterRef cfnc = CFNotificationCenterGetLocalCenter();
	CFNotificationCenterRemoveObserver(cfnc, self, NULL, (void *)mdquery);
	
	// release old query
	if (mdquery)
		CFRelease(mdquery);

	NSString *queryString = @"";
	
	NSString *tagAndContentString = [self queryStringForTags:[tags selectedTags]];
	
	if ([tagAndContentString length] > 0)
	{
		queryString = tagAndContentString;
	}
	
	NSString *dateString = [self dateRestrictionQueryString];
	
	if (dateString != nil)
	{
		queryString = dateString;
	}
	
	if (([tagAndContentString length] > 0) && (dateString != nil))
	{
		queryString = [NSString stringWithFormat:@"(%@) && (%@)",tagAndContentString,dateString];
	}
	
	mdquery = MDQueryCreate(NULL, (CFStringRef)queryString, (CFArrayRef)valueListAttrs, NULL);
	
	if (mdquery != NULL)
	{		
		// Set search scope
		CFArrayRef scope = (CFArrayRef)[NSArray arrayWithObjects:(NSString *)kMDQueryScopeAllIndexed, nil];
		MDQuerySetSearchScope(mdquery, scope, 0);
		
		// configure query
		MDQuerySetBatchingParameters(mdquery,batchingParams);
		
		CFNotificationCenterAddObserver(cfnc, self, notificationCallback, NULL, (void *)mdquery, CFNotificationSuspensionBehaviorDeliverImmediately);
	}
	
	[[NSNotificationCenter defaultCenter] postNotificationName:NNQueryDidResetNotification object:self];
}

- (NSString*)queryStringForTags:(NSArray*)someTags
{
	// get string for selected tags
	NSMutableString *queryString = [NSMutableString stringWithString:[tags queryString]];
	
	// add stuff from query filters
	// filters are || for the moment
	NSEnumerator *filterEnumerator = [filters objectEnumerator];
	NNQueryFilter *filter;
	NSMutableString *filterString = [NSMutableString stringWithString:@""];
	
	while (filter = [filterEnumerator nextObject])
	{
		// if there is no tag, there must not be && in front of the string
		if ([filterString isEqualToString:@""])
		{
			[filterString appendString:[filter filterPredicateString]];
		}
		else
		{
			[filterString appendString:[NSString stringWithFormat:@" && %@",[filter filterPredicateString]]];
		}
	}
	
	// decide if a concatenating operator is needed
	NSString *operator = ([queryString length] > 0 && [filterString length] > 0) ? @" && " : @"";
	
	// join the filter string to the query string	
	[queryString appendFormat:@"%@%@",operator,filterString];
	
	// if there is any query content, limit it to kMDItemOMUserTags
	if (([queryString length] > 0) && ([queryString rangeOfString:@"kMDItemOMUserTags"].location == NSNotFound))
	{
		[queryString insertString:[tagToFileWriter scopeLimiter] atIndex:0];
	}
		
	return queryString;
}

- (NSString*)dateRestrictionQueryString
{
	NSString *startRestriction = nil;
	NSString *endRestriction = nil;
	
	NSString *dateRestriction = nil;
	
	if ([self startDate] != nil)
	{
		startRestriction = [NSString stringWithFormat:@"kMDItemOMUserTagTime >= $time.iso(%@)",startDate];
		dateRestriction = startRestriction;
	}
	
	if ([self endDate] != nil)
	{
		endRestriction = [NSString stringWithFormat:@"kMDItemOMUserTagTime <= $time.iso(%@)",endDate];
		dateRestriction = endRestriction;
	}
	
	// if both are set, we need to combine both restrictions with &&
	if ((startRestriction != nil) && (endRestriction != nil))
	{
		dateRestriction = [NSString stringWithFormat:@"%@ && %@",startRestriction,endRestriction];
	}
	
	return dateRestriction;
}

#pragma mark result synchronization
/**
 Synchronizes results of MetadataQuery
 @return Dictionary with added/removed/updated items
 */
- (NSDictionary *)synchronizeResults
{
	[self disableUpdates];
	
	// wrap MDItemRefs into files
	NSArray *queryResults = [self wrapMetadataQueryResults:mdquery];
	
	NSDictionary *userInfo = [self compareNewResults:queryResults toOld:[self flatPlainResults]];
	NSArray *addedItems = [userInfo objectForKey:(id)kMDQueryUpdateAddedItems];
	NSArray *removedItems = [userInfo objectForKey:(id)kMDQueryUpdateRemovedItems];
		
	// 1. Update flatResults
	[[self flatPlainResults] addObjectsFromArray:addedItems];
	[[self flatPlainResults] removeObjectsInArray:removedItems];

	[[self flatPlainResults] sortUsingDescriptors:sortDescriptors];
	
	// 2. Update results	
	if([self bundlingAttributes] && [[self bundlingAttributes] count] >= 1)
	{		
		// --- Add items
		for (NNFile *item in addedItems)
		{
			// Add the item to the matching bundle on level 1. if there are sub-bundles,
			// that bundle might handle any further moving of this item IN THE FUTURE - TODO.
			NSString *bundlingAttribute = [[self bundlingAttributes] objectAtIndex:0];		
			id bundlingAttributeValue = [item valueForAttribute:bundlingAttribute];
			
			NSString *bundleValue;
			if([bundlingAttributeValue isKindOfClass:[NSString class]])
			{
				bundleValue = (NSString *)bundlingAttributeValue;
			} else {
				bundleValue = [NNTaggableObject replaceMetadataValue:bundlingAttributeValue
															  forAttribute:bundlingAttribute];
			}
			
			NNQueryBundle *bundle = [bundles objectForKey:bundleValue];
			if(!bundle)
			{
				// Create new bundle
				bundle = [NNQueryBundle bundle];
				[bundle setValue:bundleValue];
				[bundle setBundlingAttribute:bundlingAttribute];
				
				// Add to bundles dictionary
				[bundles setObject:bundle forKey:bundleValue];
				
				// Add to results
				[[self plainResults] addObject:bundle];
			}
			
			if(![bundle containsObject:item])
				[bundle addObject:item];
		}
		
		// --- Remove items
		for (NNFile *item in removedItems)
		{
			// Remove the item from the matching bundle on level 1. if there are sub-bundles,
			// that bundle might handle any further removing of this item IN THE FUTURE - TODO.
			NSString *bundlingAttribute = [[self bundlingAttributes] objectAtIndex:0];		
			id bundlingAttributeValue = [item valueForAttribute:bundlingAttribute];
			
			NSString *bundleValue;
			if([bundlingAttributeValue isKindOfClass:[NSString class]])
			{
				bundleValue = (NSString *)bundlingAttributeValue;
			} else {
				bundleValue = [NNTaggableObject replaceMetadataValue:bundlingAttributeValue
														forAttribute:bundlingAttribute];
			}
			
			NNQueryBundle *bundle = [bundles objectForKey:bundleValue];
			[bundle removeObject:item];
			
			// Check for empty bundle
			if([bundle resultCount] == 0)
			{
				// Remove bundle from results
				[[self plainResults] removeObject:bundle];
				
				// Remove from bundles dictionary
				[bundles removeObjectForKey:[bundle value]];
			}
		}
	}
	else {
		[[self plainResults] addObjectsFromArray:addedItems];
		[[self plainResults] removeObjectsInArray:removedItems];
	}
	
	// 3. Update filteredResults and flatFilteredResults
	[self filterResults];
	
	[self sortResults];
	
	[self enableUpdates];
	
	return userInfo;
}

- (void)sortResults
{
	NSEnumerator *enumerator = [bundles objectEnumerator];
	NNQueryBundle *bundle;
	while(bundle = [enumerator nextObject])
	{
		[bundle sortUsingDescriptors:sortDescriptors];
	}
	
	if ([bundlingAttributes count] == 0) {
		// there are no bundles in plain results, sort by file
		[[self plainResults] sortUsingDescriptors:sortDescriptors];
	} else {
		// sort bundles
		[[self plainResults] sortUsingSelector:@selector(compare:)];
	}
	
	[filteredResults sortUsingDescriptors:sortDescriptors];
	[flatFilteredResults sortUsingDescriptors:sortDescriptors];

}

- (NSArray *)wrapMetadataQueryResults:(MDQueryRef)query
{
	NSMutableArray *wrappedItems = [NSMutableArray array];
	
	for(CFIndex i = 0; i < MDQueryGetResultCount(query); i++)
	{
		MDItemRef mditem = (MDItemRef)MDQueryGetResultAtIndex(query, i);
		NSString *path = (NSString*)MDItemCopyAttribute(mditem, kMDItemPath);
		
		// ignore items in the framework temp path
		if ([path hasPrefix:metadataCacheFolder]) {
			[path release];
			continue;
		}
		
		// get all the attributes from the query
		NSString *displayName = 
		(NSString*)MDQueryGetAttributeValueOfResultAtIndex(query, kMDItemDisplayName, i);
		NSString *kind = 
		(NSString*)MDQueryGetAttributeValueOfResultAtIndex(query, kMDItemKind, i);
		NSString *contentType =
		(NSString*)MDQueryGetAttributeValueOfResultAtIndex(query, kMDItemContentType, i);
		NSDate *lastUsed =
		(NSDate*)MDQueryGetAttributeValueOfResultAtIndex(query, kMDItemLastUsedDate, i);
		NSArray *contentTypeTree = 
		(NSArray*)MDQueryGetAttributeValueOfResultAtIndex(query, kMDItemContentTypeTree, i);
		
		// read tags from query
		id tagsSpotlightMetadataFieldValue = MDQueryGetAttributeValueOfResultAtIndex(query, (CFStringRef)tagsSpotlightMetadataField, i);
		NSArray *tagNames = [tagToFileWriter extractTagNamesFromSpotlightMetadataFieldValue:tagsSpotlightMetadataFieldValue];
		NSArray *tagArray = [[NNTags sharedTags] tagsForNames:tagNames
											  creationOptions:NNTagsCreationOptionFull];
		
		// create new NNFile with all the data
		NNFile *file = [NNFile fileWithPath:path
								displayName:displayName
									   kind:kind
								contentType:contentType
								   lastUsed:lastUsed
							contentTypeTree:contentTypeTree
									   tags:tagArray];
		
		[wrappedItems addObject:file];
		[path release];
	}
	
	return wrappedItems;
}

- (NSDictionary *)compareNewResults:(NSArray *)newResults toOld:(NSArray *)oldResults
{
	NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithCapacity:3];
	
	NSMutableArray *addedItems = [NSMutableArray array];
	NSMutableArray *removedItems = [NSMutableArray array];
				
	// First, match new to old
	for (NNFile* newResultItem in newResults)
	{
		if(![oldResults containsObject:newResultItem])
			[addedItems addObject:newResultItem];
	}
	
	// Next, match vice-versa
	for (NNFile* oldResultItem in oldResults)
	{
		if(![newResults containsObject:oldResultItem])
			[removedItems addObject:oldResultItem];
	}
	
	// Currently, this does not note if an item was modified - only removing and adding
	// of items will be passed in userInfo
	[userInfo setObject:addedItems forKey:(id)kMDQueryUpdateAddedItems];
	[userInfo setObject:removedItems forKey:(id)kMDQueryUpdateRemovedItems];

	return userInfo;
}

-	(void)filterResults:(BOOL)flag
	  	    usingValues:(NSArray *)filterValues
   forBundlingAttribute:(NSString *)attribute 
  newBundlingAttributes:(NSArray *)newAttributes
{
	if(filterDict)
	{
		[filterDict release];
		filterDict = nil;
	}
	
	if(attribute)
	{
		filterDict = [[NSMutableDictionary alloc] initWithCapacity:3];
		if(filterValues) [filterDict setObject:filterValues forKey:@"values"];
		if(attribute) [filterDict setObject:attribute forKey:@"bundlingAttribute"];
		if(newAttributes) [filterDict setObject:newAttributes forKey:@"newBundlingAttributes"];
	}
	
	[self filterResults];
}

- (void)filterResults
{
	if(filterDict) 
	{
		// Currently, we only use VALUES from the filterDict to determine all bundles
		// that match the current filter. BundlingAttribute is ignored and assumed to be ContentTypeTree.
		NSArray *filterValues = [filterDict objectForKey:@"values"];
		NSString *filterBundlingAttribute = [filterDict objectForKey:@"bundlingAttribute"];
		
		// flatFilteredResults
		
		// COMMENTED - flatFilteredResults is currently EQUAL TO filteredResults
		// as they do not subgroups at the moment. Maybe we'll activate this in the future...
		
		/*NSMutableArray *newFilteredResults = [NSMutableArray array];
		
		NSEnumerator *enumerator = [[self flatPlainResults] objectEnumerator];
		id item;
		while(item = [enumerator nextObject])
		{
			NSString *bundlingAttribute = [[self bundlingAttributes] objectAtIndex:0];		
			id bundlingAttributeValue = [item valueForAttribute:bundlingAttribute];
			
			NSString *bundleValue;
			if([bundlingAttributeValue isKindOfClass:[NSString class]])
			{
				bundleValue = (NSString *)bundlingAttributeValue;
			} else {
				bundleValue = [NNTaggableObject replaceMetadataValue:bundlingAttributeValue
														forAttribute:bundlingAttribute];
			}
			
			if([[item valueForAttribute:bundlingAttribute] isEqualTo:bundleValue])
				[newFilteredResults addObject:item];
		}
		
		// --- Sort
		if([self sortDescriptors])
			[newFilteredResults sortUsingDescriptors:[self sortDescriptors]];
		
		[self setFlatFilteredResults:newFilteredResults];*/
		
		// filteredResults		
		NSMutableArray *newFilteredResults = [NSMutableArray array];
		id item;
		
		NSEnumerator *enumerator = [[self flatPlainResults] objectEnumerator];
		while(item = [enumerator nextObject])
		{
			if ([item isKindOfClass:[NNQueryBundle class]]) {
				// ignore for now, perhaps we want to combine filtering with bundling later on				
			} else {
				if ([filterBundlingAttribute isEqualToString:@"kMDItemContentTypeTree"]) {
					NSString *itemValue = [item contentType];
				
					if ([filterValues containsObject:itemValue]) {
						[newFilteredResults	addObject:item];
					}
				}
			}
		}
		
		[self setFlatFilteredResults:newFilteredResults];	// Use the same as filteredResults, see above
		[self setFilteredResults:newFilteredResults];
	}	
}

- (BOOL)hasResultsUsingFilterWithValues:(NSArray *)filterValues
                   forBundlingAttribute:(NSArray *)attribute
{
	NSEnumerator *enumerator = [[self flatPlainResults] objectEnumerator];
	NNFile *item;
	while(item = [enumerator nextObject])
	{		
		id valueForAttribute = [item valueForAttribute:attribute];
		
		if([valueForAttribute isKindOfClass:[NSString class]])
		{
			if([filterValues containsObject:valueForAttribute])
			{
				return YES;
			}
		} else 
		{
			lcl_log(lcl_cnntagging,lcl_vError,@"Error in hasResultsUsingFilterWithValues, value should be a NSString");
		}
	}
	
	return NO;
}

- (void)fileManager:(NSFileManager *)manager willProcessPath:(NSString *)path
{
	// nothing yet
}

-(BOOL)fileManager:(NSFileManager *)manager shouldProceedAfterError:(NSDictionary *)errorInfo
{
	NSString *informativeText;
	informativeText = [NSString stringWithFormat:
		NSLocalizedStringFromTable(@"ALREADY_EXISTS_INFORMATION", @"FileManager", @""),
		[errorInfo objectForKey:@"ToPath"]];
	
    NSAlert *alert = [[[NSAlert alloc] init] autorelease];
	
	// TODO: Support correct error message text for more types of errors
	if([[errorInfo objectForKey:@"Error"] isEqualTo:@"Already Exists"])
	{
		[alert setMessageText:NSLocalizedStringFromTable([errorInfo objectForKey:@"Error"], @"FileManager", @"")];
		[alert setInformativeText:informativeText];
	} else {
		[alert setMessageText:NSLocalizedStringFromTable(@"Unknown Error", @"FileManager", @"")];
	}
	
	[alert addButtonWithTitle:@"OK"];
	[alert setAlertStyle:NSWarningAlertStyle];  
	
	[alert beginSheetModalForWindow:errorWindow
	                  modalDelegate:self
					 didEndSelector:@selector(alertDidEnd:returnCode:contextInfo:)
					    contextInfo:nil];
	
	return NO;
}

- (void)alertDidEnd:(NSAlert *)alert returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo
{
	// nothing yet
}

#pragma mark Accessors
- (NSDictionary *)simpleGrouping
{
	return simpleGrouping;
}

- (void)setSimpleGrouping:(NSDictionary *)aDictionary
{
	[simpleGrouping release];
	simpleGrouping = [aDictionary retain];
}

- (NSArray *)bundlingAttributes
{
	return bundlingAttributes;
}

- (void)setBundlingAttributes:(NSArray *)attributes
{
	if(bundlingAttributes) [bundlingAttributes release];
	bundlingAttributes = [attributes retain];
}

- (NNSelectedTags*)tags
{
	return tags;
}

- (void)setTags:(NNSelectedTags*)otherTags
{
	[otherTags retain];
	[tags release];
	tags = otherTags;
}

- (NSArray *)sortDescriptors
{
	return sortDescriptors;
}

- (void)setSortDescriptors:(NSArray*)someSortDescriptors
{
	[someSortDescriptors retain];
	[sortDescriptors release];
	sortDescriptors = someSortDescriptors;
	
	[self sortResults];
}

- (void)setStarted:(BOOL)flag
{
	started = flag;
	
	if (flag)
		[[NSNotificationCenter defaultCenter] postNotificationName:NNQueryDidStartGatheringNotification object:self];
}

- (BOOL)isStarted
{
	return started;
}

- (void)setGathering:(BOOL)flag
{
	gathering = flag;
}

- (BOOL)isGathering
{
	return gathering;
}

- (void)setStopped:(BOOL)flag
{
	stopped = flag;
}

- (BOOL)isStopped
{
	return stopped;
}

- (NSUInteger)resultCount
{
	return filterDict ? [filteredResults count] : [plainResults count];
}

- (id)resultAtIndex:(NSUInteger)idx
{
	return filterDict ? [filteredResults objectAtIndex:idx] : [plainResults objectAtIndex:idx];
}

// Public Accessor 
- (NSArray *)results
{
	return filterDict ? filteredResults : plainResults;
}

// Public Accessor 
- (NSArray *)flatResults
{
	return filterDict ? flatFilteredResults : flatPlainResults;
}

- (NSMutableArray *)plainResults
{
	return plainResults;
}

- (void)setPlainResults:(NSMutableArray *)newResults
{
	[plainResults release];
	plainResults = [newResults retain];
}

- (NSMutableArray *)flatPlainResults
{
	return flatPlainResults;
}

- (void)setFlatPlainResults:(NSMutableArray *)newFlatResults
{
	[flatPlainResults release];
	flatPlainResults = [newFlatResults retain];
}

- (NSArray*)filters
{
	return filters;
}

- (void)setFilters:(NSMutableArray*)someFilters
{
	[someFilters retain];
	[filters release];
	filters = someFilters;
	
	[self createQueryFromTags];
}

- (void)addFilter:(NNQueryFilter*)filter
{
	[filters addObject:filter];
	
	[self createQueryFromTags];
}

- (void)addFilters:(NSArray*)someFilters
{
	if ([someFilters count] > 0)
	{
		[filters addObjectsFromArray:someFilters];
		
		[self createQueryFromTags];
	}
}

- (void)removeFilter:(NNQueryFilter*)filter
{
	[filters removeObject:filter];
	
	[self createQueryFromTags];
}

- (void)removeAllFilters
{
	if ([filters count] > 0)
	{
		[filters removeAllObjects];
		
		[self createQueryFromTags];
	}
}

- (NSArray *)filteredResults
{
	return filteredResults;
}

- (void)setFilteredResults:(NSMutableArray *)newResults
{
	[filteredResults release];
	filteredResults = [newResults retain];
}

- (NSArray *)flatFilteredResults
{
	return flatFilteredResults;
}

- (void)setFlatFilteredResults:(NSMutableArray *)newResults
{
	[flatFilteredResults release];
	flatFilteredResults = [newResults retain];
}

- (BOOL)hasFilter
{
	return filterDict ? YES : NO;
}

- (NSMutableDictionary *)bundles
{
	return bundles;
}

- (void)setBundles:(NSMutableDictionary *)theBundles
{
	[bundles release];
	bundles = [theBundles retain];
}

- (NSDate*)startDate
{
	return startDate;
}

- (void)setStartDate:(NSDate*)date
{
	[startDate release];
	startDate = [date retain];
}

- (NSDate*)endDate
{
	return endDate;
}

- (void)setEndDate:(NSDate*)date
{
	[endDate release];
	endDate = [date retain];
}

@end
