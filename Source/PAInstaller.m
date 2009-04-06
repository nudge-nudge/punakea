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
		[self displayOpenMetaMigrationMessage];
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
	// TODO check if preferences version <= 2 (corresponds to Punakea version <= 0.4.1)
	BOOL necessary  = NO;
	
	if (necessary)
	{
		// TODO increment preferences
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
		//  migrate comments to OpenMeta
		//	BusyWindowController *busyWindowController = [busyWindow delegate];
		//	
		//	[busyWindowController setMessage:NSLocalizedStringFromTable(@"BUSY_WINDOW_MESSAGE_REBUILDING_TAGS_FOLDER", @"FileManager", nil)];
		//	[busyWindowController performBusySelector:@selector(createDirectoryStructure)
		//									 onObject:[NNTagging tagging]];
		//	
		//	[busyWindow center];
		//	[NSApp runModalForWindow:busyWindow];
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
}

@end
