//
//  NNTagBackup.m
//  NNTagging
//
//  Created by Johannes Hoffart on 27.03.09.
//  Copyright 2009 nudge:nudge. All rights reserved.
//

#import "NNTagBackup.h"

#import "lcl.h"

NSString * const nntaggingApplicationSupport = @"~/Library/Application Support/NNTagging/";

@implementation NNTagBackup

+ (BOOL)createBackup
{
	BOOL success = YES;
	
	NSMutableDictionary *backup = [NSMutableDictionary dictionary];

	NNTagToFileWriter *tagToFileWriter = [[NNTagStoreManager defaultManager] tagToFileWriter];
	NSArray *allTaggedObjects = [tagToFileWriter allTaggedObjects];

	// at the moment, this will only backup tagged files
	// and NNSimpleTags
	for (NNTaggableObject *taggedObject in allTaggedObjects)
	{
		if ([taggedObject isKindOfClass:[NNFile class]])
		{
			NNFile *taggedFile = (NNFile*) taggedObject;
			
			NSString *filePath = [taggedFile path];
			
			NSArray *tags = [[taggedFile tags] allObjects];
			NSMutableArray *tagNames = [NSMutableArray array];
			
			for (NNTag *tag in tags)
			{
				[tagNames addObject:[tag name]];
			}
			
			// backup uses filepath:tag_1,tag_2 layout
			[backup setObject:tagNames forKey:filePath];
		}
	}

	// write backup as plist to the application support of the famework
	NSString *tagBackupFolder = [nntaggingApplicationSupport stringByExpandingTildeInPath];
	
	if (![[NSFileManager defaultManager] fileExistsAtPath:tagBackupFolder])
	{
		[[NSFileManager defaultManager] createDirectoryAtPath:tagBackupFolder attributes:nil];
	}
	
	// filename contains date of creation
	NSCalendar *currentCalendar = [NSCalendar currentCalendar];
	NSUInteger unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
	NSDateComponents *components = [currentCalendar components:unitFlags fromDate:[NSDate date]];
	NSString *filename = [NSMutableString stringWithFormat:@"tags_backup_%lx%lx%lx-%lx%lx%lx.plist",
						  [components year],
						  [components month],
						  [components day],
						  [components hour],
						  [components minute],
						  [components second]];
		
	NSString *pathToBackup = [tagBackupFolder stringByAppendingPathComponent:filename];
		
	if (![[NSFileManager defaultManager] fileExistsAtPath:pathToBackup])
	{
		success = [backup writeToFile:pathToBackup atomically:YES];
	}

	return success;
}

+ (void)restoreFromBackup
{
	NSString *tagBackupFolder = [nntaggingApplicationSupport stringByExpandingTildeInPath];

	NSFileManager *fm = [NSFileManager defaultManager];
	
	NSError *error;
	
	NSArray *backupFiles = [fm contentsOfDirectoryAtPath:tagBackupFolder error:&error];
	
	if (error != nil)
	{
		NSDate *mostRecent = [NSDate distantPast];
		NSString *mostRecentBackup;
		
		// find most recent backup
		for (NSString* entry in backupFiles)
		{
			BOOL isDir;
			
			entry = [tagBackupFolder stringByAppendingPathComponent:entry];
			
			if ([fm fileExistsAtPath:entry isDirectory:&isDir])
			{
				if (!isDir)
				{
					NSDictionary *attributes = [fm attributesOfItemAtPath:entry error:&error];
					
					if (error != nil)
					{
						NSDate *creationDate = [attributes objectForKey:NSFileCreationDate];
						
						if ([creationDate timeIntervalSinceDate:mostRecent] >= 0)
						{
							mostRecent = creationDate;
							mostRecentBackup = entry;
						}
					}
					else
					{
						lcl_log(lcl_cnntagging,lcl_vError,@"Could not access attributes of file at path '%@'",entry);
					}
				}
			}
		}
		
		// mostRecentBackup is now set to the last available backup
		NSDictionary *backup = [NSDictionary dictionaryWithContentsOfFile:mostRecentBackup];
		
		NSArray *taggedFiles = [backup allKeys];
		
		for (NSString *taggedFile in taggedFiles)
		{
			NSArray *tags = [[NNTags sharedTags] tagsForNames:[backup objectForKey:taggedFile]];
			
			NNFile *file = [NNFile fileWithPath:taggedFile];
			[file addTags:tags];
			
			lcl_log(lcl_cnntagging,lcl_vInfo,@"Restored tags on '%@': %@",taggedFile,tags);
		}			
	}
	else
	{
		lcl_log(lcl_cnntagging,lcl_vError,@"Could not find any tag backups at @%",tagBackupFolder);
		
	}
}

@end
