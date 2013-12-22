//
//  OpenMetaBackup.m
//  Fresh
//
//  Created by Tom Andersen on 26/01/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#include <sys/xattr.h>
#include <sys/time.h>
#include <sys/stat.h>
#include <sys/unistd.h>

#import "OpenMeta.h"
#import "OpenMetaBackup.h"

NSString* OpenMetaBackupSingleFileDoneNote = @"OpenMetaBackupSingleFileDoneNote";

NSString* kBackupPath = @"~/Library/Application Support/Punakea/OpenMeta/backups.noindex"; // i guess this should be some messy cocoa special folder lookup for application support

BOOL gDoOpenMetaBackups = YES; // mechanism for shutting down backups - place txt file at ~/Library/Application Support/OpenMeta/backups.noindex/No Backups Please.txt"

@interface OpenMetaBackup (Private)
+(NSString*)fsRefToPath:(FSRef*)inRef;
+(NSData*)aliasDataForFSRef:(FSRef*)inRef;
+(NSData*) aliasDataForPath:(NSString*)inPath;
+(NSString*) resolveAliasDataToPathFileIDFirst:(NSData*)inData osErr:(OSErr*)outErr;
+(NSString*) backupPathForMonthsBeforeNow:(int)inMonthsBeforeNow;
+(NSString*) backupPathForItem:(NSString*)inPath;
+(void)restoreMetadataSearchForFile:(NSString*)inPath withDelay:(NSTimeInterval)inDelay;
+(NSString*)hashString:(NSString*)inString;
+(NSThread*)backupThread;
+(void)enqueueBackupItem:(NSString*)inPath;
+(NSString*)truncatedPathComponent:(NSString*)aPathComponent;
+(void)backupMetadataNow:(NSString*)inPath;
+(int)restoreMetadataDict:(NSDictionary*)buDict toFile:(NSString*)inFile;
+(BOOL)backupThreadIsBusy;
+(BOOL)openMetaThreadIsBusy;
+(NSDate*)modDateOfFile:(NSString*)inPath;
+(NSDate*)creationDateOfFile:(NSString*)inPath;
+(void)singleFileQueueIsBusyError;
+(NSDictionary*)openMetaDictForPath:(NSString*)inPath;
@end

@implementation OpenMetaBackup

//----------------------------------------------------------------------
//	OpenMetaBackup
//
//	OpenMetaBackup - the idea is to store a backup of all user entered meta data - eg tags, ratings, etc. 
//					these are backed up to a folder in the application support folder Library/Application Support/OpenMeta/2009/1/lotsOfbackupfiles.omback
//
//					When tags, etc are about to be set on a document and the document has no openmeta data set on it, we check to make sure that it is actually an empty doc, 
//					and not some doc that has had the metadata stripped away. 
//
//					Currently, any setting of an kMDItemOM* key will cause a backup to happen. Restore is attempted for Tags and ratings only - if you need to restore, then you have to call it yourself,
//					which is easy.
//	
//
//
//  Created by Tom Andersen on 2009/01/26 
//
//----------------------------------------------------------------------


#pragma mark backup and restore openmeta data

//----------------------------------------------------------------------
//	backupMetadata
//
//	Purpose:	backs up metadata for the passed path. 
//				can be called many times in a row, will coalesce backup requests into one write
//	
//
//	Inputs:		gDoOpenMetaBackups
//
//	Outputs:	
//
//  Created by Tom Andersen on 2009/01/26 
//
//----------------------------------------------------------------------
+(void)backupMetadata:(NSString*)inPath;
{
	if (!gDoOpenMetaBackups)
		return;
	
	if ([inPath length] == 0)
		return;
	
	// backups are handled by a thread that has a queue
	NSThread* buThread = [self backupThread];  	
	[self performSelector:@selector(enqueueBackupItem:) onThread:buThread withObject:inPath waitUntilDone:NO];
}

+(BOOL)hasTagsOrRatingsSet:(NSString*)inPath;
{
	// if the ratings have been set OR removed, there will still be a time stamp for this.
	if ([OpenMeta getXAttr:[OpenMeta openmetaTimeKey:(NSString*)kMDItemStarRating] path:inPath error:nil])
		return YES;
	
	// if the tags have been set OR removed, there will still be a time stamp for this.
	if ([OpenMeta getXAttr:[OpenMeta openmetaTimeKey:(NSString*)kMDItemOMUserTags] path:inPath error:nil])
		return YES;
	
	return NO;
}

+(void)restoreMetadata:(NSString*)inPath withDelay:(NSTimeInterval)inDelay;
{
	if (![[NSFileManager defaultManager] fileExistsAtPath:inPath])
		return;
	
	if ([self hasTagsOrRatingsSet:inPath])
		return;
	
	// if a file has nothing set on it, then either has never been tagged, or some process like adobe photoshop et al., has stripped off the tags. At this point we can't tell which, so we search for a restore.
	[self restoreMetadataSearchForFile:inPath withDelay:inDelay];
}

//----------------------------------------------------------------------
//	restoreMetadata (public call)
//
//	Purpose:	if there is openmeta data of any sort set on the file, this call returns without doing anything.
//
//	Inputs:		
//
//	Outputs:	
//
//  Created by Tom Andersen on 2009/01/26 
//
//----------------------------------------------------------------------
+(void)restoreMetadata:(NSString*)inPath;
{
	// the delay thing is used to work around a bug/problem with spotlight not noticing multiple changes to files in the same second.
	[self restoreMetadata:inPath withDelay:0.0];
}

#pragma mark upgrade to kMDItemOMUserTags 
//----------------------------------------------------------------------
//	upgradeOpenMetaTokMDItemOM (public call)
//
//	Purpose:	Allows old applications using kOMUserTags to work with applications that use the newer format.
//				this should be run in any major app that uses open meta until about 2010, say Feb. After that only run 
//				if user wants to run it? 
//
//	NOTE:		Only call once per running of the application
//
//  Created by Tom Andersen on 2009/10/08 
//
//----------------------------------------------------------------------
+(void)upgradeOpenMetaTokMDItemOM;
{
	static NSOperationQueue* operationQ = nil;
	if (operationQ != nil)
		return; // only call once
		
	operationQ = [[NSOperationQueue alloc] init];
	OpenMetaUpgradeOperation* newOperation = [[[OpenMetaUpgradeOperation alloc] init] autorelease];
	[operationQ addOperation:newOperation];
}


#pragma mark backup and restore to from single file
NSOperationQueue* singleFileOperationQueue = nil;
+(NSOperationQueue*)singleFileQueue;
{
	if (singleFileOperationQueue == nil)
		singleFileOperationQueue = [[NSOperationQueue alloc] init];
	
	return singleFileOperationQueue;
}

//----------------------------------------------------------------------
//	backupAllMetadata (public call)
//
//	Purpose:	Make a single large backup file of all openmeta data. Data is obtained via a Spotlight Search on the passed keys.
//				If the passed keys are empty or nil, then kMDItemOMUserTags, kMDItemStarRating and kMDItemOMManaged are backed up.
//				This call is async. When the operation is done, a notification on the main thread will be sent out with a dictionary describing what happened.
//
//	Inputs:		
//
//	Outputs:	Note that all Openmeta data is backed up, not just the keys passed in. The passed in keys are for search only.
//
//  Created by Tom Andersen on 2009/01/26 
//
//----------------------------------------------------------------------
+(void)backupMetadataToSingleFile:(NSArray*)keysToSearch toFile:(NSString*)toFile;
{
	if ([[[self singleFileQueue] operations] count] > 0)
	{
		[self singleFileQueueIsBusyError];
		return;
	}
	
	OpenMetaBackupOperation* newOperation = [[[OpenMetaBackupOperation alloc] init] autorelease];
	newOperation.keysToSearch = keysToSearch;
	newOperation.singleFile = toFile;
	newOperation.writeFile = YES;
	[[self singleFileQueue] addOperation:newOperation];
}

+(void)restoreMetadataFromSingleFile:(NSString*)inBackupFile;
{
	if ([[[self singleFileQueue] operations] count] > 0)
	{
		[self singleFileQueueIsBusyError];
		return;
	}
	
	OpenMetaBackupOperation* newOperation = [[[OpenMetaBackupOperation alloc] init] autorelease];
	newOperation.singleFile = inBackupFile;
	newOperation.writeFile = NO;
	[[self singleFileQueue] addOperation:newOperation];
}

#pragma mark backup paths and stamps

//----------------------------------------------------------------------
//	calculateBackupFileName
//
//	Purpose:	the backup stap for the file - what the stamp should be for the passed path - NOT what is stored on disk
//
//	Inputs:		The stamp is a combination of a parital (full for short) file's name, a hash of the file name and a hash of the full path. 
//
//	Outputs:	
//
//  Created by Tom Andersen on 2009/01/28 
//
//----------------------------------------------------------------------
+(NSString*)calculateBackupFileName:(NSString*)inPath;
{
	NSString* fileName = [self truncatedPathComponent:[inPath lastPathComponent]]; 
	NSString* fileNameHash = [self hashString:[inPath lastPathComponent]]; // hash the name
	NSString* folderHash = [self hashString:[inPath stringByDeletingLastPathComponent]]; // hash is for the parent folder - this allows for searching for renamed files in some cases...
	NSString* buFileName = [fileName stringByAppendingString:@"__"];
	buFileName = [buFileName stringByAppendingString:fileNameHash];
	buFileName = [buFileName stringByAppendingString:@"__"];
	buFileName = [buFileName stringByAppendingString:folderHash];
	buFileName = [buFileName stringByAppendingString:@".omback"];
	
	return buFileName;
}	

//----------------------------------------------------------------------
//	backupPathForMonthsBeforeNow
//
//	Purpose:	I store backups in month - dated folders. Once a month is over, i won't write any new files in that month. (there are very small time zone issues)
//				Thus in the future, an optimized 'old' month searching db / fast access could be made...
//
//	Inputs:		
//
//	Outputs:	
//
//  Created by Tom Andersen on 2009/01/28 
//
//----------------------------------------------------------------------
+(NSString*) backupPathForMonthsBeforeNow:(int)inMonthsBeforeNow;
{
	NSString* backupPath = [kBackupPath stringByExpandingTildeInPath];

	// I changed the backup path to have .noindex on it, to prevent indexing by spotlight.
	// In order to support older OpenMeta apps out there, I create a sym link that points from the old path to the new one.
	if (gDoOpenMetaBackups && ![[NSFileManager defaultManager] fileExistsAtPath:backupPath])
	{
		NSString* oldBackupPath = [@"~/Library/Application Support/Punakea/OpenMeta/backups" stringByExpandingTildeInPath];
		if ([[NSFileManager defaultManager] fileExistsAtPath:oldBackupPath])
			rename([oldBackupPath fileSystemRepresentation], [backupPath fileSystemRepresentation]); // the old one was there, so rename it to the new .noindex name
		else 
			[[NSFileManager defaultManager] createDirectoryAtPath:backupPath withIntermediateDirectories:YES attributes:nil error:nil]; // create it - this is likely a first run
		symlink([backupPath fileSystemRepresentation], [oldBackupPath fileSystemRepresentation]); // create a link called backup that points to backup.noindex
	}
			
	NSCalendarDate* todaysDate = [NSCalendarDate calendarDate];
	
	int theYear = [todaysDate yearOfCommonEra];
	int theMonth = [todaysDate monthOfYear]; // 1 - 12 returned
	
	// adjust:
	theMonth -= inMonthsBeforeNow;
	while (theMonth < 1)
	{
		theMonth += 12;
		theYear -= 1;
	}
	
	backupPath = [backupPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%d", theYear]];
	backupPath = [backupPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%d", theMonth]];
	
	return backupPath;
}

//----------------------------------------------------------------------
//	currentBackupPath
//
//	Purpose:	The path to the folder for the current months backups. Directory created if needed.
//
//	Inputs:		
//
//	Outputs:	
//
//  Created by Tom Andersen on 2009/01/28 
//
//----------------------------------------------------------------------
+(NSString*) currentBackupPath;
{
	NSString* bupath = [self backupPathForMonthsBeforeNow:0];
	if (gDoOpenMetaBackups && ![[NSFileManager defaultManager] fileExistsAtPath:bupath])
		[[NSFileManager defaultManager] createDirectoryAtPath:bupath withIntermediateDirectories:YES attributes:nil error:nil];
	
	return bupath;
}

//----------------------------------------------------------------------
//	truncatedPathComponent
//
//	Purpose:	backupStamps and backupfiles need to have filenames that are manageable. This truncs filenames by cutting in the middle.
//
//	Inputs:		
//
//	Outputs:	
//
//  Created by Tom Andersen on 2009/01/28 
//
//----------------------------------------------------------------------
+(NSString*)truncatedPathComponent:(NSString*)aPathComponent;
{
	if ([aPathComponent length] > 40)
	{
		// we need to trunc the same way every time... - take first 20 plus last twenty
		aPathComponent = [[aPathComponent substringToIndex:20] stringByAppendingString:[aPathComponent substringFromIndex:[aPathComponent length] - 20]];
	}
	return aPathComponent;
}


//----------------------------------------------------------------------
//	backupPathForItem
//
//	Purpose:	place to write backup file for passed item
//
//	Inputs:		
//
//	Outputs:	
//
//  Created by Tom Andersen on 2009/01/28 
//
//----------------------------------------------------------------------
+(NSString*) backupPathForItem:(NSString*)inPath;
{
	// now create the special name that allows lookup:
	// our file names are: the filename.extension__hash.omback
	return [[self currentBackupPath] stringByAppendingPathComponent:[self calculateBackupFileName:inPath]];
}

#pragma mark restore all metadata - bulk 
BOOL gOMRestoreThreadBusy = NO;
BOOL gOMIsTerminating = NO;

+(BOOL)backupDictsTheSame:(NSDictionary*)one two:(NSDictionary*)two;
{
	if ([one count] != [two count])
		return NO;
	
	NSArray* keys = [one allKeys];
	for (NSString* aKey in keys)
	{
		id obj1 = [one objectForKey:aKey];
		id obj2 = [two objectForKey:aKey];
		
		// if both objects are dates, they will compare non equal, even though they both were spawned by the same date: the stored date in a backup file is only good to the second, I think that the binary plist gets more resolution?
		if ([obj1 isKindOfClass:[NSDate class]] && [obj2 isKindOfClass:[NSDate class]])
		{
			// compare the dates
			NSTimeInterval difference = [obj1 timeIntervalSinceDate:obj2];
			if (fabs(difference) > 2.0)
				return NO;
		}
		else 
		{
			if (![obj1 isEqual:obj2])
				return NO;
		}
	}
	return YES;
}
							
+(int)restoreMetadataFromBackupDictIfNeeded:(NSDictionary*)backupContents;
{
	if ([backupContents count] == 0)
		return 0;

	NSString* filePath = [backupContents objectForKey:@"bu_path"];
	if (![[NSFileManager defaultManager] fileExistsAtPath:filePath])
	{
		OSErr theErr;
		filePath = [self resolveAliasDataToPathFileIDFirst:[backupContents objectForKey:@"bu_alias"] osErr:&theErr];
		if (![[NSFileManager defaultManager] fileExistsAtPath:filePath])
			return 0; // could find no file to bu to.
	}
	
	// obtain the current state of affairs on the file by looking at a backup dict from the existing file:
	NSDictionary* currentData = [OpenMetaBackup openMetaDictForPath:filePath];
	NSDictionary* omDataFromBackup = [backupContents objectForKey:@"omDict"];
	
	if ([currentData count] == 0 && [omDataFromBackup count] == 0)
		return 0; // no data anywhere
	
	if ([self backupDictsTheSame:currentData two:omDataFromBackup])
		return 0;
	
	// there is a difference between what is on the file and the backup stuff passed in.
	// it could be that the backup stuff is old, etc. So look at that. 
	int numKeysSet = [self restoreMetadataDict:backupContents toFile:filePath];
	
#if KP_DEBUG
	if (numKeysSet > 0)
		NSLog(@"meta data repaired on %@ with %@", filePath, backupContents);
#endif
	return numKeysSet;
}

//----------------------------------------------------------------------
//	restoreMetadataFromBackupFileIfNeeded
//
//	Purpose:	restores kMDItemOM* data
//
//
//  Created by Tom Andersen on 2009/01/28 
//
//----------------------------------------------------------------------
+(int)restoreMetadataFromBackupFileIfNeeded:(NSString*)inPathToBUFile;
{
	NSDictionary* backupContents = [NSDictionary dictionaryWithContentsOfFile:inPathToBUFile];
	return [self restoreMetadataFromBackupDictIfNeeded:backupContents];
}


//----------------------------------------------------------------------
//	tellUserRestoreFinished
//
//	Purpose:	will show a modal dialog when the restore is finished. 
//
//	Inputs:		you can override the strings in a localization file
//
//	Outputs:	
//
//  Created by Tom Andersen on 2009/03/11 
//
//----------------------------------------------------------------------
+(void)tellUserRestoreFinished:(NSNumber*)inNumberOfFilesRestored;
{
	NSString* title = NSLocalizedString(@"Open Meta Restore Done", @"");
	
	NSString* comments = NSLocalizedString(@"No files needed to have meta data such as tags and ratings restored.", @"");
	if ([inNumberOfFilesRestored intValue] > 0)
	{
		comments = NSLocalizedString(@"%1 files had meta data such as tags and ratings restored.", @"");
		comments = [comments stringByReplacingOccurrencesOfString:@"%1" withString:[inNumberOfFilesRestored stringValue]];
	}

// There is some UI in the OpenMeta code. If you don't want to or can't link to UI, then define OPEN_META_NO_UI in the compiler settings. 
// ie:  in the target info in XCode set : Preprocessor Macros Not Used In Precompiled Headers OPEN_META_NO_UI=1
#if OPEN_META_NO_UI 
	NSLog(@" %@ \n %@ ", title, comments);
#else
	NSRunAlertPanel(	title,
						comments, 
						nil,
						nil,
						nil,
						nil);
#endif
}

//----------------------------------------------------------------------
//	restoreAllMetadata
//
//	Purpose:	should be run as  a 'job' on a thread to restore metadata to every file it can find that has no metadata set. 
//
//	Inputs:		
//
//	Outputs:	
//
//  Created by Tom Andersen on 2009/01/26 
//
//----------------------------------------------------------------------
+(void)restoreAllMetadata:(NSNumber*)tellUserWhenDoneNS;
{
	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
	
	BOOL tellUserWhenDone = [tellUserWhenDoneNS boolValue];
	
	// go through files, opening up as needed the filePath metadata...
	// when i find one that needs restoring, also issue a call to add it to this month's list of edits.
	// look through the previous 12 months for data. 
	// when i find it needs restoring, also issue a call to add it to this month's list of edits.
	int count;
	int numFilesFixed = 0;
	int numFilesChecked = 0;
	for (count = 0; count < 36; count++)
	{
		NSString* backupDir = [self backupPathForMonthsBeforeNow:count];
		NSArray* fileNames = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:backupDir error:nil];
		
		// the file name and folder name in the backup file filename may be truncated:
		for (NSString* aFileName in fileNames)
		{
			NSAutoreleasePool* innerPool = [[NSAutoreleasePool alloc] init];
			// our file names have: the filename.extension__pathhash.omback
			// just plow through, restoring...
			numFilesFixed += [self restoreMetadataFromBackupFileIfNeeded:[backupDir stringByAppendingPathComponent:aFileName]];
			
			numFilesChecked++;
			
			if (!tellUserWhenDone)
				[NSThread sleepForTimeInterval:0.05]; // don't push too hard if we are running lazily (not telling the user when we are done)
			
			if (gOMIsTerminating)
			{
				[innerPool release];
				[pool release];
				gOMRestoreThreadBusy = NO;
				return;
			} 
			[innerPool release];
		}
	}

#if KP_DEBUG
	NSLog(@"%d files checked for restore", numFilesChecked);
#endif
	
	if (tellUserWhenDone)
	{
		NSNumber* numFilesFixedNS = [NSNumber numberWithInt:numFilesFixed];
		[self performSelectorOnMainThread:@selector(tellUserRestoreFinished:) withObject:numFilesFixedNS waitUntilDone:YES];
	}
	
	[pool release];
	gOMRestoreThreadBusy = NO;
}

//----------------------------------------------------------------------
//	restoreAllMetadataOnBackgroundThread
//
//	Purpose:	
//
//	Inputs:		
//
//	Outputs:	
//
//  Created by Tom Andersen on 2009/01/28 
//
//----------------------------------------------------------------------
+(void)restoreAllMetadataOnBackgroundThread:(BOOL)tellUserWhenDone;
{
	if (gOMRestoreThreadBusy)
	{
		NSLog(@"meta data restore already running");
		return;
	}
	
	gOMRestoreThreadBusy = YES;
	NSNumber* tellUserWhenDoneNS = [NSNumber numberWithBool:tellUserWhenDone];
	[NSThread detachNewThreadSelector:@selector(restoreAllMetadata:) toTarget:self withObject:tellUserWhenDoneNS];
}

+(BOOL)restoreThreadIsBusy;
{
	return gOMRestoreThreadBusy;
}


//----------------------------------------------------------------------
//	appIsTerminating
//
//	Purpose: call this to tell restore and other functions running in the background to gracefully exit.	
//
//	Inputs:		
//
//	Outputs:	
//
//  Created by Tom Andersen on 2009/01/28 
//
//----------------------------------------------------------------------
+(void)appIsTerminating;
{
	gOMIsTerminating = YES;
	while ([OpenMetaBackup openMetaThreadIsBusy])
		[NSThread sleepForTimeInterval:0.1];
}

//----------------------------------------------------------------------
//	openMetaThreadIsBusy
//
//	Purpose:	returns true if some backup thread is working on stuff
//
//	usage: at terminate
//	while ([OpenMetaBackup openMetaThreadIsBusy])
//		[NSThread sleepForTimeInterval:0.1];
//			
//
//	Outputs:	
//
//  Created by Tom Andersen on 2009/01/28 
//
//----------------------------------------------------------------------
+(BOOL)openMetaThreadIsBusy;
{
	if ([self restoreThreadIsBusy] || [self backupThreadIsBusy])
		return YES;
	
	return NO;
}

#pragma mark copy old kOM tags to new kMDItemOM tags  
//----------------------------------------------------------------------
//	copyTagsFromOldKeyTokMDItemOMIfNeeded
//
//	Purpose:	Oct 8, 2009 : if user has old and new api on the system, then they will sometimes enter keys using the old api. 
//				before doing a get tags for editing type of event, 
//
//	Inputs:		THE DICT is NOT the entire file - just the actual backed up data - the omDict.
//
//	Outputs:	
//
//  Created by Tom Andersen on 2009/10/08 
//
//----------------------------------------------------------------------
+(void)copyTagsFromOldKeyTokMDItemOMIfNeeded:(NSString*)inPath;
{
	NSError* error = nil;
	// if someone is using an older api, tags will be set with:
	// org.openmetainfo:kOMUserTags [array of tags]
	// org.openmetainfo.time:kOMUserTags [NSDate]
	// With the new api, they will set tags like
	// org.openmetainfo:kMDItemOMUserTags [array of tags]
	// org.openmetainfo.time:kMDItemOMUserTags [NSDate]
	
	// we compare the two dates. If the kOMUserTagTime is newer than kMDItemOMUserTagTime, then we copy tags from kOMUserTags into kMDItemOMUserTags 
	NSDate* thekOMDate = [OpenMeta getXAttr:@"org.openmetainfo.time:kOMUserTags" path:inPath error:&error];
	NSDate* thekMDItemOMDate = [OpenMeta getXAttr:@"org.openmetainfo.time:kMDItemOMUserTags" path:inPath error:&error];
	
	if (thekOMDate == nil)
		return; // there was no date information on the file. 
	
	// to compare dates they both need to be there:
	if (thekOMDate == nil)
		thekOMDate = [NSDate distantPast];
	if (thekMDItemOMDate == nil)
		thekMDItemOMDate = [NSDate distantPast];
	
	// can't use compare, as that is sub - second, and the dates in plists are not that accurate.
	NSTimeInterval dateCompare = [thekOMDate timeIntervalSinceDate:thekMDItemOMDate]; 
	// positive values indicate that the thekOMDate is later than the thekMDItemOMDate date, so we should use it.
	// note that if the tags were wiped out by a cocoa nsdocument based save in 10.6, then the times will have been wiped away. 
	// in that case, dateCompare should be <= 0, so we won't rewrite them.
	if (dateCompare >= 2.0)
	{
		NSArray* thekOMTags = [OpenMeta getXAttr:@"org.openmetainfo:kOMUserTags" path:inPath error:&error];
		NSArray* thekMDItemOMTags = [OpenMeta getXAttr:@"org.openmetainfo:kMDItemOMUserTags" path:inPath error:&error];
		
		// someone could have erased the tags using an older api, etc, so we should honour that kind of thing?
		if (![thekOMTags isEqualToArray:thekMDItemOMTags])
		{
			// set the tags, 
			// set user tags, 
			[OpenMeta setXAttr:thekOMTags forKey:@"org.openmetainfo:kMDItemOMUserTags" path:inPath];
			[OpenMeta setXAttr:thekOMTags forKey:@"com.apple.metadata:kMDItemOMUserTags" path:inPath];
			[OpenMeta setXAttr:thekOMDate forKey:@"org.openmetainfo.time:kMDItemOMUserTags" path:inPath];
		}
	}
}

#pragma mark restoring metadata
//----------------------------------------------------------------------
//	restoreMetadataDict
//
//	Purpose:	Oct 8, 2009 : changing OpenMeta prefix to work with Snow Leopard bug
//
//	Inputs:		THE DICT is NOT the entire file - just the actual backed up data - the omDict.
//
//	Outputs:	
//
//  Created by Tom Andersen on 2009/10/08 
//
//----------------------------------------------------------------------
+(int)restoreOldMetadataKey:(NSString*)aKey fromDict:(NSDictionary*)omDict toFile:(NSString*)inFile;
{
	// the passed key is an 'old' kOM key. We only set 'new' format data, and only do that if there is no openmetainfo org stuff on the file.
	// this keeps things simple.
	id dataInBU = [omDict objectForKey:aKey];
	if (dataInBU)
	{
		NSError* error = nil;
		// only set data that is not already set - the idea of a backup is only replace if missing...
		
		// if there is new format data on disk then we are done. 
		NSString* newKey = [aKey stringByReplacingOccurrencesOfString:@"org.openmetainfo:kOM" withString:@"org.openmetainfo:kMDItemOM"];
		id data = [OpenMeta getXAttr:newKey path:inFile error:&error];
		if (data)
			return 0;
		
		NSString* newTimeKey = [newKey stringByReplacingOccurrencesOfString:@"org.openmetainfo:" withString:@"org.openmetainfo.time:"];
		
		// There was no org.openmetainfo on the file... what about com.apple.metadata?
		NSString* newKeySpotlight = [aKey stringByReplacingOccurrencesOfString:@"org.openmetainfo:kOM" withString:@"com.apple.metadata:kMDItemOM"];
		data = [OpenMeta getXAttr:newKeySpotlight path:inFile error:&error];
		if (data)
		{
			// repair the data - but use the existing on disk data - it will likely be newer, and is likely from 10.6 save bug issue
			[OpenMeta setXAttr:data forKey:newKey path:inFile];
			// set the date as now:
			[OpenMeta setXAttr:[NSDate date] forKey:newTimeKey path:inFile];
			return 1;
		}

		// there was no data of any sort, so use what we have, but update the data:
		NSString* oldTimeKey = [aKey stringByReplacingOccurrencesOfString:@"org.openmetainfo:" withString:@"org.openmetainfo.time:"];
		NSDate* dateInBU = [omDict objectForKey:oldTimeKey];
		BOOL writeDate = (dateInBU != nil);
		
		
		NSString* oldAppleMetaDataKey = [aKey stringByReplacingOccurrencesOfString:@"org.openmetainfo:" withString:@"com.apple.metadata:"];
		
		[OpenMeta setXAttr:dataInBU forKey:newKey path:inFile];
		
		if ([omDict objectForKey:oldAppleMetaDataKey])
			[OpenMeta setXAttr:dataInBU forKey:newKeySpotlight path:inFile];
		// if the backup date is 'real' then write it too:
		if (writeDate)
			[OpenMeta setXAttr:dateInBU forKey:newTimeKey path:inFile];
		
		return 1;
	}
	return 0;
}

//----------------------------------------------------------------------
//	restoreMetadataDict
//
//	Purpose:	Sep 1, 2009 : only restore open meta data
//
//	Inputs:		
//
//	Outputs:	
//
//  Created by Tom Andersen on 2009/01/28 
//
//----------------------------------------------------------------------
+(int)restoreMetadataDict:(NSDictionary*)buDict toFile:(NSString*)inFile;
{
	NSDictionary* omDict = [buDict objectForKey:@"omDict"];
	
	int numKeysRestored = 0;
	
	NSError* error = nil;
	for (NSString* aKey in [omDict allKeys])
	{
		// only restore open meta data:
		
		// backward compatibility kOM
		if ([aKey hasPrefix:@"org.openmetainfo.kOM"])
		{
			// this is an older backup record. We need to handle this differently:
			numKeysRestored += [self restoreOldMetadataKey:aKey fromDict:omDict toFile:inFile];
		}
		else if ([aKey hasPrefix:@"org.openmetainfo:"])
		{
			id dataInBU = [omDict objectForKey:aKey];
			if (dataInBU)
			{
				// Compare dates
				
				// get the dates on the attribute on disk and the attribute in the backup dict:
				NSString* timeKey = [aKey stringByReplacingOccurrencesOfString:@"org.openmetainfo:" withString:@"org.openmetainfo.time:"];
				NSDate* dateOnDisk = [OpenMeta getXAttr:timeKey path:inFile error:&error];
				NSDate* dateInBU = [omDict objectForKey:timeKey];
				BOOL writeDate = (dateInBU != nil);
				
				// to compare dates they both need to be there:
				if (dateOnDisk == nil)
					dateOnDisk = [NSDate distantPast];
				if (dateInBU == nil)
					dateInBU = [NSDate distantPast];
				
				NSString* appleMetaDataKey = [aKey stringByReplacingOccurrencesOfString:@"org.openmetainfo:" withString:@"com.apple.metadata:"];
				
				// can't use compare, as that is sub - second, and the dates in the backup files are only accurate to the second.
				NSTimeInterval dateCompare = [dateInBU timeIntervalSinceDate:dateOnDisk]; // positive values indicate that the dateInBackup is newer than the on disk date.
				if (fabs(dateCompare) < 2.0)
				{
					// the dates are the same. Only set if the data is missing on disk 
					id objectOnDisk = [OpenMeta getXAttr:aKey path:inFile error:&error];
					if (objectOnDisk == nil)
					{
						numKeysRestored++;
						[OpenMeta setXAttr:dataInBU forKey:aKey path:inFile];
						if ([omDict objectForKey:appleMetaDataKey])
							[OpenMeta setXAttr:dataInBU forKey:appleMetaDataKey path:inFile];
						
						// if the backup date is 'real' then write it too:
						if (writeDate)
							[OpenMeta setXAttr:dateInBU forKey:timeKey path:inFile];
					}
				}
				else if (dateCompare >= 2.0)
				{
					// the backup time is later than the on disk time - the data is old.
					numKeysRestored++;
					[OpenMeta setXAttr:dataInBU forKey:aKey path:inFile];
					if ([omDict objectForKey:appleMetaDataKey])
						[OpenMeta setXAttr:dataInBU forKey:appleMetaDataKey path:inFile];
					// if the backup date is 'real' then write it too:
					if (writeDate)
						[OpenMeta setXAttr:dateInBU forKey:timeKey path:inFile];
				}
			}
		}
	}
	return numKeysRestored;
}

+(BOOL)modDateOfFile:(NSString*)inBackupPath isAfterCreationDateOf:(NSString*)inFile;
{
	NSDate* modDate = [self modDateOfFile:inBackupPath];
	NSDate* creationDate = [self creationDateOfFile:inFile];
	NSComparisonResult compareResult = [modDate compare:creationDate];
	if (compareResult == NSOrderedSame || compareResult == NSOrderedDescending)
		return YES;

	return NO;
}

//----------------------------------------------------------------------
//	restoreMetadataFromBackupFile
//
//	Purpose:	restores data to the passed path. Will only restore if the passed path matches the alias or the stored path. (we also check filename in emergency)
//
//	Inputs:		
//
//	Outputs:	Returns YES if the dictionary looked like it was the right one for the file. 
//				Does NOT tell you if any restore was actually done.
//
//  Created by Tom Andersen on 2009/01/28 
//
//----------------------------------------------------------------------
+(BOOL)restoreMetadataFromBackupFile:(NSString*)inPathToBUFile toFile:(NSString*)inPath withDelay:(NSTimeInterval)inDelay;
{
	NSDictionary* backupContents = [NSDictionary dictionaryWithContentsOfFile:inPathToBUFile];
	if ([backupContents count] == 0)
		return NO;
	
	
	//  if an alias path comes back, then we know there is a file there. 
	OSErr theErr;
	NSString* aliasPath = [self resolveAliasDataToPathFileIDFirst:[backupContents objectForKey:@"bu_alias"] osErr:&theErr];
	
	// if the path is right, then look at restoring and returning:
	if ([inPath isEqualToString:[backupContents objectForKey:@"bu_path"]])
	{
		// Another tweak: Applications, and perhaps other file types like to use path based tags - when you update an application, 
		// you want the tags to be reapplied. 
		if ([[inPath pathExtension] isEqualToString:@"app"])
		{
			if (inDelay > 0.0)
				[NSThread sleepForTimeInterval:inDelay];
			[self restoreMetadataDict:backupContents toFile:inPath];
			return YES;
		}
		
		// the path is the same as the backup path. 
		// we can still trip over the 'Picture 1" scenario - Picture 1 lands on the desktop and is promptly tagged
		// then renamed and moved. So the tags are on the moved file.
		// when the next screenshot comes down the pipe, the alias will point to the moved file, which is what we want
		// but if the alias does not work, then we know that the original is nowhere to be found, so we can add tags to this file.
		if ([aliasPath length] == 0 || [inPath isEqualToString:aliasPath])
		{
			if (inDelay > 0.0)
				[NSThread sleepForTimeInterval:inDelay];
			[self restoreMetadataDict:backupContents toFile:inPath];
			return YES;
		}
	}
	
	// if the alias resolves to the path 
	if ([inPath isEqualToString:aliasPath])
	{
		// the file has moved. Or it seems likely that the file has moved.
		if ([self modDateOfFile:inPathToBUFile isAfterCreationDateOf:inPath])
		{
			if (inDelay > 0.0)
				[NSThread sleepForTimeInterval:inDelay];
			[self restoreMetadataDict:backupContents toFile:inPath];
		}
		return YES;
	}
	
	return NO;
}

//----------------------------------------------------------------------
//	modDateOfFile
//
//	Purpose:	
//
//	Inputs:		
//
//	Outputs:	
//
//  Created by Tom Andersen on 2009/04/30 
//
//----------------------------------------------------------------------
+(NSDate*)modDateOfFile:(NSString*)inPath;
{
	NSDate* modDate = [[[NSFileManager defaultManager] attributesOfItemAtPath:inPath error:nil] objectForKey:NSFileModificationDate];
	if (modDate == nil)
		modDate = [NSDate dateWithTimeIntervalSinceReferenceDate:0]; // that way asking for a non existent directory will also cache nicely
	return modDate;
}

+(NSDate*)creationDateOfFile:(NSString*)inPath;
{
	NSDate* creationDate = [[[NSFileManager defaultManager] attributesOfItemAtPath:inPath error:nil] objectForKey:NSFileCreationDate];
	if (creationDate == nil)
		creationDate = [NSDate dateWithTimeIntervalSinceReferenceDate:0]; // that way asking for a non existent directory will also cache nicely
	return creationDate;
}


//----------------------------------------------------------------------
//	cachedContentsOfDirectoryAtPath
//
//	Purpose:	returns contents of directory - open meta keeps a cached copy for performance reasons.
//
//	Inputs:		
//
//	Outputs:	
//
//  Created by Tom Andersen on 2009/04/30 
//
//----------------------------------------------------------------------
+(NSArray*)cachedContentsOfDirectoryAtPath:(NSString*)inPath;
{
	static NSMutableDictionary* cachedDirectories = nil;
	if (cachedDirectories == nil)
		cachedDirectories = [[NSMutableDictionary alloc] init];
	
	@synchronized(cachedDirectories)
	{
		NSDictionary* cachedPaths = [cachedDirectories objectForKey:inPath];
		if (cachedPaths)
		{
			// if the date is good, then return with info.
			if ([[cachedPaths objectForKey:@"modDate"] isEqual:[self modDateOfFile:inPath]])
			{
				return [[[cachedPaths objectForKey:@"files"] retain] autorelease];  // the retain autorelease makes for thread safe
			}
		}
		
		// ok - we got to here - it means that we have to make a new entry in the dict:
		NSArray* fileNames = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:inPath error:nil];
		if (fileNames == nil)
			fileNames = [NSArray array]; // if someone asks for non exitent file, we cache that as an empty array with a date at the reference date

		cachedPaths = [NSDictionary dictionaryWithObjectsAndKeys:fileNames, @"files", [self modDateOfFile:inPath], @"modDate", nil];
		[cachedDirectories setObject:cachedPaths forKey:inPath];
		return fileNames;  // since we just made them in this thread they are auto released in the right pool.
	}
	return nil; // compiler happy
}

//----------------------------------------------------------------------
//	cachedContentsOfDirectoryAtPathAsString
//
//	Purpose:	returns all the filenames in a directory mashed together in one c string (utf8 file sys rep), nil terminated.
//
//	Inputs:		
//
//	Outputs:	
//
//  Created by Tom Andersen on 2009/05/19 
//
//----------------------------------------------------------------------
+(char*)cachedContentsOfDirectoryAtPathAsString:(NSString*)inPath;
{
	static NSMutableDictionary* cachedDirectoriesCStrings = nil;
	if (cachedDirectoriesCStrings == nil)
		cachedDirectoriesCStrings = [[NSMutableDictionary alloc] init];
	
	@synchronized(cachedDirectoriesCStrings)
	{
		NSDictionary* cachedPaths = [cachedDirectoriesCStrings objectForKey:inPath];
		if (cachedPaths)
		{
			// if the date is good, then return with info.
			if ([[cachedPaths objectForKey:@"modDate"] isEqual:[self modDateOfFile:inPath]])
			{
				NSData* theData = [[[cachedPaths objectForKey:@"mashedFileNames"] retain] autorelease];  // the retain autorelease makes for thread safe
				char* longCString = (char*) [theData bytes];
				return longCString;
			}
		}
		
		// ok - we got to here - it means that we have to make a new entry in the dict:
		NSArray* fileNames = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:inPath error:nil];
		if (fileNames == nil)
			fileNames = [NSArray array]; // if someone asks for non exitent file, we cache that as an empty array with a date at the reference date
		
		NSMutableData* bigString = [NSMutableData dataWithCapacity:1000];
		
		for (NSString* aFileName in fileNames)
		{
			char* utf8filename =  (char*) [aFileName fileSystemRepresentation];
			[bigString appendBytes:utf8filename length:strlen(utf8filename)];
		}
		
		char nilTerm = '\0';
		[bigString appendBytes:&nilTerm length:1];
		
		cachedPaths = [NSDictionary dictionaryWithObjectsAndKeys:bigString, @"mashedFileNames", [self modDateOfFile:inPath], @"modDate", nil];
		[cachedDirectoriesCStrings setObject:cachedPaths forKey:inPath];
		char* longCString =  (char*) [bigString bytes];
		return longCString;
	}
	return nil; // compiler happy
}

//----------------------------------------------------------------------
//	restoreMetadataSearchForFile
//
//	Purpose:	This call is called when we can't find meta data for a file, which happens when a file has no metadata set on it.
//	
//	NOTE:		This call needs to be fast, as it can get called often, but it also has to be able to find metadata easily...
//
//	Inputs:		
//
//	Outputs:	
//
//  Created by Tom Andersen on 2009/01/28 
//
//----------------------------------------------------------------------
+(void)restoreMetadataSearchForFile:(NSString*)inPath withDelay:(NSTimeInterval)inDelay;
{
	// This needs to be fast. 
	// First we look through the past year for a backup file with the exact name. 
	// Failing that we look through the directory contents of the past year. 
	// I cache the directory contents. 
	
	// look for an exact match on the previous 12 months of data. If there is one found, we are good. 
	//----------
	NSString* exactBackupFileName = [self calculateBackupFileName:inPath];
	int count;
	for (count = 0; count < 12; count++)
	{
		NSString* backupDir = [self backupPathForMonthsBeforeNow:count];
		if ([self restoreMetadataFromBackupFile:[backupDir stringByAppendingPathComponent:exactBackupFileName] toFile:inPath withDelay:inDelay])
			return; // found a backup file that looked good enough to use.
	}
	
	// only if a delay is specified do I search through the directory: the code below takes too long to run when we are called in main thread, etc...
	if (inDelay == 0.0)
		return; 
	
	// filenames are trunced to 40 chars in the stamp
	NSString* fileNameToLookFor = [self truncatedPathComponent:[inPath lastPathComponent]];
	char* fileNameToLookForUTF8 =  (char*) [[self truncatedPathComponent:[inPath lastPathComponent]] fileSystemRepresentation];
	
	// look through the previous 12 months for data. 
	// when i find it needs restoring, also issue a call to add it to this month's list of edits.
	// this is looking for files with the same name as the passed one. If one is found, we check to see if it is the right
	// file using alias. If is, apply the backup.
	for (count = 0; count < 12; count++)
	{
		NSString* backupDir = [self backupPathForMonthsBeforeNow:count];
		
		// here is the huge speed booster - look for files
		char* allFilenamesMashed = [self cachedContentsOfDirectoryAtPathAsString:backupDir];
		if (strstr(allFilenamesMashed, fileNameToLookForUTF8))
		{
			NSArray* fileNames = [self cachedContentsOfDirectoryAtPath:backupDir];
			// the file name and folder name in the backup file filename may be truncated:
			for (NSString* aFileName in fileNames)
			{
				// our file names have: the filename.extension__pathhash.omback
				
				// look for a hit on name. When we see a name match, check now. 
				// for folder matches we just add to our array of ones to check.
				if ([aFileName rangeOfString:fileNameToLookFor options:NSLiteralSearch].location != NSNotFound) // not sure if NSLiteralSearch is ideal (it is much faster), but we are looking for an exact match based on what were the same strings at one point.
				{
					if ([self restoreMetadataFromBackupFile:[backupDir stringByAppendingPathComponent:aFileName] toFile:inPath withDelay:inDelay])
						return; // found a backup file that looked good enough to use. (ie alias resolve worked)
				}
			}
		}
	}
	
	// if all else fails - do we look through every file until we get a hit? - perhaps look through files for a second or so? 
	// it seems that this should be the job of  of the 'OM fix' app that fixes damage done by Adobe apps.
	
	// one thing we could do is look through all the items that have the same parent folder hash as the passed path,
	// then see if any of the aliases point to the item. If any do, then use that, but if we find some files with aliases that don't resolve,
	// then we could ask the user if that meta data is the correct one/pick from a list...?
	
	
	// note that editing a moved file in photoshop will render the alias useless. The path is also useless. 
	// moving a renamed, tagged file, and then editing it in photoshop will lose tags. 
	
	// that would be slow. Perhaps we just give up. Maybe the restore all will do the trick...
	
}

//----------------------------------------------------------------------
//	ELFHash
//
//	Purpose:	hash to use for strings. Note that this has to be constant, 
//				and always 32 bit number, which is why the cocoa hash on the string will not work for us.	
//
//	Inputs:		
//
//	Outputs:	
//
//  Created by Tom Andersen on 2009/01/28 
//
//----------------------------------------------------------------------
unsigned int ELFHash(const char* str, unsigned int len)
{
   unsigned int hash = 0;
   unsigned int x    = 0;
   unsigned int i    = 0;

   for(i = 0; i < len; str++, i++)
   {
      hash = (hash << 4) + (*str);
      if((x = hash & 0xF0000000L) != 0)
      {
         hash ^= (x >> 24);
      }
      hash &= ~x;
   }

   return hash;
}

//----------------------------------------------------------------------
//	hashString
//
//	Purpose:	has as number string
//
//	Inputs:		
//
//	Outputs:	
//
//  Created by Tom Andersen on 2009/01/28 
//
//----------------------------------------------------------------------
+(NSString*)hashString:(NSString*)inString;
{
	// don't use built in hash - it is 64 bit on 64bit compiles, and is not guaranteed to be constant across restart (ie system updates)
	// unsigned int is always 32 bit
	const char* fileSysRep = [inString fileSystemRepresentation];
	
	unsigned int hashNumber = ELFHash(fileSysRep, strlen(fileSysRep));
	return [[NSNumber numberWithUnsignedInt:hashNumber] description];
}

#pragma mark thread that does all the backups
//----------------------------------------------------------------------
//	backupThreadMain
//
//	Purpose:	The idea of the backup thread is so that one can call backupMetadata (the public api)
//				lots (like hundreds) of times over a short period, and have the actual backup file created just once (or a small number of times).
//				
//				The slight disadvantage is that rapidly moving files may not get their metadata backed up. (path changes before we get there to backup the file)
//
//	Inputs:		
//
//	Outputs:	
//
//  Created by Tom Andersen on 2009/01/28 
//
//----------------------------------------------------------------------
+(void)keepAlive:(NSTimer*)inTimer;
{
	// this keeps run loop running
}

// this array to only be accessed in the backupThread.
NSMutableArray* gOMBackupQueue = nil;
BOOL gOMBackupThreadBusy = NO;

+(void)backupThreadMain:(NSThread*)inThread;
{
	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
	
	// create array that holds all pending backups. Note that this array can only be accessed from this thread, as I don't lock it.
	gOMBackupQueue = [[NSMutableArray alloc] init];
	
	NSRunLoop* theRL = [NSRunLoop currentRunLoop];
	
	// this timer keeps the thread running. Seemed simpler than an input source
	[NSTimer scheduledTimerWithTimeInterval:86400 target:self selector:@selector(keepAlive:) userInfo:nil repeats:YES];
	
	// use autorelease pools around each event
	while (![inThread isCancelled])
	{
		NSAutoreleasePool *poolWhileLoop = [[NSAutoreleasePool alloc] init];
		[theRL runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
		[poolWhileLoop release];
	}
	
	[pool release];
}

//----------------------------------------------------------------------
//	backupThreadIsBusy
//
//	Purpose:	returns true if the backup thread is working on stuff
//
//	usage: at terminate
//	while ([OpenMetaBackup backupThreadIsBusy])
//		[NSThread sleepForTimeInterval:0.1];
//	Inputs:		
//
//	Outputs:	
//
//  Created by Tom Andersen on 2009/01/28 
//
//----------------------------------------------------------------------
+(BOOL)backupThreadIsBusy;
{
	return gOMBackupThreadBusy;
}

//----------------------------------------------------------------------
//	backupThread
//
//	Purpose:	returns the backup thread. Usually called from the main thread, but I put a synchronize on it just in case
//
//	Inputs:		
//
//	Outputs:	
//
//  Created by Tom Andersen on 2009/01/28 
//
//----------------------------------------------------------------------
+(NSThread*)backupThread;
{
	@synchronized([self class])
	{
		static NSThread* buThread = nil;
		if (buThread == nil)
		{
			// if there is a file called noBackup 
			NSString* noBackupPath = [[kBackupPath stringByExpandingTildeInPath] stringByAppendingPathComponent:@"No Backups Please.txt"];
			if ([[NSFileManager defaultManager] fileExistsAtPath:noBackupPath])
				gDoOpenMetaBackups = NO;
			
			buThread = [[NSThread alloc] initWithTarget:self selector:@selector(backupThreadMain:) object:buThread];
			[buThread start];
		}
		return buThread;
	}
	return nil;
}

//----------------------------------------------------------------------
//	enqueueBackupItem
//
//	Purpose:	add the path to the list of items to backup data for. 
//				note that if the backup is already in the queue we do nothing.
//
//	Thread:		only call on the buThread
//
//	Outputs:	
//
//  Created by Tom Andersen on 2009/01/28 
//
//----------------------------------------------------------------------
+(void)enqueueBackupItem:(NSString*)inPath;
{
	gOMBackupThreadBusy = YES;
	if ([gOMBackupQueue containsObject:inPath])
		return;
	
	[gOMBackupQueue addObject:inPath];
	
	if ([gOMBackupQueue count] == 1)
		[self performSelector:@selector(doABackup:) withObject:nil afterDelay:0.2];
}

//----------------------------------------------------------------------
//	doABackup
//
//	Purpose:	Does a backup. If there are more on the queue, we call ourselves later.
//
//	Thread:		only call on the buThread
//
//	Outputs:	
//
//  Created by Tom Andersen on 2009/01/28 
//
//----------------------------------------------------------------------
+(void)doABackup:(id)arg;
{
	if ([gOMBackupQueue count] == 0)
		return;
	
	NSString* thePathToDo = [gOMBackupQueue objectAtIndex:0];
	[self backupMetadataNow:thePathToDo];
	[gOMBackupQueue removeObjectAtIndex:0];
	
	if ([gOMBackupQueue count] > 0)
	{
		NSTimeInterval delay = 0.03;
		if (gOMIsTerminating)
			delay = 0.000001; // go full speed
		
		[self performSelector:@selector(doABackup:) withObject:nil afterDelay:delay];
	}
	else
	{
		gOMBackupThreadBusy = NO;
	}
}

// you can backup the open meta data about any file by calline [OpenmetaBackup backupMetadata:path].
// only when you set tags are backup files automatically created.

+(BOOL)attributeKeyMeansAutomaticBackup:(NSString*)attrName;
{
	if ([attrName rangeOfString:kMDItemOMUserTags options:NSLiteralSearch].location != NSNotFound)
		return YES;
		
	return NO;
}


+(BOOL)attributeKeyMeansBackup:(NSString*)attrName;
{
	// the org.openmetainfo will grab the org.openmetainfo: and org.openmetainfo.time: 
	if ([attrName hasPrefix:@"org.openmetainfo"] || [attrName hasPrefix:@"kMDItemOM"] || [attrName hasPrefix:[OpenMeta spotlightKey:@"kMDItem"]] )
		return YES;
	
	return NO;
}

+(NSDictionary*)openMetaDictForPath:(NSString*)inPath;
{
	if ([inPath length] == 0)
		return nil;
	
	// create dictionary representing all kMDItemOM* metadata on the file:
	NSMutableDictionary* omDictionary = [NSMutableDictionary dictionary];
	
	char* nameBuffer = nil;
	
	ssize_t bytesNeeded = listxattr([inPath fileSystemRepresentation], nil, 0, XATTR_NOFOLLOW);
	
	if (bytesNeeded <= 0)
		return nil; // no attrs or no info.
	
	nameBuffer = malloc(bytesNeeded);
	listxattr([inPath fileSystemRepresentation], nameBuffer, bytesNeeded, XATTR_NOFOLLOW);
	
	// walk through the returned buffer, getting names, 
	char* namePointer = nameBuffer;
	ssize_t bytesLeft = bytesNeeded;
	while (bytesLeft > 0)
	{
		NSString* attrName = [NSString stringWithUTF8String:namePointer];
		ssize_t byteLength = strlen(namePointer) + 1;
		namePointer += byteLength;
		bytesLeft -= byteLength;
		
		// backup all kMDItemOM and kMDItem stuff. This will also back up apple's where froms, etc.
		if ([self attributeKeyMeansBackup:attrName])
		{
			// add to dictionary:
			NSError* error = nil;
			id objectStored = [OpenMeta getXAttr:attrName path:inPath error:&error];
			
			if (objectStored)
				[omDictionary setObject:objectStored forKey:attrName];
		}
	}
	if (nameBuffer)
		free(nameBuffer);

	return omDictionary;
}

+(NSDictionary*)backupDictForPath:(NSString*)inPath;
{
	NSDictionary* omDictionary = [self openMetaDictForPath:inPath];
	if ([omDictionary count] == 0)
		return nil;
	
	NSMutableDictionary* outerDictionary = [NSMutableDictionary dictionary];
	
	[outerDictionary setObject:omDictionary forKey:@"omDict"];
	
	// create alias to file, so that we can find it easier:
	NSData* fileAlias = [[self class] aliasDataForPath:inPath];
	if (fileAlias)
		[outerDictionary setObject:fileAlias forKey:@"bu_alias"];
	
	// store path - which is in the alias too but not directly accessible
	if (inPath)
		[outerDictionary setObject:inPath forKey:@"bu_path"];
	
	// store date that we did the backup
	[outerDictionary setObject:[NSDate date] forKey:@"bu_date"];
	
	return outerDictionary;
}

//----------------------------------------------------------------------
//	backupMetadataNow
//
//	Purpose:	actually backs up the meta data. 
//
//	Thread:		should be able to call on any thread. 
//
//	Outputs:	
//
//  Created by Tom Andersen on 2009/01/28 
//
//----------------------------------------------------------------------
+(void)backupMetadataNow:(NSString*)inPath;
{
	NSDictionary* backupDict = [self backupDictForPath:inPath];
	
	if ([backupDict count] > 0)
	{
		// place to put data: 
		// filename is 
		NSString* buItemPath = [self backupPathForItem:inPath];
		[backupDict writeToFile:buItemPath atomically:YES];
	}
}

#pragma mark alias handling

//----------------------------------------------------------------------
//	fsRefToPath
//
//	Purpose:	Given an fsref, returns a path
//
//	Inputs:		
//
//	Outputs:	
//
//  Created by Tom Andersen on 2009/01/28 
//
//----------------------------------------------------------------------
+(NSString*)fsRefToPath:(FSRef*)inRef;
{			
	if (inRef == nil)
		return nil;
		
	char thePath[4096];
	OSStatus err = FSRefMakePath(inRef, (UInt8*) &thePath, 4096);
	
	if (err == noErr)
	{
		NSString* filePath = [[NSFileManager defaultManager] stringWithFileSystemRepresentation:thePath length:strlen(thePath)];
		return filePath;
	}
	return nil;
}

//----------------------------------------------------------------------
//	aliasDataForFSRef
//
//	Purpose:	returns an alias for the passed fsRef - aliases only work for existing files.
//
//	Inputs:		
//
//	Outputs:	
//
//  Created by Tom Andersen on 2009/01/28 
//
//----------------------------------------------------------------------
+(NSData*)aliasDataForFSRef:(FSRef*)inRef;
{
	AliasHandle aliasHandle = nil;
	OSStatus err = FSNewAlias(nil, inRef, &aliasHandle);
	
	if (err != noErr || aliasHandle == nil)
	{
		if (aliasHandle)
			DisposeHandle((Handle) aliasHandle);
		return nil;
	}
	
	HLock((Handle)aliasHandle);
	NSData* aliasData = [NSData dataWithBytes:*aliasHandle length:GetHandleSize((Handle) aliasHandle)];
	HUnlock((Handle)aliasHandle);

	if (aliasHandle)
		DisposeHandle((Handle) aliasHandle);
	return aliasData;
}
//----------------------------------------------------------------------
//	aliasForPath
//
//	Purpose: returns an alias for a path. NSData	
//
//	Inputs:		
//
//	Outputs:	
//
//  Created by Tom on 2007/02/13 
//
//----------------------------------------------------------------------
+(NSData*) aliasDataForPath:(NSString*)inPath;
{
	if (inPath == nil)
		return nil;
	
	FSRef pathFSRef;
	OSErr err = FSPathMakeRefWithOptions((const UInt8*) [inPath fileSystemRepresentation], kFSPathMakeRefDoNotFollowLeafSymlink, &pathFSRef, nil);
	if (err != noErr)
		return nil;
		
	return [self aliasDataForFSRef:&pathFSRef];
}

//----------------------------------------------------------------------
//	resolveAliasDataToPathFileIDFirst
//
//	Purpose:	
//
//	Inputs:		
//
//	Outputs:	
//
//  Created by Tom on 2007/02/13 
//
//----------------------------------------------------------------------
+(NSString*) resolveAliasDataToPathFileIDFirst:(NSData*)inData osErr:(OSErr*)outErr;
{
	*outErr = paramErr;
	if (inData == nil)
		return nil;
	
	if (![inData isKindOfClass:[NSData class]])
		return nil;
	
	*outErr = noErr;
	
	//Constants
	//kResolveAliasFileNoUI
	//The Alias Manager should resolve the alias without presenting a user interface.
	//kResolveAliasTryFileIDFirst
	//The Alias Manager should search for the alias target using file IDs before searching using the path.
	
	// we need to construct a handle from nsdata:
	NSString* thePath = nil;
	AliasHandle aliasHandle;
	if (PtrToHand([inData bytes], (Handle*)&aliasHandle, [inData length]) == noErr)
	{
		// We want to allow the caller to avoid blocking if the volume  
		//in question is not reachable.  The only way I see to do that is to  
		//pass the kResolveAliasFileNoUI flag to FSResolveAliasWithMountFlags.  
		//This will cause it to fail immediately with nsvErr (no such volume).
//		unsigned long mountFlags = kResolveAliasTryFileIDFirst;
//		mountFlags |= kResolveAliasFileNoUI; // no ui 
		unsigned long mountFlags = kResolveAliasFileNoUI | kResolveAliasTryFileIDFirst; // we use fileid fist for open meta as we want tags to follow actual files more than paths.
			
		FSRef				theTarget;
		Boolean				changed;
		
		if((*outErr = FSResolveAliasWithMountFlags( NULL, aliasHandle, &theTarget, &changed, mountFlags )) == noErr)
		{
			thePath = [self fsRefToPath:&theTarget];
		}
		if (aliasHandle)
			DisposeHandle((Handle) aliasHandle);
	}
	return thePath;
}

#pragma mark live repair thread

// Adobe Photoshop, Illustrator(?) and other CS3 and 4 apps (and other adobe products like elements) have a serious bug where they erase all metadata from a file at every save (not only save as...)
// To work around this bug, we run this thread which watches for changed adobe files, (and image files, since adobe products can also create image files like jpegs and not leave any adobe traces). 
// This thread has a search in it that checks for stripped xattrs, and if it finds them it does a restore from backed up data. 
//------------------

//----------------------------------------------------------------------
//	restoreToMDItem
//
//	Purpose:	called whenever a file has been changed, added, etc according to the spotlight search
//
//	NOTE:		This will not be running on the main thread!
//
//	Outputs:	
//
//  Created by Tom Andersen on 2009/04/22 
//
//----------------------------------------------------------------------
+(void)restoreToMDItem:(MDItemRef)inItem;
{
	CFStringRef thePath = MDItemCopyAttribute(inItem, kMDItemPath);
	if (thePath)
	{
		// it could be that there is a bug in the way that spotlight reads in xattr changes - since file mod date as astored is only to a 1 second resolution
		// if a file is saved by photoshop, the plugin runs for spotlight, and the attributes are changed AFTER BUT IN THE SAME SECOND, the 
		// spotlight DB will not see that it is out of date, and it refuses to set the data on the file. - At least this is my guess. 
		// so I I wait one second in here, before the restore, then we should be ok. - 
		// I moved the wait to the place where the restore is actually done, so if there is no restore due for this file,
		// then we don't need to wait.
		if (![self hasTagsOrRatingsSet:(NSString*)thePath])
		{
			[self restoreMetadata:(NSString*)thePath withDelay:1.0];
#if KP_DEBUG
			NSLog(@"restored data to %@", (NSString*)thePath);
#endif
		}
		CFRelease(thePath);
	}
}


//----------------------------------------------------------------------
//	updatedLiveRepairQuery
//
//	Purpose:	spotlight callback for updated query
//
//	NOTE:		This will not be running on the main thread!
//
//	Outputs:	
//
//  Created by Tom Andersen on 2009/04/22 
//
//----------------------------------------------------------------------
+ (void)updatedLiveRepairQuery:(NSNotification *)queryNotification;
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	// if no documents have only changed - we don't need to do anything..
	NSDictionary* updatedInfo = [queryNotification userInfo];
	NSArray* addedItems = [updatedInfo objectForKey:@"kMDQueryUpdateAddedItems"];
	NSArray* changedItems = [updatedInfo objectForKey:@"kMDQueryUpdateChangedItems"];
	NSArray* removedItems = [updatedInfo objectForKey:@"kMDQueryUpdateRemovedItems"];
	
	// check all changed, added, removed docs.
	for (id mdRef in addedItems)
		[self restoreToMDItem:(MDItemRef)mdRef];

	for (id mdRef in changedItems)
		[self restoreToMDItem:(MDItemRef)mdRef];

	for (id mdRef in removedItems)
		[self restoreToMDItem:(MDItemRef)mdRef];


	[pool release];
}

//----------------------------------------------------------------------
//	finishedLiveRepairQuery
//
//	Purpose:	called when initial query is done. Only after this call comes through are we updating 
//
//	Note:		KP_DEBUG debug flag - turn it on in the project settings to enable it for debug builds.
//	NOTE:		This will not be running on the main thread!
//
//	Outputs:	
//
//  Created by Tom Andersen on 2009/04/22 
//
//----------------------------------------------------------------------
+ (void)finishedLiveRepairQuery:(NSNotification *)queryNotification;
{	
#if KP_DEBUG
	NSLog(@" done intial live query - query count is %d", MDQueryGetResultCount((MDQueryRef)[queryNotification object]));
#endif
}

+(void)keepLiveRepairAlive:(NSTimer*)inTimer;
{
	// this keeps run loop running
}

NSThread* sLiveRepairThread = nil;
//----------------------------------------------------------------------
//	liveRepairThread
//
//	Purpose:	this thread starts an mdquery. It runs until it detects a shutdown order.
//
//	NOTE:		This will not be running on the main thread!
//
//	Outputs:	
//
//  Created by Tom Andersen on 2009/04/22 
//
//----------------------------------------------------------------------
+(void)liveRepairThread:(id)arg;
{
	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
	
	// the timer also keeps the thread running.
	NSRunLoop* runLoop = [NSRunLoop currentRunLoop];
	[NSTimer scheduledTimerWithTimeInterval:86400 target:self selector:@selector(keepLiveRepairAlive:) userInfo:nil repeats:YES];
	
	// we want to look for any adobe file that has changed its content.
	// It seems difficult to get a search exactly 'right' - I don't want too much traffic, yet we want to cover all Adobe CS3 and CS4 apps, 
	// 
	// This search, with all images may be needed, and is what I use for the OMFix application. But it does result in some extra xattrs being placed on image files.
	//NSString* query = @"(kMDItemContentModificationDate > $time.now) && ((kMDItemCreator == '*Adobe*') || (kMDItemContentTypeTree == 'public.image') || (kMDItemContentType == '*adobe*'))";
	NSString* query = @"(kMDItemContentModificationDate > $time.now) && ((kMDItemCreator == '*Adobe*') || (kMDItemContentType == '*adobe*'))";
	
	// one other query to seriously consider - all modified files that have the word adobe in ANY key: (not tested though)
	//NSString* query = @"(kMDItemContentModificationDate > $time.now) && (* == '*adobe*'cd))";
	
	MDQueryRef mdQuery = MDQueryCreate(nil, (CFStringRef)query, nil, nil);

	// if something is goofy, we won't get the query back, and all calls involving a mil MDQuery crash. So return:
	if (mdQuery == nil)
	{
		[pool release];
		return;
	}
	
	NSNotificationCenter* nf = [NSNotificationCenter defaultCenter];
	//[nf addObserver:self selector:@selector(progressMDQuery:) name:(NSString*)kMDQueryProgressNotification object:(id) mdQuery];
	[nf addObserver:self selector:@selector(finishedLiveRepairQuery:) name:(NSString*)kMDQueryDidFinishNotification object:(id) mdQuery];
	[nf addObserver:self selector:@selector(updatedLiveRepairQuery:) name:(NSString*)kMDQueryDidUpdateNotification object:(id) mdQuery];
	
	// Should I run this query on the network too? Difficult decision, as I think that this will slow stuff way down.
	// But i think it will only query leopard servers so perhaps ok
	//MDQuerySetSearchScope(mdQuery, (CFArrayRef)[NSArray arrayWithObjects:(NSString*)kMDQueryScopeComputer, (NSString*)kMDQueryScopeNetwork, nil], 0); // this is suitable for the way we run leaps, local only
	
	// start it
	BOOL queryRunning = MDQueryExecute(mdQuery, kMDQueryWantsUpdates); 
	if (!queryRunning)
	{
		CFRelease(mdQuery);
		mdQuery = nil;
		// leave this log message in...
		NSLog(@"MDQuery for recently opened files failed to start in Fresh.");
		[pool release];
		return;
	}
		
	while (![sLiveRepairThread isCancelled])
	{
		NSAutoreleasePool *poolWhileLoop = [[NSAutoreleasePool alloc] init];
		[runLoop runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
		[poolWhileLoop release];
	}
	
	CFRelease(mdQuery);
	mdQuery = nil;
	[pool release];
}

//----------------------------------------------------------------------
//	startLiveRepairThread
//
//	Purpose:	Call this (its in the header) to run the live repair thread. 
//
//	NOTE:		You would usually call this from the main thread in something like applicationDidFinishLaunching
//
//	Outputs:	
//
//  Created by Tom Andersen on 2009/04/22 
//
//----------------------------------------------------------------------
+(void)startLiveRepairThread;
{
	if (sLiveRepairThread != nil)
		return;
	
	sLiveRepairThread = [[NSThread alloc] initWithTarget:self selector:@selector(liveRepairThread:) object:nil];
	[sLiveRepairThread start];
}

//----------------------------------------------------------------------
//	stopLiveRepairThread
//
//	Purpose:	
//
//	NOTE:		You would usually call this from the main thread in something like applicationWillTerminate
//
//	Outputs:	
//
//  Created by Tom Andersen on 2009/04/22 
//
//----------------------------------------------------------------------
+(void)stopLiveRepairThread;
{
	if ([sLiveRepairThread isCancelled])
		return; // only need to call once.
	
	[sLiveRepairThread cancel]; // calling this only sets a flag in the thread. 
	// so we need to make the thread do some call, any call, as this will run us through the event loop in the thread, so isCanceled can be checked
	[self performSelector:@selector(keepLiveRepairAlive:) onThread:sLiveRepairThread withObject:nil waitUntilDone:NO];
	
	// now wait here until the thread dies.
	// The reason I do this is because I have found that it is not a good thing to quit an application with live queries running - at least it looks that way to me
	// It seems in 10.5 that mds, being a single system wide service, does not know to flush active queries when the app thats making them does not clean up nice. - At least that's what seems to happen!
	int count = 0;
	while ([sLiveRepairThread isExecuting] && count++ < 10)
		[NSThread sleepForTimeInterval:0.05]; // sleep a bit to allow thread to quit 
	
#if KP_DEBUG
	if ([sLiveRepairThread isExecuting])
		NSLog(@"live repair thread failed to quit! - a half a second wait did not help");
	else
		NSLog(@"live repair thread quit in %f seconds", count*0.05);
#endif
	
	if (![sLiveRepairThread isExecuting])
	{
		[sLiveRepairThread release];
		sLiveRepairThread = nil;
	}

}

#pragma mark single file backup support

+(void)singleFileQueueIsBusyError;
{
	// we need to inform:
	NSDictionary* info = [NSDictionary dictionaryWithObject:@"busy" forKey:@"status"];
	[[NSNotificationCenter defaultCenter] postNotificationName:OpenMetaBackupSingleFileDoneNote object:info];
}
@end

@interface OpenMetaBackupOperation (Private)

-(void)writeSingleFile;
-(void)readSingleFile;
-(void)doneTheJob;

@end


@implementation OpenMetaBackupOperation
@synthesize singleFile;
@synthesize	keysToSearch;
@synthesize	returnDict;
@synthesize	writeFile;

-(void)main;
{
	// we are either to read or write open meta data:
	
	if (self.writeFile)
		[self writeSingleFile];
	else 
		[self readSingleFile];
	
	// ok report back the news:
	[self performSelectorOnMainThread:@selector(doneTheJob:) withObject:nil waitUntilDone:NO];
}

-(void)dealloc;
{
	self.singleFile = nil;
	self.keysToSearch = nil;
	self.returnDict = nil;
	[super dealloc];
}

-(void)doneTheJob:(id)obj;
{
	[[NSNotificationCenter defaultCenter] postNotificationName:OpenMetaBackupSingleFileDoneNote object:self.returnDict];
}

-(void)writeSingleFile;
{
	// first we have to search for all the items we can find. 
	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
	
	// create the query
	if ([self.keysToSearch count] == 0)
		self.keysToSearch = [NSArray arrayWithObjects:@"kMDItemOMManaged", kMDItemOMUserTags, (NSString*)kMDItemStarRating, nil];
	
	NSString* queryString = @"";
	for (NSString* aKey in self.keysToSearch)
	{
		NSString* thisKeyQuery = [NSString stringWithFormat:@"(%@ == *)", aKey];
		if ([queryString length] > 0)
			queryString = [queryString stringByAppendingString:@" || "];
		queryString = [queryString stringByAppendingString:thisKeyQuery];
	}
	
	MDQueryRef mdQuery = MDQueryCreate(nil, (CFStringRef)queryString, nil, nil);
	
	// if something is goofy, we won't get the query back, and all calls involving a mil MDQuery crash. So return:
	if (mdQuery == nil)
	{
		[pool release];
		self.returnDict = [NSDictionary dictionaryWithObject:@"spotlight failed" forKey:@"status"];
		return;
	}
	
	// look for these everywhere.
	CFArrayRef scope = (CFArrayRef)[NSArray arrayWithObjects:(NSString*)kMDQueryScopeAllIndexed, nil];
	MDQuerySetSearchScope(mdQuery, scope, 0);
	
	[NSRunLoop currentRunLoop]; // need run loop for mdquery
	
	
	// start it
	MDQuerySetMaxCount(mdQuery, 500000); // so we don't go completely crazy..
	BOOL queryRunning = MDQueryExecute(mdQuery, kMDQuerySynchronous); 
	if (!queryRunning)
	{
		CFRelease(mdQuery);
		[pool release];
		self.returnDict = [NSDictionary dictionaryWithObject:@"spotlight failed" forKey:@"status"];
		return;
	}
	
	// ok enumerate through the results:
	NSInteger numResults = MDQueryGetResultCount(mdQuery);

	NSMutableDictionary* mainDict = [NSMutableDictionary dictionary];
	
	NSInteger count;
	for (count = 0; count < numResults; count++)
	{
		NSAutoreleasePool* innerPool = [[NSAutoreleasePool alloc] init];
		
		MDItemRef theItem = (MDItemRef) MDQueryGetResultAtIndex(mdQuery, count);
		
		CFStringRef path = MDItemCopyAttribute(theItem, kMDItemPath);
		if (path)
		{
			NSDictionary* backupDict = [OpenMetaBackup backupDictForPath:(NSString*)path];
			if (backupDict)
				[mainDict setObject:backupDict forKey:(NSString*)path];
			
			CFRelease(path);
		}
		[innerPool release];
	}
	
	CFRelease(mdQuery);
	
	BOOL worked = [mainDict writeToFile:self.singleFile atomically:YES];
	
	
	NSString* statusString = [NSString stringWithFormat:@"%d backups done, file written to %@", numResults, [self.singleFile stringByAbbreviatingWithTildeInPath]];
	self.returnDict = [NSDictionary dictionaryWithObjectsAndKeys:	statusString, @"status",
																	[NSNumber numberWithBool:worked], @"worked",
																	[NSNumber numberWithInt:[mainDict count]], @"dictCount",
																	nil];
	
	[pool release];
}

-(void)readSingleFile;
{
	NSDictionary* mainDict = [NSDictionary dictionaryWithContentsOfFile:self.singleFile];
	if ([mainDict count] == 0)
	{
		self.returnDict = [NSDictionary dictionaryWithObject:@"no restore data found" forKey:@"status"];
		return;
	}
	
	// ok, loop through all keys
	NSArray* allKeys = [mainDict allKeys];
	int numberDone = 0;
	for (NSString* aPath in allKeys)
	{
		NSDictionary* backupDict = [mainDict objectForKey:aPath];
		numberDone += [OpenMetaBackup restoreMetadataFromBackupDictIfNeeded:backupDict];
	}
	
	
	NSString* statusString = [NSString stringWithFormat:@"%d restores done", numberDone];
	self.returnDict = [NSDictionary dictionaryWithObjectsAndKeys:	statusString, @"status",
					   [NSNumber numberWithBool:YES], @"worked",
					   [NSNumber numberWithInt:[mainDict count]], @"dictCount",
					   nil];
	
}


@end


#pragma mark convert from old kOM format to new kMDItemOM format

// class for converting from kOMUserTags to kMDItemOMUserTags
// it actually erases no data, it just adds a few fields of new data
@implementation OpenMetaUpgradeOperation
@synthesize		mdQueryString;
@synthesize		keyToSet;

-(void)upgradeTagsOnItem:(MDItemRef)inItem;
{
	NSString* fullOldKey = [@"com.apple.metadata:kOM" stringByAppendingString:keyToSet];
	
	NSString* metaNewKey = [@"com.apple.metadata:kMDItemOM" stringByAppendingString:keyToSet];
	NSString* infoNewKey = [@"org.openmetainfo:kMDItemOM" stringByAppendingString:keyToSet];
	NSString* timeNewKey = [@"org.openmetainfo.time:kMDItemOM" stringByAppendingString:keyToSet];
	
	CFStringRef path = MDItemCopyAttribute(inItem, kMDItemPath);
	if (path)
	{
		NSError* error = nil;
		NSArray* oldFormatTags = [OpenMeta getXAttr:fullOldKey path:(NSString*)path error:&error];
		if (error == nil)
		{
			NSArray* newFormatTags = [OpenMeta getXAttr:metaNewKey path:(NSString*)path error:&error];
			if (newFormatTags == nil)
			{
				[OpenMeta setXAttr:oldFormatTags forKey:infoNewKey path:(NSString*)path];
				[OpenMeta setXAttr:oldFormatTags forKey:metaNewKey path:(NSString*)path];
				[OpenMeta setXAttr:[NSDate date] forKey:timeNewKey path:(NSString*)path];
				// when doing imports of lots of files, we don't want to overload Spotlight mdimport - we want it to keep up.
				[NSThread sleepForTimeInterval:0.06];
			}
		}
		CFRelease(path);
	}
}

//----------------------------------------------------------------------
//	progressUpradeQuery
//
//	Purpose:	spotlight callback for progress query
//
//	NOTE:		This will not be running on the main thread!
//
//----------------------------------------------------------------------
- (void)progressUpradeQuery:(NSNotification *)queryNotification;
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	MDQueryRef mdQuery = (MDQueryRef)[queryNotification object];
	
	// added items are not in the dict, we need to go through them...
	NSInteger numResults = MDQueryGetResultCount(mdQuery);
	NSInteger count;
	for (count = 0; count < numResults; count++)
	{
		NSAutoreleasePool* innerPool = [[NSAutoreleasePool alloc] init];
		
		MDItemRef theItem = (MDItemRef) MDQueryGetResultAtIndex(mdQuery, count);
		[self upgradeTagsOnItem:(MDItemRef)theItem];
		[innerPool release];
	}
	
	
	NSDictionary* updatedInfo = [queryNotification userInfo];
	NSArray* changedItems = [updatedInfo objectForKey:@"kMDQueryUpdateChangedItems"];
	
	// check all changed too
	for (id mdRef in changedItems)
		[self upgradeTagsOnItem:(MDItemRef)mdRef];

	[pool release];
}

- (void)updatedUpradeQuery:(NSNotification *)queryNotification;
{
	// I have a bug - serious it seems where this gets in a loop:
	// so we 'only' do 100 calls through here, maximum.
	static int counter = 0;
	if (counter++ > 100)
		return;
	
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	NSDictionary* updatedInfo = [queryNotification userInfo];
	NSArray* addedItems = [updatedInfo objectForKey:@"kMDQueryUpdateAddedItems"];
	// don't worry about changed items in the search, as they could be the cause of this loop I am seeing.
	//NSArray* changedItems = [updatedInfo objectForKey:@"kMDQueryUpdateChangedItems"];
	
	// check only items added
	for (id mdRef in addedItems)
		[self upgradeTagsOnItem:(MDItemRef)mdRef];

	[pool release];
}

- (void)finishedUpradeQuery:(NSNotification *)queryNotification;
{	
#if KP_DEBUG
	MDQueryRef theQuery = (MDQueryRef)[queryNotification object];
	NSLog(@" done intial upgrade from kOM to kMDItemOM - query count is %d", MDQueryGetResultCount(theQuery));
#endif
}

-(void)keepLiveRepairAlive:(NSTimer*)inTimer;
{
	// this keeps run loop running
}

-(void)main;
{
	// we need a list of all files that have kOMUserTags but NOT kMDItemOMUserTags set:
	// live search:
	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
	
	// the timer also keeps the thread running.
	NSRunLoop* runLoop = [NSRunLoop currentRunLoop];
	[NSTimer scheduledTimerWithTimeInterval:86400 target:self selector:@selector(keepLiveRepairAlive:) userInfo:nil repeats:YES];
	
	// we want to look all files that have kOMUserTags but NOT kMDItemOMUserTags set:
	NSString* query = mdQueryString;
	if ([query length] == 0)
		query = @"((kOMUserTags == *) && (kMDItemOMUserTags != *))";
	
	
	if ([keyToSet length] == 0)
		keyToSet = @"UserTags";

	
	MDQueryRef mdQuery = MDQueryCreate(nil, (CFStringRef)query, nil, nil);

	// if something is goofy, we won't get the query back, and all calls involving a mil MDQuery crash. So return:
	if (mdQuery == nil)
	{
		[pool release];
		return;
	}
	
	NSNotificationCenter* nf = [NSNotificationCenter defaultCenter];
	[nf addObserver:self selector:@selector(progressUpradeQuery:) name:(NSString*)kMDQueryProgressNotification object:(id) mdQuery];
	[nf addObserver:self selector:@selector(finishedUpradeQuery:) name:(NSString*)kMDQueryDidFinishNotification object:(id) mdQuery];
	[nf addObserver:self selector:@selector(updatedUpradeQuery:) name:(NSString*)kMDQueryDidUpdateNotification object:(id) mdQuery];
	
	// Should I run this query on the network too? Difficult decision, as I think that this will slow stuff way down.
	// But i think it will only query leopard servers so perhaps ok
	//MDQuerySetSearchScope(mdQuery, (CFArrayRef)[NSArray arrayWithObjects:(NSString*)kMDQueryScopeComputer, (NSString*)kMDQueryScopeNetwork, nil], 0); // this is suitable for the way we run leaps, local only
	
	// start it
	BOOL queryRunning = MDQueryExecute(mdQuery, kMDQueryWantsUpdates); 
	if (!queryRunning)
	{
		CFRelease(mdQuery);
		mdQuery = nil;
		// leave this log message in...
		NSLog(@"MDQuery to upgrade open meta tags for snow leopard failed to start.");
		[pool release];
		return;
	}
		
	while (!gOMIsTerminating) // run till the end
	{
		NSAutoreleasePool *poolWhileLoop = [[NSAutoreleasePool alloc] init];
		[runLoop runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
		[poolWhileLoop release];
	}
	
	CFRelease(mdQuery);
	mdQuery = nil;
	[pool release];

}

@end

