//
//  OpenMetaPrefs.m
//  adobeFix
//
//  Created by Tom Andersen on 24/04/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "OpenMetaPrefs.h"

NSString* gPrefsFileName = @"com.openmeta.shared";

@interface OpenMetaPrefs (Private)
+(void)synchPrefsIfItsBeenAWhile;
@end


@implementation OpenMetaPrefs
#pragma mark global prefs for recent tags 

// Call without extension - ie don't add plist
+(void)setPrefsFile:(NSString*)prefsFileToUse;
{
	gPrefsFileName = [prefsFileToUse copy];
}

//----------------------------------------------------------------------
//	recentTags
//
//	Purpose:	returns a list of the recently entered tags. The creation of the recently entered tags is not automatic. You need to call updatePrefsNewTags to do this.
//				only call updatePrefsNewTags if the USER has changed tags - usually automated scripts, etc will not want to update the recent tags
//
//	Inputs:		
//
//	Outputs:	
//
//  Created by Tom Andersen on 2009/01/09 
//
//----------------------------------------------------------------------
+(NSArray*)recentTags;
{
	[self synchPrefsIfItsBeenAWhile]; // can't really  call sync for each call into here, as some apps will call really really often. And the sync call goes out to the file system
	NSArray* outArray = [NSArray array];
	CFPropertyListRef prefArray = CFPreferencesCopyAppValue(CFSTR("recentlyEnteredTags"), (CFStringRef)gPrefsFileName);
	if (prefArray)
	{
		outArray = [NSArray arrayWithArray:(NSArray*)prefArray];
		CFRelease(prefArray);
	}
	return outArray;
}

//----------------------------------------------------------------------
//	updatePrefsRecentTags (was updatePrefsNewTags)
//
//	Purpose:	call this to update the list of recent tags. You pass in two arrays, one is the original set of tags, the other is the set of all tags, 
//				this will write to the shared OpenMeta prefs for recently entered tags.
//				oldTags - the tags you put into the editing box for the user to edit for one or more docs
//				newTags - the tags the user ended up with on the document. 
//				The old tags are needed so that we can figure out which tags (or case changes, etc) the user added. 
//
//	Inputs:		
//
//	Outputs:	
//
//  Created by Tom Andersen on 2009/02/10 
//
//----------------------------------------------------------------------
+(void)updatePrefsRecentTags:(NSArray*)oldTags newTags:(NSArray*)newTags;
{
	// we need to update the prefs with the recently entered tags. We limit the list to being 200 tags, and the most recently entered tags are at the top of the list.
	
	// we are passed a set of tags that the user started with, and the ones he ended with. We need the new ones only.
	NSMutableArray* tagsToAdd = [NSMutableArray arrayWithCapacity:[newTags count]];
	for (NSString* newTag in newTags)
	{
		if (![oldTags containsObject:newTag]) // since we are case sensitive here, a case change will count as a 'newly entered tag' which is what I want.
			[tagsToAdd addObject:newTag];
	}

	if ([tagsToAdd count] == 0)
		return;
	
	// by using CFPreferences, we can use a global shared pool of recently entered tags.
	[self synchPrefs];
	NSMutableArray* currentRecents = [NSMutableArray array];
	CFPropertyListRef prefArray = CFPreferencesCopyAppValue(CFSTR("recentlyEnteredTags"), (CFStringRef)gPrefsFileName);
	if (prefArray)
	{
		[currentRecents addObjectsFromArray:(NSArray*)prefArray];
		CFRelease(prefArray);
	}
	
	// Case insensitivity is important - we also need to preserve case, but the recentTags list in the prefs only should have 
	// one version of each tag (eg only 'Tom' and not TOM, tom, ToM...)
	// The way to do this is to use a dictionary, then use the current recents to order the output:
	const int kMaxRecentsKept = 200;
	
	NSMutableDictionary* recentsDict = [NSMutableDictionary dictionary];
	for (NSString* aRecent in currentRecents)
		[recentsDict setObject:aRecent forKey:[aRecent lowercaseString]];
	for (NSString* tagToAdd in tagsToAdd)
		[recentsDict setObject:tagToAdd forKey:[tagToAdd lowercaseString]];
	
	// now use ordering from the two arrays to create the new array:
	NSMutableArray* newRecents = [NSMutableArray array];
	for (NSString* tagToAdd in tagsToAdd)
	{
		if ([recentsDict objectForKey:[tagToAdd lowercaseString]])
		{
			[newRecents addObject:tagToAdd];
			[recentsDict removeObjectForKey:[tagToAdd lowercaseString]]; // remove from dict to signal that it is already added
		}
		if ([newRecents count] > kMaxRecentsKept) // we can't let this recent pool of tags grow without limit.
			break;
	}
	
	// now add the current recents in order, but only if they have not been added before.
	for (NSString* aRecent in currentRecents)
	{
		if ([recentsDict objectForKey:[aRecent lowercaseString]])
		{
			[newRecents addObject:aRecent];
			[recentsDict removeObjectForKey:[aRecent lowercaseString]]; // remove from dict to signal that it is already added
		}
		if ([newRecents count] > kMaxRecentsKept) // we can't let this recent pool of tags grow without limit.
			break;
	}

	CFPreferencesSetAppValue(CFSTR("recentlyEnteredTags"), (CFPropertyListRef) newRecents, (CFStringRef)gPrefsFileName);
	[self synchPrefs];
}

//----------------------------------------------------------------------
//	synchPrefs
//
//	Purpose:	Call on quit, also usually call when you swap in.
//
//	Inputs:		
//
//	Outputs:	
//
//  Created by Tom Andersen on 2009/01/09 
//
//----------------------------------------------------------------------
+(void)synchPrefs;
{
	CFPreferencesAppSynchronize((CFStringRef)gPrefsFileName);
}

+(void)synchPrefsIfItsBeenAWhile;
{
	static CFAbsoluteTime lastSyncTime = 0;
	if (fabs(lastSyncTime - CFAbsoluteTimeGetCurrent()) < 10.0)
		return;
	
	// ok - its been ' a while' since we synched tags. so do it.
	[self synchPrefs];
	lastSyncTime = CFAbsoluteTimeGetCurrent();
}

@end
