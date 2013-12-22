//
//  OpenMeta.m
//  OpenMeta
//
//  Created by Tom Andersen on 17/07/08.
//  MIT license.
//
/*
Copyright (c) 2009 ironic software

Permission is hereby granted, free of charge, to any person
obtaining a copy of this software and associated documentation
files (the "Software"), to deal in the Software without
restriction, including without limitation the rights to use,
copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the
Software is furnished to do so, subject to the following
conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
OTHER DEALINGS IN THE SOFTWARE.
*/

#include <sys/xattr.h>
#include <sys/time.h>
#include <sys/stat.h>
#import "OpenMeta.h"
#import "OpenMetaBackup.h"

// OPEN_META_NO_UI 
// There is some UI in the OpenMeta code. If you don't want to or can't link to UI, then define OPEN_META_NO_UI in the compiler settings. 
// ie:  in the target info in XCode set : "Preprocessor Macros Not Used In Precompiled Headers" to  OPEN_META_NO_UI=1


const long kMaxDataSize = 4096; // Limit maximum data that can be stored, 

NSString* const kMDItemOMUserTags = @"kMDItemOMUserTags";
NSString* const kMDItemOMUserTagTime = @"kMDItemOMUserTagTime";
NSString* const kMDItemOMDocumentDate = @"kMDItemOMDocumentDate";
NSString* const kMDItemOMBookmarks = @"kMDItemOMBookmarks";
NSString* const kMDItemOMUserTagApplication = @"kMDItemOMUserTagApplication";

const double kMDItemOMMaxRating = 5.0;


NSString* const OM_ParamErrorString = @"Open Meta parameter error";
NSString* const OM_NoDataFromPropertyListErrorString = @"The data requested or attempted to be set could not be made into a apple property list";
NSString* const OM_NoMDItemFoundErrorString = @"The path appears not to point to a valid item on disk";
NSString* const OM_MetaTooBigErrorString = @"Meta data is too big - size as binary plist must be less than (perhaps 4k?) some number of bytes";


@interface OpenMeta (Private)
+(BOOL)validateAsArrayOfStrings:(NSArray*)array;
+(NSArray*)removeDuplicateTags:(NSArray*)tags;
+(NSString*)errnoString:(int)errnoErr;
@end

@implementation OpenMeta

//----------------------------------------------------------------------
//	setUserTags
//
//	Purpose:	Set the passed tags on the passed file url, so that the user can search in 
//				spotlight. 
//	Also:		case preserving case insensitive removal of duplicate tags - so feel free to pass in a few dups
//
//	Inputs:		If you pass in nil or an empty array, the entire key is removed from the data.
//				When you remove tags, the date stamp is still set. Useful perhaps in telling someone that all tags were removed intentionally.
//
//	Outputs:	
//
//  Created by Tom Andersen on 2008/07/17 
//
//----------------------------------------------------------------------
+(NSError*)setUserTags:(NSArray*)tags path:(NSString*)path;
{
	if (![self validateAsArrayOfStrings:tags])
		return [NSError errorWithDomain:@"openmeta" code:OM_ParamError userInfo:[NSDictionary dictionaryWithObject:OM_ParamErrorString forKey:@"info"]];
	
	tags = [self removeDuplicateTags:tags]; // also converts to utf8 decomposed format
	
	[self setXAttrMetaData:[NSDate date] metaDataKey:kMDItemOMUserTagTime path:path];

	// backward compatibility kOM
	// for backward compatibility with older openmeta, also set the user tags under kOMUserTags.
	// the problem with the old name is that they erased by many common file operations in 10.6. 
	// the new prefix, kMDItemOM* will get preserved 
	[self setXAttr:tags forKey:[self spotlightKey:@"kOMUserTags"] path:path];
	[self setXAttr:tags forKey:[self openmetaKey:@"kOMUserTags"] path:path];

	return [self setNSArrayMetaData:tags metaDataKey:kMDItemOMUserTags path:path]; 
}

//----------------------------------------------------------------------
//	clearUserTags
//
//	Purpose:	removes the passed tags. If the tags are already in, then no error (nil) is returned
//
//	Inputs:		
//
//	Outputs:	
//
//  Created by Tom Andersen on 2008/12/10 
//
//----------------------------------------------------------------------
+(NSError*)clearUserTags:(NSArray*)tags path:(NSString*)path;
{
	if (![self validateAsArrayOfStrings:tags])
		return [NSError errorWithDomain:@"openmeta" code:OM_ParamError userInfo:[NSDictionary dictionaryWithObject:OM_ParamErrorString forKey:@"info"]];

	// we need to be careful to be case insensitive case preserving here:
	NSError* error = nil;
	NSArray* originalTags = [self getNSArrayMetaData:kMDItemOMUserTags path:path error:&error];
	if (error)
		return error;
		
	NSMutableArray* newArray = [NSMutableArray arrayWithCapacity:[originalTags count]];
	
	for (NSString* aTag in originalTags)
	{
		NSString* lowercaseTag = [aTag lowercaseString];
		BOOL keepTheTag = YES;
		for (NSString* aTagToClear in tags)
		{
			NSString* lowercaseTagToClear = [aTagToClear lowercaseString];
			if ([lowercaseTagToClear isEqualToString:lowercaseTag])
				keepTheTag = NO;
		}
		
		if (keepTheTag)
			[newArray addObject:aTag];
	}
	 
	if ([newArray count] == [originalTags count])
		return nil; // not an error to clear a tag that was not there.
	
	return [self setUserTags:newArray path:path];
}




//----------------------------------------------------------------------
//	addUserTags
//
//	Purpose:	adds the tags to the current tags. If the tags are already in, then then no error (nil) is returned
//
//	Inputs:		
//
//	Outputs:	
//
//  Created by Tom Andersen on 2008/12/10 
//
//----------------------------------------------------------------------
+(NSError*)addUserTags:(NSArray*)tags path:(NSString*)path;
{
	if (![self validateAsArrayOfStrings:tags])
		return [NSError errorWithDomain:@"openmeta" code:OM_ParamError userInfo:[NSDictionary dictionaryWithObject:OM_ParamErrorString forKey:@"info"]];

	// we need to be careful to be case insensitive case preserving here:
	NSError* error = nil;
	NSArray* originalTags = [self getNSArrayMetaData:kMDItemOMUserTags path:path error:&error];
	if (error)
		return error;
	
	NSMutableArray* newArray = [NSMutableArray arrayWithArray:originalTags]; 
	[newArray addObjectsFromArray:tags];
	NSArray* cleanedTags = [self removeDuplicateTags:newArray];
	
	if (![originalTags isEqualToArray:cleanedTags])
	{
		return [self setUserTags:cleanedTags path:path];
	}
		
	return nil; // no error if we did not have to do anything
}


//----------------------------------------------------------------------
//	getUserTags
//
//	Purpose:	retrive user tags for the passed file
//
//	Inputs:		NSArray of strings - nothing else allowed
//
//	Outputs:	
//
//  Created by Tom Andersen on 2008/07/17 
//
//----------------------------------------------------------------------
+(NSArray*)getUserTags:(NSString*)path error:(NSError**)error;
{
	// if there are tags set by both old and new api, then this uses dates to figure out which to use. 
	[OpenMetaBackup copyTagsFromOldKeyTokMDItemOMIfNeeded:path];
	
	// I put restore meta here - as restoreMetadata calls us! 
	// I put the restore on the usertags and ratings. Users will have to manually call restore for other keys 
	[OpenMetaBackup restoreMetadata:path];
	return [self getNSArrayMetaData:kMDItemOMUserTags path:path error:error];
}

+(NSArray*)getUserTagsNoRestore:(NSString*)path error:(NSError**)error;
{
	return [self getNSArrayMetaData:kMDItemOMUserTags path:path error:error];
}


//----------------------------------------------------------------------
//	setRating
//
//	Purpose:	get/set ratings. If you pass in a 0 rating we remove the rating. So no items will have a rating 'set' to zero. 
//				ratings are 0 - 5 'stars'.
//
//
//	Inputs:	0. if rating is not found. 0 - 5 rating spread (float).
//
//  Created by Tom Andersen on 2008/07/17 
//
//----------------------------------------------------------------------
+(NSError*)setRating:(double)rating05 path:(NSString*)path;
{
	if (rating05 <= 0.0)
		return [self setXAttrMetaData:nil metaDataKey:(NSString*)kMDItemStarRating path:path];
	
	if (rating05 > kMDItemOMMaxRating)
		rating05 = kMDItemOMMaxRating;
		
	NSNumber* ratingNS = [NSNumber numberWithDouble:rating05];
	return [self setXAttrMetaData:ratingNS metaDataKey:(NSString*)kMDItemStarRating path:path];
}

+(double)getRating:(NSString*)path error:(NSError**)error;
{
	// ratings and tags are the only 'auto - restored' items 
	[OpenMetaBackup restoreMetadata:path];
	NSNumber* theNumber = [self getXAttrMetaData:(NSString*)kMDItemStarRating path:path error:error];
	return [theNumber doubleValue];
}

//----------------------------------------------------------------------
//	setString:keyName:path:
//
//	Purpose:	simple way to set a single string on a key.
//				use these when you only want to store a single string in the spotlightDB under a key
//
//	Inputs:		
//
//	Outputs:	
//
//  Created by Tom Andersen on 2008/09/21 
//
//----------------------------------------------------------------------
+(NSError*)setString:(NSString*)string keyName:(NSString*)keyName path:(NSString*)path;
{
	return [self setXAttrMetaData:string metaDataKey:keyName path:path];
}

+(NSString*)getString:(NSString*)keyName path:(NSString*)path error:(NSError**)error;
{
	return [self getXAttrMetaData:keyName path:path error:error];
}


#pragma mark getting/setting on multiple files 

//----------------------------------------------------------------------
//	getCommonUserTags
//
//	Purpose:	returns an array of tags (each of which could be multiple words, etc)
//				note that the use of 'prefix characters such as @ or & is useless and discouraged"
//
//	Inputs:		
//
//	Outputs:	
//
//  Created by Tom Andersen on 2008/10/01 
//
//----------------------------------------------------------------------
+(NSArray*)getCommonUserTags:(NSArray*)paths error:(NSError**)error;
{
	// order is to 'be preserved' - but for multiple documents - we use the first passed doc
	if ([paths count] == 1)
		return [self getUserTags:[paths lastObject] error:error];
	
	
	// make sure that any tags that are set with the old api get copied into the new fold:
	for (NSString* aPath in paths)
		[OpenMetaBackup copyTagsFromOldKeyTokMDItemOMIfNeeded:aPath];
	
	
	// restore metadata to all files:
	// by doing it now, at 'get' time, we are basically reading a static db of backup files.
	// if we are lazy and wait, then sometimes we will win, because the user will not set any files, 
	// but often we will lose bad, as when the user does set a tag, the backup dir will rapidly change, which results in much reloading 
	// of cached backup folder contents.
	for (NSString* aPath in paths)
		[OpenMetaBackup restoreMetadata:aPath];
	
	NSMutableDictionary* theCommonTags = [NSMutableDictionary dictionary];
	
	NSArray* firstSetOfTags = nil;
	for (NSString* aPath in paths)
	{
		// go through each document, extracting tags. 
		NSError* theError = nil;
		NSArray* tags = [self getUserTagsNoRestore:aPath error:&theError];
		if ([tags count] == 0 || theError != nil)
		{
			if (error)
				*error = theError;
			return [NSArray array];
		}
		
		// if we made it here it means that this document has some tags: if there are none in the 
		// commonTags yet it must mean that we have not added the original set:
		if ([theCommonTags count] == 0)
		{
			firstSetOfTags = tags;
			// add original set:
			for (NSString* aTag in tags)
				[theCommonTags setObject:aTag forKey:[aTag lowercaseString]];
		}
		else
		{
			// second or later document
			NSMutableDictionary* currentTags = [NSMutableDictionary dictionary];
			for (NSString* aTag in tags)
				[currentTags setObject:aTag forKey:[aTag lowercaseString]];
				
			// go through the theCommonTags,
			// removing any that are not in this document
			for (NSString* commonTag in [theCommonTags allKeys])
			{
				if ([currentTags objectForKey:commonTag] == nil)
					[theCommonTags removeObjectForKey:commonTag];
			}
		}
		
		if ([theCommonTags count] == 0)
			return [NSArray array];
	}
	
	// preserve order using the first array passed
	return [self orderedArrayWithDict:theCommonTags sortHint:firstSetOfTags];
}


//----------------------------------------------------------------------
//	setCommonUserTags
//
//	Purpose:	set common user tags: passed an array of paths and the original tags as from an earlier call 
//				to getCommonUserTags, this call will go through each document changing the tags as directed.
//				This method handles the case where another user or other program, multiple windows, etc, has modified 
//				the tags in between the time you called getCommonUserTags and the time you call setCommonUserTags
//
//	Inputs:		
//
//	Outputs:	
//
//  Created by Tom Andersen on 2008/10/01 
//
//----------------------------------------------------------------------
+(NSError*)setCommonUserTags:(NSArray*)paths originalCommonTags:(NSArray*)originalTags replaceWith:(NSArray*)replaceWith;
{
	if ([originalTags count] == 0 && [replaceWith count] == 0)
		return nil;
	
	// we try to preserve order, and we allow case changes, so original tags as @"foo" @"bar" is different from @"bar" @"Foo"
	// but all new tags are always added to the end. 
	NSError* error = nil;
	for (NSString* aPath in paths)
	{
		// get the tags currently on the document
		// Note that since we just finished getting the tags, we don't need to bother doing a restore for each document. 
		// it is especially slow to call restore here for a lot of docs, as for each doc the backup dir will change, which will mean an expensive reload.
		NSArray* tags = [self getUserTagsNoRestore:aPath error:&error];
		if (![replaceWith isEqualToArray:tags])
		{
			NSMutableDictionary* currentTags = [NSMutableDictionary dictionary];
			for (NSString* aTag in tags)
				[currentTags setObject:aTag forKey:[aTag lowercaseString]];
			
			// remove the tags that were originally common:
			for (NSString* aTag in originalTags)
				[currentTags removeObjectForKey:[aTag lowercaseString]];
			
			// start building the new array using the order from the old array, along with the new values
			NSMutableArray* newTags = [NSMutableArray array];
			for (NSString* aTag in tags)
			{
				if ([currentTags objectForKey:[aTag lowercaseString]])
					[newTags addObject:aTag];
			}
			
			// add the new tags in the order passed.
			for (NSString* aTag in replaceWith)
				[newTags addObject:aTag];
			
			// write out the tags:
			NSError* errorOnThisOne = [self setUserTags:newTags path:aPath];
			
			// if there was an error, don't abort the whoe thing, but rather just return an error code at the end:
			if (errorOnThisOne != nil)
				error = errorOnThisOne;
		}
	}
	return error;
}

#pragma mark set data that will be indexed by spotlight 
//----------------------------------------------------------------------
//	getNSArrayMetaData
//
//	Purpose:	
//
//	Inputs:		
//
//	Outputs:	
//
//  Created by Tom Andersen on 2008/12/10 
//
//----------------------------------------------------------------------
+(NSArray*)getNSArrayMetaData:(NSString*)metaDataKey path:(NSString*)path error:(NSError**)error;
{
	NSArray* returnedArray = (NSArray*) [self getXAttrMetaData:metaDataKey path:path error:error];
	if (![returnedArray isKindOfClass:[NSArray class]])
		return nil;
	return returnedArray;
}

+(NSError*)setNSArrayMetaData:(NSArray*)array metaDataKey:(NSString*)metaDataKey path:(NSString*)path;
{
	if (![array isKindOfClass:[NSArray class]])
		return [NSError errorWithDomain:@"openmeta" code:OM_ParamError userInfo:[NSDictionary dictionaryWithObject:OM_ParamErrorString forKey:@"info"]];
	
	return [self setXAttrMetaData:array metaDataKey:metaDataKey path:path];
}

//----------------------------------------------------------------------
//	addToNSArrayMetaData
//
//	Purpose:	
//
//	Inputs:		
//
//	Outputs:	
//
//  Created by Tom Andersen on 2008/12/10 
//
//----------------------------------------------------------------------
+(NSError*)addToNSArrayMetaData:(NSArray*)itemsToAdd metaDataKey:(NSString*)metaDataKey path:(NSString*)path;
{
	// get the current, then add the items in, checking for duplicates, then write out the result, if we need to.
	NSError* error = nil;
	NSMutableArray* newArray = [NSMutableArray arrayWithArray:[self getNSArrayMetaData:metaDataKey path:path error:&error]]; 
	
	BOOL needToSet = NO;
	for (id anItem in itemsToAdd)
	{
		if (![newArray containsObject:anItem])
		{
			needToSet = YES;
			[newArray addObject:anItem];
		}
	}
	
	if (needToSet)
		error = [self setXAttrMetaData:newArray metaDataKey:metaDataKey path:path];
	
	return error;
}


//----------------------------------------------------------------------
//	getXAttrMetaData
//
//	Purpose:	
//
//	Inputs:		
//
//	Outputs:	
//
//  Created by Tom Andersen on 2008/12/10 
//
//----------------------------------------------------------------------
+(id)getXAttrMetaData:(NSString*)metaDataKey path:(NSString*)path error:(NSError**)error;
{
	return [self getXAttr:[self spotlightKey:metaDataKey] path:path error:error];
	
	// Mirroring:
	// it might seem prudent to look for an attribute with a key of [self spotlightKey:metaDataKey]
	// and if that fails, to look to the mirror data. But if someone sets a tag using an OpenMeta app.
	// then removes it with another, possibly old openmeta app, or some other application that uses 
	// its own method to call setxattr() directly, the mirrored tags will be old and wrong.
	// what to do?
}
+(id)getXAttrMetaDataNoSpotlightMirror:(NSString*)omKey path:(NSString*)path error:(NSError**)error;
{
	return [self getXAttr:[self openmetaKey:omKey] path:path error:error];
}

//----------------------------------------------------------------------
//	setXAttrMetaData
//
//	Purpose:	
//
//	Inputs:		
//
//	Outputs:	
//
//  Created by Tom Andersen on 2008/12/10 
//
//----------------------------------------------------------------------
+(NSError*)setXAttrNoSpotlightMirror:(id)plistObject omKey:(NSString*)omKey path:(NSString*)path;
{
	// Mirroring: mirror all data to our own open meta domain name
	[self setXAttr:plistObject forKey:[self openmetaKey:omKey] path:path];
	
	// set a time stamp (not in spotlight DB) for this operation
	NSError* error = [self setXAttr:[NSDate date] forKey:[self openmetaTimeKey:omKey] path:path];
	return error;
}

+(NSError*)setXAttrMetaData:(id)plistObject metaDataKey:(NSString*)metaDataKey path:(NSString*)path;
{
	// Mirroring: mirror all data to our own open meta domain name
	[self setXAttrNoSpotlightMirror:plistObject omKey:metaDataKey path:path];
	
	NSError* error = [self setXAttr:plistObject forKey:[self spotlightKey:metaDataKey] path:path];
	
	return error;
}

#pragma mark registering openmeta attributes
+(void)removeSchemaFile:(NSString*)path;
{
	if ([path rangeOfString:@"Library/Application Support/Punakea/OpenMeta/schemaregister"].location != NSNotFound) // make sure some error does not see us erasing lots of stuff 
		[[NSFileManager defaultManager] removeItemAtPath:path error:nil];
}

//----------------------------------------------------------------------
//	registerUsualOMAttributes
//
//	Purpose:	Call on launch to be sure that the OpenMeta spotlgight importer that you included in your app bundle 
//				gets registered. If you are  doing a command line thing, or some tool where you know the person has the OpenMeta spotlight plugin installed,
//				then you don't need this. 
//
//				It makes sure that typing a search like 'tag:goofy' will work in the Apple default spotlight search, or in the Finder.
//
//	Inputs:		
//
//	Outputs:	
//
//  Created by Tom Andersen on 2009/05/19 
//
//----------------------------------------------------------------------
+(void)registerUsualOMAttributes;
{
	NSDictionary* stuffWeUse = [NSDictionary dictionaryWithObjectsAndKeys:
								[NSArray arrayWithObjects:@"openMeta1", @"openMeta2", nil], @"kMDItemOMUserTags",
								[NSDate date], @"kMDItemOMUserTagTime",
								[NSDate date], @"kMDItemOMDocumentDate",
								[NSNumber numberWithBool:YES], @"kMDItemOMManaged",
								[NSArray arrayWithObjects:@"bookmark1", @"bookmark2", nil], @"kMDItemOMBookmarks",
								nil];

	
	// App name: 
	NSString* appname = [[[NSBundle mainBundle] bundlePath] lastPathComponent];
	
	[OpenMeta registerOMAttributes:stuffWeUse forAppName:appname];
}

//----------------------------------------------------------------------
//	registerOMAttributes
//
//				Easiest to ususally call registerUsualOMAttributes
//
//	Purpose:	This should be called by any application that uses OpenMeta, to register the attributes that you are using with spotlight.
//				Spotlight may not 'know' about say kMDItemOMUserTags unless you set a file with some user tags so that the OpenMeta spotlight importer can
//				run on this one (fairly hidden file), which then tells spotlight to look up and use all the relevant 'stuff':
//
//				For the kMDItemOMUserTags example:
//				kMDItemOMUserTags is an array of nsstrings. So create one, tags = [NSArray arrayWithObjects:@"foo", @"bar"], and make a dictionary entry for it:
//				[myAttributeDict setObject:tags forKey:@"kMDItemOMUserTags"];
//		
//				Then add other attributes that your app uses:
//				[myAttributeDict setObject:[NSNumber numberWithFloat:2] forKey:(NSString*)kMDItemStarRating];

//				Then register the types:
//				[OpenMeta registerOMAttributes:myAttributeDict forAppName:@"myCoolApp"];
//
//				Doing all of this is necc to get searches like 'starrating:>4' working in spotlight, and for the item 'Rated' to show up 
//				in the Finder (and other apps) when you do a Find and then look under the little 'Other' menu. 
//
//				All this routine does is make a file that the importer will import, then let mdimport go at it, then remove the file. 
//
//	Inputs:		
//
//	Outputs:	
//
//  Created by Tom Andersen on 2009/01/21 
//
//----------------------------------------------------------------------
+(void)registerOMAttributes:(NSDictionary*)typicalAttributes forAppName:(NSString*)appName;
{
	// the spotlight plugin is registered to only import files with openmetaschema as an extension
	appName = [appName stringByAppendingString:@".openmetaschema"];
	
	// create the file: - directory - spotlight will still import it.
	NSString* path = [@"~/Library/Application Support/Punakea/OpenMeta/schemaregister" stringByExpandingTildeInPath];
	[[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
	path = [path stringByAppendingPathComponent:appName];
	
	[typicalAttributes writeToFile:path atomically:YES];
	
	// simpler - just leave mdimport a few seconds to get to the file. 
	[self performSelector:@selector(removeSchemaFile:) withObject:path afterDelay:2.0];
}

#pragma mark private 
//----------------------------------------------------------------------
//	spotlightKey
//
//	Purpose:	if we want an array of items to be recognized by spotlight, we need to 
//				use the corect key:
//
//	Inputs:		
//
//	Outputs:	
//
//  Created by Tom Andersen on 2008/07/17 
//
//----------------------------------------------------------------------
+(NSString*)spotlightKey:(NSString*)inKeyName;
{
	return [@"com.apple.metadata:" stringByAppendingString:inKeyName];
}

//----------------------------------------------------------------------
//	openmetaKey
//
//	Purpose:	store stuff in the openmeta key as well:
//
//	Inputs:		
//
//	Outputs:	
//
//  Created by Tom Andersen on 2008/07/17 
//
//----------------------------------------------------------------------
+(NSString*)openmetaKey:(NSString*)inKeyName;
{
	return [@"org.openmetainfo:" stringByAppendingString:inKeyName];
}

+(NSString*)openmetaTimeKey:(NSString*)inKeyName;
{
	return [@"org.openmetainfo.time:" stringByAppendingString:inKeyName];
}



+(NSString*)errnoString:(int)errnoErr;
{
	// the error is an errno from the system:
	char errorMessage[1024];
	errorMessage[0] = 0;
	strerror_r(errnoErr, errorMessage, 1024);
	return [NSString stringWithFormat:@"errno error: %d, %s", (int)errnoErr, errorMessage];
}

//----------------------------------------------------------------------
//	setXAttr:
//
//	Purpose:	Sets the xtended attribute on the passed file. Returns various errors
//
//	Inputs:		if items is empty or nil, the item at the passed key is removed
//
//	Authenticated version: the authenticated version will be called if the programmer has included the files into the project and linked to the Security framework.
//
//	Outputs:	
//
//  Created by Tom Andersen on 2008/07/17 
//
//----------------------------------------------------------------------
+(NSError*)setXAttr:(id)plistObject forKey:(NSString*)inKeyName path:(NSString*)path;
{
	const char *pathUTF8 = [path fileSystemRepresentation];
	if ([path length] == 0 || pathUTF8 == nil)
	{
		return [NSError errorWithDomain:@"openmeta" code:OM_ParamError userInfo:[NSDictionary dictionaryWithObject:OM_ParamErrorString forKey:@"info"]];
	}
	
	// If the object passed in has no data - is a string of length 0 or an array or dict with 0 objects, then we remove the data at the key.
	// reduces the number of xattrs we need to set and tae care of.
	// Leave that up to the caller. Often it is useful to have an empty array, etc on xattrs, as it says 'User set to 0 tags" (along with a time stamp).
	
	
//		 I used to consider it 'wrong' to be able to override kMDItem* stuff with OpenMeta, and it is for tags. Tags though are a special case,
//		 in that there could be for instance 6 keywords (relevant - ish) set on a PDF, and you want to add the open meta tag 'special' to it. You don't want to 
//		 lose the 6 keywords do you? There are also lots of images from image houses that have a lot of keyword 'noise' in them that you might not want
//		 cluttering up your tags that you have set. i have found png files with 50 keywords set. html can also be bad for this. So users want the ability to only look at tags that they have set,
//		 or a combination of keywords and tags.
//			BUT - look at ratings - ratings are just one number - it is likely that you don't want to as a user, have to think about 2 different places ratings 
//			could be stored, (like tags vs keywords), but would rather have just the one concept of 'rating'. It is also ok, even deisrable, to be able to override the rating
//			on a file. So ratings _should_ use kMDItemStarRating.
//			Also look at 'less used' keys - like camera (kMDItemAcquisitionMake and  kMDItemAcquisitionModel) - although they will be set on perhaps thousands of photos in 
//			what if you run into a PDF that is a picture taken with a camera, and you want to tag that? openmeta will allow you to to tag it with kMDItemAcquisitionMake and kMDItemAcquisitionModel
//			so that searches for camera make an model do not have to 'know about openmeta' to work. 
//			Plus it's always good to keep the number of keys down.
	
	const char* inKeyNameC = [inKeyName fileSystemRepresentation];
	
	long returnVal = 0;
	
	// always set data as binary plist.
	NSData* dataToSendNS = nil;
	if (plistObject)
	{
		NSString *errorString = nil;
		dataToSendNS = [NSPropertyListSerialization dataFromPropertyList:plistObject
																				format:kCFPropertyListBinaryFormat_v1_0
																				errorDescription:&errorString];
		if (errorString)
		{
			[errorString autorelease];
			dataToSendNS = nil;
			return [NSError errorWithDomain:@"openmeta" code:OM_NoDataFromPropertyListError userInfo:[NSDictionary dictionaryWithObject:errorString forKey:@"info"]];
		}
	}
	
	
	if (dataToSendNS)
	{
		// also reject for tags over the maximum size:
		if ([dataToSendNS length] > kMaxDataSize)
			return [NSError errorWithDomain:@"openmeta" code:OM_MetaTooBigError userInfo:[NSDictionary dictionaryWithObject:OM_MetaTooBigErrorString forKey:@"info"]];
		
		returnVal = setxattr(pathUTF8, inKeyNameC, [dataToSendNS bytes], [dataToSendNS length], 0, XATTR_NOFOLLOW);
	}
	else
	{
		returnVal = removexattr(pathUTF8, inKeyNameC, XATTR_NOFOLLOW);
	}
	
	// only backup kMDItemOM - open meta stuff. 
	if (returnVal == 0)
	{
		if ([OpenMetaBackup attributeKeyMeansAutomaticBackup:inKeyName])
			[OpenMetaBackup backupMetadata:path]; // backup all meta data changes. 
		return nil;
	}
	
	
	// the file OpenMetaAuthenticate.m is optional. So check that we have it loaded.
	int theErrorNumber = errno;
	if (theErrorNumber == EACCES && [self respondsToSelector:@selector(authenticatedSetXAttr:forKey:path:)])
	{
		NSError* errorOnAuthenticatedAttempt = [self authenticatedSetXAttr:plistObject forKey:inKeyName path:path];
		if (errorOnAuthenticatedAttempt == nil)
		{
			if ([OpenMetaBackup attributeKeyMeansAutomaticBackup:inKeyName])
				[OpenMetaBackup backupMetadata:path]; // backup all meta data changes. 
			
			return nil; // success after authenticating
		}
		// return original error - return errorOnAuthenticatedAttempt;
	}
	
	// return original error 
	return [NSError errorWithDomain:NSPOSIXErrorDomain code:theErrorNumber userInfo:[NSDictionary dictionaryWithObject:[self errnoString:theErrorNumber] forKey:@"info"]];
}

//----------------------------------------------------------------------
//	getXAttr
//
//	Purpose:	returns attribute
//
//	Inputs:		
//
//	Outputs:	plist object - whether nsarray (often) or nsstring, dictionary, number... 
//
//  Created by Tom Andersen on 2008/07/17 
//
//----------------------------------------------------------------------
+(id)getXAttr:(NSString*)inKeyName path:(NSString*)path error:(NSError**)error;
{
	// we can't put restore meta here - as restoreMetadata calls us! 
	// I put the restore on the usertags and ratings. Users will have to manually call restore for other keys 
	//[OpenMetaBackup restoreMetadata:path];
	
	const char *pathUTF8 = [path fileSystemRepresentation];
	if ([path length] == 0 || pathUTF8 == nil)
	{
		if (error)
			*error = [NSError errorWithDomain:@"openmeta" code:OM_ParamError userInfo:[NSDictionary dictionaryWithObject:OM_ParamErrorString forKey:@"info"]];
		return nil;
	}
	
	const char* inKeyNameC = [inKeyName fileSystemRepresentation];
	// retrieve data from store. 
	char* data[kMaxDataSize];
	ssize_t dataSize = kMaxDataSize; // ssize_t means SIGNED size_t as getXattr returns - 1 for no attribute found
	NSData* nsData = nil;
	dataSize = getxattr(pathUTF8, inKeyNameC, data, dataSize, 0, XATTR_NOFOLLOW);
	if (dataSize > 0)
	{
		nsData = [NSData dataWithBytes:data	length:dataSize];
	}
	else
	{
		// I get EINVAL sometimes when setting/getting xattrs on afp servers running 10.5. When I get this error, I find that everything is working correctly... so it seems to make sense to ignore them
		// EINVAL means invalid argument. I know that the args are fine. 
		if ((errno != ENOATTR) && (errno != EINVAL) && error) // it is not an error to have no attribute set 
			*error = [NSError errorWithDomain:NSPOSIXErrorDomain code:errno userInfo:[NSDictionary dictionaryWithObject:[self errnoString:errno] forKey:@"info"]];
		return nil;
	}
	
	// ok, we have some data 
	NSPropertyListFormat formatFound;
	NSString* errorString;
	id outObject = [NSPropertyListSerialization propertyListFromData:nsData mutabilityOption:kCFPropertyListImmutable format:&formatFound errorDescription:&errorString];
	if (errorString)
	{
		if (error)
			*error = [NSError errorWithDomain:@"openmeta" code:OM_NoDataFromPropertyListError userInfo:[NSDictionary dictionaryWithObject:errorString forKey:@"info"]];
		[errorString release]; // "Unlike the normal memory management rules for Cocoa, strings returned in errorString need to be released by the caller" - apple docs
		return nil;
	}
	
	if (error)
		*error = nil;
	return outObject;
}

//----------------------------------------------------------------------
//	validateAsArrayOfStrings
//
//	Purpose:	
//
//	Inputs:		
//
//	Outputs:	
//
//  Created by Tom Andersen on 2008/06/14 
//
//----------------------------------------------------------------------
+(BOOL)validateAsArrayOfStrings:(NSArray*)array;
{
	if (![array isKindOfClass:[NSArray class]])
		return NO;
	
	NSEnumerator* enumerator = [array objectEnumerator];
	NSString* aString;
	while (aString = [enumerator nextObject])
	{
		if (![aString isKindOfClass:[NSString class]])
			return NO;
	}
	return YES;
}

//----------------------------------------------------------------------
//	orderedArrayWithDict
//
//	Purpose:	preserve order: The dict has the tags we want, while the sort hint is a superset of the tags, with the order correct
//
//	Inputs:		
//
//	Outputs:	
//
//  Created by Tom Andersen on 2008/11/25 
//
//----------------------------------------------------------------------
+(NSArray*)orderedArrayWithDict:(NSDictionary*)inTags sortHint:(NSArray*)inSortedItems;
{
	if ([inSortedItems count] == 0)
		return [inTags allValues];
	
	NSMutableDictionary* tagsWeWant = [NSMutableDictionary dictionaryWithDictionary:inTags];
	NSMutableArray* orderedArray = [NSMutableArray arrayWithCapacity:[inTags count]];
	for (NSString* aTag in inSortedItems)
	{
		if ([tagsWeWant objectForKey:[aTag lowercaseString]])
		{
			[tagsWeWant removeObjectForKey:[aTag lowercaseString]];
			[orderedArray addObject:aTag];
		}
	}
	
	// if the sort hint was deficient in some way, just add the remaining ones in.
	if ([tagsWeWant count] > 0)
		[orderedArray addObjectsFromArray:[tagsWeWant allValues]];
	
	return [NSArray arrayWithArray:orderedArray];
}

// turn umlats, etc into same format as file sys uses. There are two ways to represent ü , etc. (single or multiple code points in utf (8)).
+(NSArray*)decomposeArrayOfStrings:(NSArray*)inTags;
{
	NSMutableArray* outArray = [NSMutableArray arrayWithCapacity:[inTags count]];
	for (NSString* aTag in inTags)
		[outArray addObject:[aTag decomposedStringWithCanonicalMapping]];
	
	return outArray;
}

//----------------------------------------------------------------------
//	removeDuplicateTags
//
//	Purpose:	case preserving case insensitive removal of duplicate tags
//
//	Inputs:		
//
//	Outputs: Also decomposes the strings to a standardized UTF8 representation	
//
//  Created by Tom Andersen on 2008/07/17 
//
//----------------------------------------------------------------------
+(NSArray*)removeDuplicateTags:(NSArray*)tags;
{
	if (tags == nil)
		return nil;
	
	// we always store tags as decomposed UTF-8 strings:
	// turn umlats, etc into same format that the file system uses, for consistency 
	tags = [self decomposeArrayOfStrings:tags];
	
	NSMutableDictionary* dict = [NSMutableDictionary dictionary];
	for (NSString* aTag in tags)
		[dict setObject:aTag forKey:[aTag lowercaseString]];
	
	// preserve order.
	return [self orderedArrayWithDict:dict sortHint:tags];
}


@end
