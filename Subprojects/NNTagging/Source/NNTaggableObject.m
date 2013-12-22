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

#import "NNTaggableObject.h"

NSString * const NNTaggableObjectUpdate = @"NNTaggableObjectUpdate";

NSUInteger const MANAGED_FOLDER_MAX_SUBDIR_SIZE = 300;

@interface NNTaggableObject (PrivateAPI)

/**
must be used in order to check if files are managed
 i.e. they must be put in the managed files area
 if this method returns YES
 */
- (BOOL)shouldManageFiles;

@end


@implementation NNTaggableObject

static NSDictionary *simpleGrouping;

#pragma mark init
+ (void)initialize
{
	// Simple Grouping TODO leaks
	NSString *path = [[NSBundle bundleWithIdentifier:@"eu.nudgenudge.nntagging"] pathForResource:@"MDSimpleGrouping" ofType:@"plist"];	
	simpleGrouping = [[NSDictionary alloc] initWithContentsOfFile:path];
}

// designated init - ONLY USED BY SUBCLASSES!
- (id)init
{
	if (self = [super init])
	{
		globalTags = [NNTags sharedTags];
		
		retryCount = 0;
		
		nc = [NSNotificationCenter defaultCenter];
		
		manageFilesAutomatically = YES;
	}
	return self;
}

- (void)dealloc
{
	[displayName release];
	[contentType release];
	[contentTypeIdentifier release];
	[contentTypeTree release];
	[lastUsedDate release];
	
	[tags release];
	[super dealloc];
}


#pragma mark Comparison
// TODO:Add hash and isEqual

- (NSComparisonResult)displayNameCompare:(id)otherTaggableObject
{
	return [[self displayName] compare:[otherTaggableObject displayName] options:(NSNumericSearch | NSCaseInsensitiveSearch)];
}


#pragma mark accessors
- (NSMutableSet*)tags
{
	return tags;
}

- (void)setTags:(NSMutableSet*)someTags
{
	[someTags retain];
	[tags release];
	tags = someTags;
}

- (NSInteger)retryCount
{
	return retryCount;
}

- (void)incrementRetryCount
{
	retryCount++;
}

- (void)setRetryCount:(NSInteger)i
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
	
	// set the content type - the one displayed
	[self setContentType:[NNTaggableObject replaceMetadataValue:[self contentTypeTree]
												   forAttribute:(NSString*)kMDItemContentTypeTree]];
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
- (void)addTag:(NNTag*)tag
{
	// increment use count if necessary
	if (![tags containsObject:tag])
		[tag incrementUseCount];
		
	// add tag to object
	[tags addObject:tag];
	
	// handle file management
	if ([self shouldManageFiles])
		[self handleFileManagement];
	
	[nc postNotificationName:NNTaggableObjectUpdate object:self userInfo:nil];
}

- (void)addTags:(NSArray*)someTags
{
	BOOL added = NO;
	
	for (NNTag* newTag in someTags)
	{
		if (![tags containsObject:newTag])
		{
			[tags addObject:newTag];
						
			// increment use count if necessary
			[newTag incrementUseCount];
			
			added = YES;
		}
	}
	
	// handle file management
	if ([self shouldManageFiles])
		[self handleFileManagement];

	if (added)
		[nc postNotificationName:NNTaggableObjectUpdate object:self userInfo:nil];
}

- (void)removeTag:(NNTag*)tag
{
	// decrement use count if necessary
	if ([tags containsObject:tag])
		[tag decrementUseCount];
	
	// TODO: Permanently remove tag if it is not used any more
	// However, [tag useCount] gives an incorrect result (e.g. 2 instead of 0),
	// and [tag taggedObjects] starts an expensive synchronous query...
	
	// remove tag from object	
	[tags removeObject:tag];
	
	// handle file management
	if ([self shouldManageFiles])
		[self handleFileManagement];
	
	[nc postNotificationName:NNTaggableObjectUpdate object:self userInfo:nil];
}

- (void)removeTags:(NSArray*)someTags
{
	BOOL removed = NO;
	
	for (NNTag* newTag in someTags)
	{
		if ([tags containsObject:newTag])
		{
			[tags removeObject:newTag];
			
			// decrement use count if necessary
			[newTag decrementUseCount];
			
			// TODO: Permanently remove tag, see removeTag:
			
			removed = YES;
		}
	}
		
	// handle file management
	if ([self shouldManageFiles])
		[self handleFileManagement];

	if (removed)
		[nc postNotificationName:NNTaggableObjectUpdate object:self userInfo:nil];
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
	
	[nc postNotificationName:NNTaggableObjectUpdate object:self userInfo:nil];
}

- (void)initiateSave
{
	[nc postNotificationName:NNTaggableObjectUpdate object:self userInfo:nil];
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

- (void)renameTo:(NSString*)newName errorWindow:(NSWindow*)window;
{
	// does nothing, must be implemented by subclass
}

- (BOOL)validateNewName:(NSString*)newName
{
	return NO;
}

- (void)moveToTrash:(BOOL)flag errorWindow:(NSWindow *)window
{
	// does nothing, must be implemented by subclass
}

- (BOOL)isWritable
{
	return NO;
}

#pragma mark helper
- (BOOL)shouldManageFiles
{
	// only manage if there are some tags on the file	
	if(!manageFilesAutomatically)
	{
		return manageFiles && ([tags count] > 0);
	} else {	
		return [[NNTagStoreManager defaultManager] managedFolderEnabled] && ([tags count] > 0);
	}
}

- (void)setShouldManageFiles:(BOOL)flag
{
	manageFilesAutomatically = NO;
	manageFiles = flag;
}

- (BOOL)shouldManageFilesAutomatically
{
	return manageFilesAutomatically;
}

- (void)setShouldManageFilesAutomatically:(BOOL)flag
{
	manageFilesAutomatically = YES;
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
	else if([attrName isEqualToString:(NSString*)kMDItemContentTypeTree])
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
		NSArray *artists = (NSArray*)attrValue;
		NSEnumerator *artistEnumerator = [artists objectEnumerator];
		NSMutableString *replacementValue = [NSMutableString string];
		NSString *artist;
		while(artist = [artistEnumerator nextObject])
		{
			[replacementValue appendString:artist];
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
