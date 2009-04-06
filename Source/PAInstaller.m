//
//  PAInstaller.m
//  punakea
//
//  Created by Johannes Hoffart on 22.05.07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "PAInstaller.h"

#import "NNTagging/NNTagToFileWriter.h"
#import "NNTagging/NNSecureTagToFileWriter.h"
#import "NNTagging/NNTagToOpenMetaWriter.h"
#import "NNTagging/NNFile.h"

@interface PAInstaller (PrivateAPI)

- (void)runInstallation;
- (void)removeOldWeblocImporter;
- (BOOL)migrationToOpenMetaIsNecessary;
- (void)migrateSpotlightCommentsToOpenMeta;
- (void)displayOpenMetaMigrationMessage;

@end

@implementation PAInstaller

+ (void)install
{
	PAInstaller *installer = [[PAInstaller alloc] init];
	[installer runInstallation];
	[installer release];
}

- (void)runInstallation
{
	// version 0.3 had a webloc importer installed in the user's library directory,
	// remove it
	[self removeOldWeblocImporter];
	
	// Punakea 1.0 switched to OpenMeta -> migrate
	if ([self migrationToOpenMetaIsNecessary])
	{
		//[self displayOpenMetaMigrationMessage];
	}
}

- (void)removeOldWeblocImporter
{
	NSFileManager *fm = [NSFileManager defaultManager];
	
	NSString *targetPath = [@"~/Library/Spotlight/WeblocImporter.mdimporter" stringByExpandingTildeInPath];
	
	if ([fm fileExistsAtPath:targetPath])
	{
		[fm removeFileAtPath:targetPath handler:NULL];
		NSLog(@"cleaned up old WeblocImporter.mdimporter");
	}
}

- (BOOL)migrationToOpenMetaIsNecessary
{
	BOOL necessary  = NO;
	
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	int currentVersion = [userDefaults integerForKey:@"Version"];
	
	// This will break if someone removes his preferences.plist ...
	// but actually this shouldn't matter, once the update is finished,
	// it doesn't matter if run again.
	if (currentVersion < 3)
	{
		necessary = YES;
	}
	
	return necessary;
}

- (void)displayOpenMetaMigrationMessage
{
	NSAlert *alert = [[[NSAlert alloc] init] autorelease];
	[alert setMessageText:NSLocalizedStringFromTable(@"OPEN_META_MIGRATION_MESSAGE",@"FileManager",@"")];
	[alert setInformativeText:NSLocalizedStringFromTable(@"OPEN_META_MIGRATION_MESSAGE_INFORMATIVE",@"FileManager",@"")];
	[alert addButtonWithTitle:NSLocalizedStringFromTable(@"OPEN_META_CONFIRM",@"FileManager",@"")];
	[alert addButtonWithTitle:NSLocalizedStringFromTable(@"OPEN_META_CANCEL",@"FileManager",@"")];
	
	[alert setAlertStyle:NSWarningAlertStyle];
	
	int button = [alert runModal];
	
	// check if upgrade shall procede
	if (button == NSAlertFirstButtonReturn)
	{
		[self migrateSpotlightCommentsToOpenMeta];
	}
	else
	{
		// quit Punakea -> update is MANDATORY
		[[NSApplication sharedApplication] terminate:self];
	}
}

- (void)migrateSpotlightCommentsToOpenMeta
{
	NNTagStoreManager *tagStoreManager = [NNTagStoreManager defaultManager];
	
	// get all old files 
	NNSecureTagToFileWriter *oldTagToFileWriter = [[NNSecureTagToFileWriter alloc] init];
	[tagStoreManager setTagPrefix:@"@"];
	[tagStoreManager setTagToFileWriter:oldTagToFileWriter];
	[oldTagToFileWriter release];
	
	NSArray *taggedFiles = [oldTagToFileWriter allTaggedObjects];
	
	// create a backup of all current assignments
	NNTagBackup *backup = [[NNTagBackup alloc] init];
	[backup createBackup];
	[backup release];
	
	// now all files are loaded, including their tags
	// switch to new tagToOpenMetaWriter
	NNTagToFileWriter *newTagToFileWriter = [[NNTagToOpenMetaWriter alloc] init];
	[tagStoreManager setTagToFileWriter:newTagToFileWriter];
	[newTagToFileWriter release];
	
	// now save all files using the new tagToFileWriter
	// this writes all tags to the new storage and we're good
	// to go!
	for (NNFile *file in taggedFiles)
	{
		[file initiateSave];
		
		// clean up finder comments
		NSString *finderCommentWithoutTags = [oldTagToFileWriter finderCommentIgnoringKeywordsForFile:file];
		[oldTagToFileWriter setComment:finderCommentWithoutTags	forURL:[file url]];
	}
	
	// once done, increment pref version so that the migration won't happen again
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	
	if ([userDefaults integerForKey:@"Version"] < 3)
	{
		[userDefaults setInteger:3 forKey:@"Version"];
	}
}

@end
