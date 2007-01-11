//
//  PATaggableObject.m
//  punakea
//
//  Created by Johannes Hoffart on 19.12.06.
//  Copyright 2006 nudge:nudge. All rights reserved.
//

#import "PATaggableObject.h"

NSString * const PATaggableObjectUpdate = @"PATaggableObjectUpdate";

@interface PATaggableObject (PrivateAPI)

/**
must be used in order to check if files are managed
 i.e. they must be put in the managed files area
 if this method returns YES
 */
- (BOOL)shouldManageFiles;

@end


@implementation PATaggableObject

static NSDictionary *simpleGrouping;

#pragma marg init
+ (void)initialize
{
	// Simple Grouping
	NSString *path = [[NSBundle mainBundle] pathForResource:@"MDSimpleGrouping" ofType:@"plist"];
	simpleGrouping = [[NSDictionary alloc] initWithContentsOfFile:path];
}


// designated init - ONLY USED BY SUBCLASSES!
- (id)init
{
	if (self = [super init])
	{
		globalTags = [PATags sharedTags];
		
		retryCount = 0;
		
		nc = [NSNotificationCenter defaultCenter];
	
	}
	return self;
}

- (void)dealloc
{
	[self saveTags];
	[tags release];
	[super dealloc];
}

#pragma mark accessors
- (NSSet*)tags
{
	return tags;
}

- (int)retryCount
{
	return retryCount;
}

- (void)incrementRetryCount
{
	retryCount++;
}

- (void)setRetryCount:(int)i
{
	retryCount = i;
}

- (NSString *)displayName
{
	return displayName;
}

- (void)setDisplayName:(NSString *)aDisplayName
{
	[displayName release];
	displayName = [aDisplayName retain];
}

- (NSString *)contentType
{
	return contentType;
}

- (void)setContentType:(NSString *)aContentType
{
	[contentType release];
	contentType = [aContentType retain];
}

- (NSString *)contentTypeIdentifier
{
	return contentTypeIdentifier;
}

- (void)setContentTypeIdentifier:(NSString *)aContentTypeIdentifier
{
	[contentTypeIdentifier release];
	contentTypeIdentifier = [aContentTypeIdentifier retain];
}

- (NSArray *)contentTypeTree
{
	return contentTypeTree;
}

- (void)setContentTypeTree:(NSArray *)aContentTypeTree
{
	[contentTypeTree release];
	contentTypeTree = [aContentTypeTree retain];
}

- (NSDate *)lastUsedDate
{
	return lastUsedDate;
}

- (void)setLastUsedDate:(NSDate *)aDate
{
	[lastUsedDate release];
	lastUsedDate = [aDate retain];
}


#pragma mark functionality
- (void)addTag:(PATag*)tag
{
	// increment use count if necessary
	if (![tags containsObject:tag])
		[tag incrementUseCount];
		
	// add tag to object
	[tags addObject:tag];
	
	// handle file management
	if ([self shouldManageFiles])
		[self handleFileManagement];
	
	[nc postNotificationName:PATaggableObjectUpdate object:self userInfo:nil];
}

- (void)addTags:(NSArray*)someTags
{
	NSEnumerator *tagEnumerator = [someTags objectEnumerator];
	PATag *newTag;
	
	while (newTag = [tagEnumerator nextObject])
	{
		if (![tags containsObject:newTag])
		{
			[tags addObject:newTag];
			
			// increment use count if necessary
			[newTag incrementUseCount];
		}
	}
	
	// handle file management
	if ([self shouldManageFiles])
		[self handleFileManagement];
	
	[nc postNotificationName:PATaggableObjectUpdate object:self userInfo:nil];
}

- (void)removeTag:(PATag*)tag
{
	// decrement use count if necessary
	if ([tags containsObject:tag])
		[tag decrementUseCount];
	
	// remove tag from object	
	[tags removeObject:tag];
	
	// handle file management
	if ([self shouldManageFiles])
		[self handleFileManagement];
	
	[nc postNotificationName:PATaggableObjectUpdate object:self userInfo:nil];
}

- (void)removeTags:(NSArray*)someTags
{
	NSEnumerator *tagEnumerator = [someTags objectEnumerator];
	PATag *newTag;
	
	while (newTag = [tagEnumerator nextObject])
	{
		if ([tags containsObject:newTag])
		{
			[tags removeObject:newTag];
			
			// decrement use count if necessary
			[newTag decrementUseCount];
		}
	}
		
	// handle file management
	if ([self shouldManageFiles])
		[self handleFileManagement];
	
	[nc postNotificationName:PATaggableObjectUpdate object:self userInfo:nil];
}

- (void)removeAllTags
{
	// decrement use count if necessary
	[tags makeObjectsPerformSelector:@selector(decrementUseCount)];
	
	// remove all tags
	[tags removeAllObjects];
	
	// handle file management
	if ([self shouldManageFiles])
		[self handleFileManagement];
	
	[nc postNotificationName:PATaggableObjectUpdate object:self userInfo:nil];
}

- (void)initiateSave
{
	[nc postNotificationName:PATaggableObjectUpdate object:self userInfo:nil];
}

#pragma mark abstract methods
- (BOOL)saveTags
{
	// does nothing, must be implemented by subclass
	return NO;
}

- (void)handleFileManagement
{
	// does nothing, must be implemented by subclass
}

- (BOOL)renameTo:(NSString*)newName errorWindow:(NSWindow*)window;
{
	return NO;
}

- (BOOL)validateNewName:(NSString*)newName
{
	return NO;
}

#pragma mark helper
- (BOOL)shouldManageFiles
{
	// only manage if there are some tags on the file
	return [[NSUserDefaults standardUserDefaults] boolForKey:@"General.ManageFiles"] && ([tags count] > 0);
}


#pragma mark Class Methods
+ (id)replaceMetadataValue:(id)attrValue forAttribute:(NSString *)attrName {
	if ((attrValue == nil) || (attrValue == [NSNull null])) {
        // We don't want to display <null> for the user, so, depending on the category, display something better
        if ([attrName isEqualToString:(id)kMDItemKind]) {
            return NSLocalizedString(@"Other", @"Kind to display for unknown file types");
        } else {
            //return NSLocalizedString(@"Unknown", @"Kind to display for other unknown values"); 
			return nil;
        }
    } 
	// kMDItemContentType
	else if([attrName isEqualToString:@"kMDItemContentTypeTree"])
	{	
		/*path = @"~/Library/Preferences/com.apple.spotlight.plist";
		path = [path stringByExpandingTildeInPath];
		NSDictionary *spotlightUserDefaults = [[NSDictionary alloc] initWithContentsOfFile:path];
		NSArray *spotlightOrderedItems = [spotlightUserDefaults objectForKey:@"orderedItems"];*/
		
		NSArray *typeTreeArray = (NSArray *)attrValue;
		NSEnumerator *enumerator = [typeTreeArray objectEnumerator];
		NSString *aType, *replacementValue;
		
		while(aType = [enumerator nextObject])
		{
			replacementValue = [simpleGrouping objectForKey:aType];
			if(replacementValue) break;
		}
		
		//NSString *replacementValue = [simpleGrouping objectForKey:attrValue];
		if(!replacementValue) replacementValue = @"DOCUMENTS";
		
		// Add and sort index like "00 APPLICATIONS"
		/*int j;
		for(j = 0; j < [spotlightOrderedItems count]; j++)
		{
			NSDictionary *spotlightOrderedItem = [spotlightOrderedItems objectAtIndex:j];
			NSString *spotlightOrderedItemName = [spotlightOrderedItem objectForKey:@"name"];
			if([spotlightOrderedItemName isEqualToString:replacementValue])
			{
				NSNumberFormatter *numberFormatter = [[[NSNumberFormatter alloc] init] autorelease];
				[numberFormatter setFormat:@"00"];
				
				NSString *indexString = [numberFormatter stringFromNumber:[NSNumber numberWithInt:j]];
				indexString = [indexString stringByAppendingString:@" "];
				replacementValue = [indexString stringByAppendingString:replacementValue];
				break;
			}
		}*/
		
		return replacementValue;
    }
	// kMDItemArtists (Wrap NSArray into NSString)
	else if ([attrName isEqualToString:(id)kMDItemAuthors])
	{
		NSArray *artists = attrValue;
		NSEnumerator *artistEnumerator = [artists objectEnumerator];
		NSMutableString *replacementValue = [NSMutableString string];
		NSString *artist;
		while(artist = [artistEnumerator nextObject])
		{
			replacementValue = [replacementValue stringByAppendingString:artist];
		}
		return replacementValue;
	}
	// Default
	else
	{
		return attrValue;
	}
    
}

#pragma mark copying
- (id)copyWithZone:(NSZone *)zone
{
	return nil;
}

@end
