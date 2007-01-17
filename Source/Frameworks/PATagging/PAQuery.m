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

- (void)createQuery;
- (void)setMdquery:(NSMetadataQuery*)query;

- (NSDictionary *)synchronizeResults;
- (NSArray *)wrapMetadataQueryItems:(NSArray *)mdQueryItems;
- (NSDictionary *)compareNewResults:(NSArray *)newResults toOld:(NSArray *)oldResults;

- (void)setDelegate:(id)aDelegate;

- (NSPredicate *)predicate;
- (void)setPredicate:(NSPredicate *)aPredicate;

- (NSMutableArray *)plainResults;
- (void)setPlainResults:(NSMutableArray *)newResults;
- (NSMutableArray *)flatPlainResults;
- (void)setFlatPlainResults:(NSMutableArray *)newFlatResults;
- (NSArray *)filteredResults;
- (void)setFilteredResults:(NSMutableArray *)newResults;
- (NSArray *)flatFilteredResults;
- (void)setFlatFilteredResults:(NSMutableArray *)newResults;

- (NSMutableDictionary *)bundles;
- (void)setBundles:(NSMutableDictionary *)theBundles;

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
	if(bundles) [bundles release];
	[super dealloc];
}

#pragma mark Actions
- (void)createQuery
{
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	[nc removeObserver:self];
	
	[self setMdquery:[[[NSMetadataQuery alloc] init] autorelease]];
	[mdquery setDelegate:self];
	[mdquery setNotificationBatchingInterval:0.3];
	[mdquery setSortDescriptors:[NSArray arrayWithObject:[[[NSSortDescriptor alloc] initWithKey:(id)kMDItemFSName ascending:YES] autorelease]]];
	
	[nc addObserver:self
		   selector:@selector(metadataQueryNote:)
			   name:nil
			 object:mdquery];
	
	[self setPlainResults:[NSMutableArray array]];
	[self setFlatPlainResults:[NSMutableArray array]];
	[self setFilteredResults:[NSMutableArray array]];
	[self setFlatFilteredResults:[NSMutableArray array]];
	
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
	// Cleanup results
	[self setPlainResults:[NSMutableArray array]];
	[self setFlatPlainResults:[NSMutableArray array]];
	[self setFilteredResults:[NSMutableArray array]];
	[self setFlatFilteredResults:[NSMutableArray array]];
	
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
    @returns Dictionary with added/removed/updated items
*/
- (NSDictionary *)synchronizeResults
{
	[self disableUpdates];

	// We don't use [mdquery results] as this proxy array causes missing results during live update
	NSMutableArray *mdQueryResults = [NSMutableArray array];
	for(unsigned i = 0; i < [mdquery resultCount]; i++)
	{
		NSMetadataItem *mdItem = [mdquery resultAtIndex:i];
		
		if([[NSFileManager defaultManager] fileExistsAtPath:[mdItem valueForAttribute:(id)kMDItemPath]]) {
			[mdQueryResults addObject:mdItem];
		}
	}
	
	NSArray *queryResults = [self wrapMetadataQueryItems:mdQueryResults];
	
	NSDictionary *userInfo = [self compareNewResults:queryResults toOld:[self flatResults]];
	NSArray *addedItems = [userInfo objectForKey:(id)kMDQueryUpdateAddedItems];
	NSArray *removedItems = [userInfo objectForKey:(id)kMDQueryUpdateRemovedItems];
		
	// 1. Update flatResults
	[[self flatPlainResults] addObjectsFromArray:addedItems];
	[[self flatPlainResults] removeObjectsInArray:removedItems];
	
	// 2. Update results	
	if([self bundlingAttributes])
	{
		// --- Add items
		NSEnumerator *enumerator = [addedItems objectEnumerator];
		PAFile *item;
		while(item = [enumerator nextObject])
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
				bundleValue = [PATaggableObject replaceMetadataValue:bundlingAttributeValue
															  forAttribute:bundlingAttribute];
			}
			
			PAQueryBundle *bundle = [bundles objectForKey:bundleValue];
			if(!bundle)
			{
				bundle = [PAQueryBundle bundle];
				[bundle setValue:bundleValue];
				[bundle setBundlingAttribute:bundlingAttribute];
				[bundles setObject:bundle forKey:bundleValue];
				
				[[self plainResults] addObject:bundle];
			}
			[bundle addObject:item];
		}
		
		// --- Remove items
		enumerator = [removedItems objectEnumerator];
		while(item = [enumerator nextObject])
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
				bundleValue = [PATaggableObject replaceMetadataValue:bundlingAttributeValue
														forAttribute:bundlingAttribute];
			}
			
			PAQueryBundle *bundle = [bundles objectForKey:bundleValue];
			[bundle removeObject:item];
			
			if([bundle resultCount] == 0)
				[[self plainResults] removeObject:bundle];
		}
	}
	else {
		[[self plainResults] addObjectsFromArray:addedItems];
		[[self plainResults] removeObjectsInArray:removedItems];
	}
	
	// 3. Update filteredResults and flatFilteredResults
	[self filterResults];
	
	[self enableUpdates];
	
	return userInfo;
}

- (NSArray *)wrapMetadataQueryItems:(NSArray *)mdQueryItems
{
	BOOL wrapping = NO;
	if([mdQueryItems count] > 0)
		wrapping = [[mdQueryItems objectAtIndex:0] isKindOfClass:[NSMetadataItem class]];
	
	if(!wrapping)
	{
		return mdQueryItems;
	} 
	else
	{
		NSMutableArray *wrappedItems = [NSMutableArray array];
		
		NSEnumerator *enumerator = [mdQueryItems objectEnumerator];
		NSMetadataItem *mdItem;
		while(mdItem = [enumerator nextObject])
		{
			[wrappedItems addObject:[PAFile fileWithNSMetadataItem:mdItem]];
		}
		
		return wrappedItems;
	}
}

- (NSDictionary *)compareNewResults:(NSArray *)newResults toOld:(NSArray *)oldResults
{
	NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithCapacity:3];
	
	NSMutableArray *addedItems = [NSMutableArray array];
	NSMutableArray *removedItems = [NSMutableArray array];
				
	// First, match new to old
	NSEnumerator *enumerator = [newResults objectEnumerator];
	PAFile *newResultItem;
	while(newResultItem = [enumerator nextObject])
	{
		if(![oldResults containsObject:newResultItem])
			[addedItems addObject:newResultItem];
	}
	
	// Next, match vice-versa
	enumerator = [oldResults objectEnumerator];
	PAFile *oldResultItem;
	while(oldResultItem = [enumerator nextObject])
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
		
		// flatFilteredResults
		NSMutableArray *newFilteredResults = [NSMutableArray array];
		
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
				bundleValue = [PATaggableObject replaceMetadataValue:bundlingAttributeValue
														forAttribute:bundlingAttribute];
			}
			
			if([[item valueForAttribute:bundlingAttribute] isEqualTo:bundleValue])
				[newFilteredResults addObject:item];
		}
		
		[self setFlatFilteredResults:newFilteredResults];
		
		// filteredResults		
		newFilteredResults = [NSMutableArray array];
		
		enumerator = [[self plainResults] objectEnumerator];
		while(item = [enumerator nextObject])
		{
			if([self bundlingAttributes])
			{
				// This item is a PAQueryBundle
				PAQueryBundle *bundle = (PAQueryBundle *)item;
				if([filterValues containsObject:[bundle value]])
					[newFilteredResults addObjectsFromArray:[bundle results]];
			}
			else 
			{
				// This item is a PAFile - this case should not happen on level 1
				[newFilteredResults addObject:item];
			}
		}
		
		[self setFilteredResults:newFilteredResults];
	}	
}

- (BOOL)hasResultsUsingFilterWithValues:(NSArray *)filterValues
                   forBundlingAttribute:(NSArray *)attribute
{
	NSEnumerator *enumerator = [[self flatPlainResults] objectEnumerator];
	PAFile *item;
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
	/*[self disableUpdates];
	
	NSString *trashDir = [NSHomeDirectory() stringByAppendingPathComponent:@".Trash"];
	
	NSEnumerator *e = [items objectEnumerator];
	PAFile *item;

	while (item = [e nextObject])
	{
		PAFile *file = [PAFile fileWithPath:[item valueForAttribute:(id)kMDItemPath]];
		
		// Move to trash
		[[NSFileManager defaultManager] trashFileAtPath:[file path]];
		
		// Remove tags from trashed file to give spotlight enough time
		// TODO leave this to PAFile!!
		PAFile *trashedFile = [PAFile fileWithPath:[trashDir stringByAppendingPathComponent:[file filename]]];
		[trashedFile removeAllTags];

		// Remove from flatresults
		for(int k = 0; k < [[self flatPlainResults] count]; k++)
		{
			if([[[self flatPlainResults] objectAtIndex:k] isEqualTo:item])
			{
				[[self flatPlainResults] removeObjectAtIndex:k];
				break;
			}
		}
	}
	
	[self setResults:[self bundleResults:flatResults byAttributes:bundlingAttributes]];	
	
	// Apply filter, if active
	if(filterDict)
	{
		[self filterResults:YES usingValues:[filterDict objectForKey:@"values"]
		               forBundlingAttribute:[filterDict objectForKey:@"bundlingAttribute"]
					  newBundlingAttributes:[filterDict objectForKey:@"newBundlingAttributes"]];
	}
	
	[self enableUpdates];
	*/
}

/*- (BOOL)renameItem:(PAQueryItem *)item to:(NSString *)newName errorWindow:(NSWindow *)window
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
		
		tagsOnFiles = [[file tags] allObjects];
		
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
		// TODO this should be handled internally by PAFile
		PAFile *newFile = [PAFile fileWithPath:destination];
		[newFile addTags:tagsOnFiles];
	
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
}*/

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
	NSString *queryString = [self queryStringForTags:[tags selectedTags]];
	
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
		[self setFlatFilteredResults:nil];
		[self setFilteredResults:nil];
		[self setBundles:[NSMutableDictionary dictionary]];
		
		[nc postNotificationName:PAQueryDidStartGatheringNotification object:self];
	}
	
	/*if([[note name] isEqualTo:NSMetadataQueryGatheringProgressNotification])
	{
		[self synchronizeResults];
		[nc postNotificationName:PAQueryGatheringProgressNotification object:self];
	}*/
		
	if([[note name] isEqualTo:NSMetadataQueryDidUpdateNotification])
	{
		NSDictionary *userInfo = [self synchronizeResults];
		[nc postNotificationName:PAQueryDidUpdateNotification object:self userInfo:userInfo];
	}
		
	if([[note name] isEqualTo:NSMetadataQueryDidFinishGatheringNotification])
	{
		NSDictionary *userInfo = [self synchronizeResults];
		[nc postNotificationName:PAQueryDidFinishGatheringNotification object:self userInfo:userInfo];
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

- (NSDictionary *)simpleGrouping
{
	return simpleGrouping;
}

- (void)setSimpleGrouping:(NSDictionary *)aDictionary
{
	[simpleGrouping release];
	simpleGrouping = [aDictionary retain];
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
	return filterDict ? [filteredResults count] : [plainResults count];
}

- (id)resultAtIndex:(unsigned)idx
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


@end
