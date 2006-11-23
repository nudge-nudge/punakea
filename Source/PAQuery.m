//
//  PAQuery.m
//  punakea
//
//  Created by Daniel on 21.05.06.
//  Copyright 2006 nudge:nudge. All rights reserved.
//

#import "PAQuery.h"

NSString * const PAQueryDidStartGatheringNotification = @"PAQueryDidStartGatheringNotification";
NSString * const PAQueryGatheringProgressNotification = @"PAQueryGatheringProgressNotification";
NSString * const PAQueryDidUpdateNotification = @"PAQueryDidUpdateNotification";
NSString * const PAQueryDidFinishGatheringNotification = @"PAQueryDidFinishGatheringNotification";
NSString * const PAQueryDidResetNotification = @"PAQueryDidResetNotification";

//NSString * const PAQueryGroupingAttributesDidChange = @"PAQueryGroupingAttributesDidChange";

@interface PAQuery (PrivateAPI)

- (void)tagsHaveChanged:(NSNotification *)note;
- (void)updateQueryFromTags;
- (NSString*)queryStringForTags:(NSArray*)tags;
- (NSString*)queryInSpotlightSyntaxForTags:(NSArray*)someTags;

- (NSPredicate *)predicate;
- (void)setPredicate:(NSPredicate *)aPredicate;

- (void)createQuery;
- (void)setMdquery:(NSMetadataQuery*)query;

- (void)synchronizeResults;
- (NSArray *)bundleResults:(NSArray *)theResults byAttributes:(NSArray *)attributes;
- (void)filterResults:(BOOL)flag usingValues:(NSArray *)filterValues forBundlingAttribute:(NSString *)attribute newBundlingAttributes:(NSArray *)newAttributes;

@end 

@implementation PAQuery

#pragma mark Init + Dealloc
- (id)init
{
	return [self initWithTags:[[[PASelectedTags alloc] init] autorelease]];
}

- (id)initWithTags:(PASelectedTags*)otherTags
{
	if (self = [super init])
	{
		[self setDelegate:self];
		[self createQuery];
		
		[self setTags:otherTags];
	}
	return self;
}

- (void)dealloc
{
	[tags release];
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	if ([self isStarted]) [self stopQuery];	
	[mdquery release];
	[bundlingAttributes release];
	[filterDict release];
	[predicate release];
	[super dealloc];
}

#pragma mark Synchronous Searching
- (NSArray*)filesForTag:(PATag*)tag
{
	CFStringRef searchString = (CFStringRef)[self queryInSpotlightSyntaxForTags:[NSArray arrayWithObject:tag]];
	MDQueryRef query = MDQueryCreate(NULL,searchString,NULL,NULL);
	MDQueryExecute(query,kMDQuerySynchronous);
	CFIndex resultCount = MDQueryGetResultCount(query);
	
	NSMutableArray *resultArray = [NSMutableArray array];
	
	for (int i=0;i<resultCount;i++)
	{
		MDItemRef queryResult = (MDItemRef) MDQueryGetResultAtIndex(query,i);
		NSString *fileName = (NSString*)MDItemCopyAttribute(queryResult,(CFStringRef)@"kMDItemPath");
		[resultArray addObject:[PAFile fileWithPath:fileName]];
	}

	CFRelease(query);
	
	return resultArray;
}

#pragma mark Actions
- (void)createQuery
{
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	[nc removeObserver:self];
	
	[self setMdquery:[[NSMetadataQuery alloc] init]];
	[mdquery setDelegate:self];
	[mdquery setNotificationBatchingInterval:0.3];
	[mdquery setSortDescriptors:[NSArray arrayWithObject:[[[NSSortDescriptor alloc] initWithKey:(id)kMDItemFSName ascending:YES] autorelease]]];
	
	[nc addObserver:self
		   selector:@selector(metadataQueryNote:)
			   name:nil
			 object:mdquery];
	
	[self synchronizeResults];
	
	[nc postNotificationName:PAQueryDidResetNotification object:self];
}

- (void)setMdquery:(NSMetadataQuery*)query
{
	[query retain];
	[mdquery release];
	mdquery = query;
}

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
	[[NSNotificationCenter defaultCenter] postNotificationName:PAQueryDidFinishGatheringNotification
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

/**
	Synchronizes results of MetadataQuery
*/
- (void)synchronizeResults
{
	[self disableUpdates];

	if(flatResults) [flatResults release];
	if(results) [results release];
	
	// We don't use [mdquery results] as this proxy array causes missing results during live update
	NSMutableArray *mdQueryResults = [NSMutableArray array];
	for(unsigned i = 0; i < [mdquery resultCount]; i++)
	{
		[mdQueryResults addObject:[mdquery resultAtIndex:i]];
	}
	
	flatResults = [self bundleResults:mdQueryResults byAttributes:nil];
	results = [self bundleResults:flatResults byAttributes:bundlingAttributes];	
	
	// Apply filter, if active
	if(filterDict)
	{
		[self filterResults:YES usingValues:[[[filterDict objectForKey:@"values"] retain] autorelease]
		               forBundlingAttribute:[[[filterDict objectForKey:@"bundlingAttribute"] retain] autorelease]
					  newBundlingAttributes:[[[filterDict objectForKey:@"newBundlingAttributes"] retain] autorelease]];
	}
	
	[self enableUpdates];
}


/**
	Bundles a flat list of results into a hierarchical structure
	defined by the first item of bundlingAttributes
*/
- (NSArray *)bundleResults:(NSArray *)theResults byAttributes:(NSArray *)attributes
{
	NSMutableDictionary *bundleDict = [NSMutableDictionary dictionary];
	
	NSMutableArray *bundledResults = [[NSMutableArray alloc] init];
	
	NSString *bundlingAttribute = nil;
	if(attributes)
	{
		bundlingAttribute = [attributes objectAtIndex:0];
	}
	
	BOOL wrapping = NO;
	if([theResults count] > 0) wrapping = [[theResults objectAtIndex:0] isKindOfClass:[NSMetadataItem class]];

	NSEnumerator *resultsEnumerator = [theResults objectEnumerator];
	//NSMetadataItem *mdItem;
	id theItem;
	while(theItem = [resultsEnumerator nextObject])
	{	
		PAQueryBundle *bundle;
		
		if(bundlingAttribute)
		{
			NSString *bundleValue;
			
			if(wrapping)
			{
				// theItem is a NSMetadataItem
				id valueToBeReplaced = [theItem valueForAttribute:bundlingAttribute];
				bundleValue = [delegate metadataQuery:self
						 replacementValueForAttribute:bundlingAttribute
						                        value:valueToBeReplaced];
			} else {
				// theItem is a PAQueryItem
				bundleValue = [theItem valueForAttribute:bundlingAttribute];
			}
		
			bundle = [bundleDict objectForKey:bundleValue];
			if(!bundle)
			{
				bundle = [[PAQueryBundle alloc] init];
				[bundle setValue:bundleValue];
				[bundle setBundlingAttribute:bundlingAttribute];
				[bundleDict setObject:bundle forKey:bundleValue];
			}			
		}
		
		// TODO: DEFINE MACRO FOR REPLACEMENTVALUEFORATTRIBUTE!
		PAQueryItem *item;
		if(wrapping)
		{
			// Wrap theItem (a NSMetadataItem) into PAQueryItem
			NSMetadataItem *mdItem = theItem;
			id value;
			item = [[PAQueryItem alloc] init];
			[item setValue:[mdItem valueForAttribute:(id)kMDItemDisplayName] forAttribute:@"value"];
			[item setValue:[mdItem valueForAttribute:(id)kMDItemDisplayName] forAttribute:(id)kMDItemDisplayName];
			[item setValue:[mdItem valueForAttribute:(id)kMDItemPath] forAttribute:(id)kMDItemPath];			
			[item setValue:[mdItem valueForAttribute:(id)kMDItemContentType] forAttribute:(id)kMDItemContentType];
			
			value = [delegate metadataQuery:self
			   replacementValueForAttribute:(id)kMDItemLastUsedDate
									  value:[mdItem valueForAttribute:(id)kMDItemLastUsedDate]];
			if(value) [item setValue:value forAttribute:(id)kMDItemLastUsedDate];
			
			// AUDIO
			value = [delegate metadataQuery:self
			   replacementValueForAttribute:(id)kMDItemAlbum
									  value:[mdItem valueForAttribute:(id)kMDItemAlbum]];
			if(value) [item setValue:value forAttribute:(id)kMDItemAlbum];
			
			value = [delegate metadataQuery:self
			   replacementValueForAttribute:(id)kMDItemAuthors
									  value:[mdItem valueForAttribute:(id)kMDItemAuthors]];
			if(value) [item setValue:value forAttribute:(id)kMDItemAuthors];
			
			value = [delegate metadataQuery:self
			   replacementValueForAttribute:@"kMDItemContentTypeTree"
									  value:[mdItem valueForAttribute:@"kMDItemContentTypeTree"]];
			if([value isEqualTo:@"DOCUMENTS"])
			{
				// Bookmarks that are stored as webloc file don't have the right content type,
				// so we set it here
				NSString *path = [mdItem valueForAttribute:(id)kMDItemPath];
				if(path && [path hasSuffix:@"webloc"])
				{
					// Set new value for Content Type Tree
					value = @"BOOKMARKS";
					
					/*
					// Set new value for Display Name
					NSString *displayName = [item valueForAttribute:(id)kMDItemDisplayName];
					[item setValue:[displayName substringToIndex:[displayName length]-7] forAttribute:(id)kMDItemDisplayName];
					*/
				}
			}
			[item setValue:value forAttribute:@"kMDItemContentTypeTree"];
			
			// TODO more attributes of item, use replacementValueForAttribute for each value!!
		
		} else {
			item = theItem;
		}
		
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
			NSMutableArray *nextBundlingAttributes = [attributes mutableCopy];
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

-   (void)filterResults:(BOOL)flag
			usingValues:(NSArray *)filterValues
   forBundlingAttribute:(NSString *)attribute
  newBundlingAttributes:(NSArray *)newAttributes
{	
	if(!flag) 
	{		
		[filterDict release];
		filterDict = nil;
		return;
	}
	
	// If there is already a filter applied, we may check if it's the right one
	BOOL isSameFilter = NO;
	/*if(filterDict)
	{
		isSameFilter = YES;
		if(![[filterDict objectForKey:@"values"] isEqualTo:filterValues]) isSameFilter = NO;
		if(![[filterDict objectForKey:@"bundlingAttribute"] isEqualTo:attribute]) isSameFilter = NO;
		if([filterDict objectForKey:@"newBundlingAttributes"] &&
		   ![[filterDict objectForKey:@"newBundlingAttributes"] isEqualTo:newAttributes]) isSameFilter = NO;
	}*/
	
	// Return if we already have results for this filter
	if(isSameFilter && flatFilteredResults) return;
	
	// Store current filter values for later use
	
	[filterDict release];
	if(attribute)
	{
		filterDict = [[NSMutableDictionary alloc] initWithCapacity:3];
		if(filterValues) [filterDict setObject:filterValues forKey:@"values"];
		if(attribute) [filterDict setObject:attribute forKey:@"bundlingAttribute"];
		if(newAttributes) [filterDict setObject:newAttributes forKey:@"newBundlingAttributes"];
	}

	[flatFilteredResults release];
	flatFilteredResults = nil;
	flatFilteredResults = [[NSMutableArray alloc] init];

	NSEnumerator *enumerator = [flatResults objectEnumerator];
	PAQueryItem *item;
	while(item = [enumerator nextObject])
	{		
		id valueForAttribute = [item valueForAttribute:attribute];
		
		if([valueForAttribute isKindOfClass:[NSString class]])
		{
			if([filterValues containsObject:valueForAttribute])
			{
				[flatFilteredResults addObject:item];
			}
		} else {
			NSLog(@"couldn't properly filter results");
		}
	}
	
	[filteredResults release];
	filteredResults = nil;
	filteredResults = [self bundleResults:flatFilteredResults byAttributes:newAttributes];
}

- (BOOL)hasResultsUsingFilterWithValues:(NSArray *)filterValues
                   forBundlingAttribute:(NSArray *)attribute
{
	NSEnumerator *enumerator = [flatResults objectEnumerator];
	PAQueryItem *item;
	while(item = [enumerator nextObject])
	{		
		id valueForAttribute = [item valueForAttribute:attribute];
		
		if([valueForAttribute isKindOfClass:[NSString class]])
		{
			if([filterValues containsObject:valueForAttribute])
			{
				return YES;
			}
		} else {
			NSLog(@"Error in hasResultsUsingFilterWithValues");
		}
	}
	
	return NO;
}

- (void)trashItems:(NSArray *)items errorWindow:(NSWindow *)window
{
	[self disableUpdates];
	
	NSString *trashDir = [NSHomeDirectory() stringByAppendingPathComponent:@".Trash"];
	
	NSEnumerator *e = [items objectEnumerator];
	PAQueryItem *item;

	while (item = [e nextObject])
	{
		PAFile *file = [PAFile fileWithPath:[item valueForAttribute:(id)kMDItemPath]];
		
		// Move to trash
		[[NSFileManager defaultManager] trashFileAtPath:[file path]];
		
		// Remove tags from trashed file to give spotlight enough time
		PAFile *trashedFile = [PAFile fileWithPath:[trashDir stringByAppendingPathComponent:[file name]]];
		[[PATagger sharedInstance] removeAllTagsFromFile:trashedFile];
		
		// Remove from flatresults
		for(int k = 0; k < [flatResults count]; k++)
		{
			if([[flatResults objectAtIndex:k] isEqualTo:item])
			{
				[flatResults removeObjectAtIndex:k];
				break;
			}
		}
	}
	
	results = [self bundleResults:flatResults byAttributes:bundlingAttributes];	
	
	// Apply filter, if active
	if(filterDict)
	{
		[self filterResults:YES usingValues:[[[filterDict objectForKey:@"values"] retain] autorelease]
		               forBundlingAttribute:[[[filterDict objectForKey:@"bundlingAttribute"] retain] autorelease]
					  newBundlingAttributes:[[[filterDict objectForKey:@"newBundlingAttributes"] retain] autorelease]];
	}
	
	[self enableUpdates];
}

- (BOOL)renameItem:(PAQueryItem *)item to:(NSString *)newName errorWindow:(NSWindow *)window
{
	errorWindow = window;
	
	NSFileManager *fm = [NSFileManager defaultManager];

	PAFile		*file = [PAFile fileWithPath:[item valueForAttribute:(id)kMDItemPath]];
	NSString	*source = [file path];
	NSString	*destination = [file directory];
	
	// Ignore case-sensitive changes to the extension - TEMP for now
	newName = [newName substringToIndex:[newName length] - [[file extension] length]];
	destination = [destination stringByAppendingPathComponent:newName];
	destination = [destination stringByAppendingString:[file extension]];
	
	// Return NO if source equals destination
	if([source isEqualToString:destination]) return NO;
	
	BOOL fileWasMovedToTemp = NO;
	NSString *tempDestination = nil;
	NSArray *tagsOnFiles = nil;
	
	if([source compare:destination options:NSCaseInsensitiveSearch] == NSOrderedSame)
	{
		tempDestination = [file directory];
		tempDestination = [tempDestination stringByAppendingPathComponent:@"~"];
		tempDestination = [tempDestination stringByAppendingString:newName];
		
		tagsOnFiles = [[PATagger sharedInstance] tagsOnFiles:[NSArray arrayWithObject:file]];
		
		if([fm fileExistsAtPath:tempDestination])
			[fm removeFileAtPath:tempDestination handler:nil];
			
		fileWasMovedToTemp = [fm movePath:source toPath:tempDestination handler:nil];
	}
	
	BOOL fileWasMoved;
	if(tempDestination && fileWasMovedToTemp)
	{	
		[fm removeFileAtPath:destination handler:nil];
		fileWasMoved = [fm movePath:tempDestination toPath:destination handler:self];
		
		if(fileWasMoved)
		{
			[fm removeFileAtPath:tempDestination handler:nil];
		}
	} else {
		fileWasMoved = [fm movePath:source toPath:destination handler:self];
	}
	
	if(fileWasMoved)
	{
		// Write tags on file
		PAFile *newFile = [PAFile fileWithPath:destination];
		[[PATagger sharedInstance] addTags:tagsOnFiles toFiles:[NSArray arrayWithObject:newFile]];
	
		[item setValue:newName forAttribute:(id)kMDItemDisplayName];
		[item setValue:destination forAttribute:(id)kMDItemPath];
	
		for(int i = 0; i < [flatResults count]; i++)
		{
			if([[flatResults objectAtIndex:i] isEqualTo:item])
			{
				[flatResults replaceObjectAtIndex:i withObject:item];
				break;
			}
		}
	
		// Re-bundle results
		if(filterDict)
		{
			[self filterResults:YES usingValues:[[[filterDict objectForKey:@"values"] retain] autorelease]
		               forBundlingAttribute:[[[filterDict objectForKey:@"bundlingAttribute"] retain] autorelease]
					  newBundlingAttributes:[[[filterDict objectForKey:@"newBundlingAttributes"] retain] autorelease]];
		}
	
		return YES;
	}
	else
	{
		return NO;
	}
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

- (void)alertDidEnd:(NSAlert *)alert returnCode:(int)returnCode contextInfo:(void *)contextInfo
{
	// nothing yet
}

- (void)updateQueryFromTags
{
	NSMutableString *queryString = [self queryStringForTags:[tags selectedTags]];
	
	if ([queryString isEqualToString:@""])
	{
		[self createQuery];
	}
	else
	{
		[self setPredicate:[NSPredicate predicateWithFormat:queryString]];
		
		if (![self isStarted])
		{
			[self startQuery];
		}
	}
}

- (NSString*)queryStringForTags:(NSArray*)someTags
{
	NSMutableString *queryString = [NSMutableString stringWithString:@""];
	
	NSEnumerator *e = [someTags objectEnumerator];
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

- (NSString*)queryInSpotlightSyntaxForTags:(NSArray*)someTags
{
	NSMutableString *queryString = [NSMutableString stringWithString:@""];
	
	NSEnumerator *e = [someTags objectEnumerator];
	PATag *tag;
	
	if (tag = [e nextObject]) 
	{
		NSString *anotherTagQuery = [NSString stringWithFormat:@"(%@)",[tag queryInSpotlightSyntax]];
		[queryString appendString:anotherTagQuery];
	}
	
	while (tag = [e nextObject]) 
	{
		NSString *anotherTagQuery = [NSString stringWithFormat:@" && (%@)",[tag queryInSpotlightSyntax]];
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
	
	if([[note name] isEqualTo:NSMetadataQueryDidStartGatheringNotification])
	{
		[flatFilteredResults release];
		flatFilteredResults = nil;
		[filteredResults release];
		filteredResults = nil;
		[nc postNotificationName:PAQueryDidStartGatheringNotification object:self];
	}
	
	/*if([[note name] isEqualTo:NSMetadataQueryGatheringProgressNotification])
	{
		[self synchronizeResults];
		[nc postNotificationName:PAQueryGatheringProgressNotification object:self];
	}*/
		
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
	[aPredicate retain];
	[predicate release];
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

- (BOOL)isStarted
{
	return [mdquery isStarted];
}

- (BOOL)isGathering
{
	return [mdquery isGathering];
}

- (BOOL)isStopped
{
	return [mdquery isStopped];
}

- (unsigned)resultCount
{
	return filterDict ? [filteredResults count] : [results count];
}

- (id)resultAtIndex:(unsigned)idx
{
	return filterDict ? [filteredResults objectAtIndex:idx] : [results objectAtIndex:idx];
}

- (NSArray *)results
{
	return filterDict ? filteredResults : results;
}

- (NSArray *)flatResults
{
	return filterDict ? flatFilteredResults : flatResults;
}

- (BOOL)hasFilter
{
	return filterDict ? YES : NO;
}


@end
