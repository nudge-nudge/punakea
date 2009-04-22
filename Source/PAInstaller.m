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
	PAInstaller *installer = [[PAInstaller alloc] initWithWindowNibName:@"Installer"];
	[installer release];
}

- (id)initWithWindowNibName:(NSString *)windowNibName
{
	if (self = [super initWithWindowNibName:windowNibName])
	{
		// Reference the window once to enforce loading of the Nib
		[self window];
	}
	return self;
}

- (void)awakeFromNib
{
	[self runInstallation];
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
	BOOL necessary  = NO;
	
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	int currentVersion = [userDefaults integerForKey:@"Version"];
	
	// This will only update if the preferences contain version 2 (TODO discuss with Daniel if this is allright -> what to do
	// on the next update when we store the version in the UserDefaults.plist?)
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
	[openMetaMigrationWindow center];
	[[NSApplication sharedApplication] runModalForWindow:openMetaMigrationWindow];
}

- (IBAction)stopModal:(id)sender
{
	[[NSApplication sharedApplication] stopModal];
}

- (IBAction)terminate:(id)sender
{
	[[NSApplication sharedApplication] terminate:self];
}

- (IBAction)migrateSpotlightCommentsToOpenMeta:(id)sender
{
	[openMetaProgressIndicator setIndeterminate:YES];
	[openMetaProgressIndicator startAnimation:self];

	NNTagStoreManager *tagStoreManager = [NNTagStoreManager defaultManager];

	// get all old files 
	NNSecureTagToFileWriter *oldTagToFileWriter = [[NNSecureTagToFileWriter alloc] init];
	[tagStoreManager setTagPrefix:@"@"];
	[tagStoreManager setTagToFileWriter:oldTagToFileWriter];
	
	// create a backup of all current assignments
	[NNTagBackup createBackup];
	
	NSArray *taggedFiles = [oldTagToFileWriter allTaggedObjects];	
	
	// now all files are loaded, including their tags
	// switch to new tagToOpenMetaWriter
	NNTagToFileWriter *newTagToFileWriter = [[NNTagToOpenMetaWriter alloc] init];
	[tagStoreManager setTagToFileWriter:newTagToFileWriter];

//	// now save all files using the new tagToFileWriter
//	// this writes all tags to the new storage and we're good
//	// to go!
//	for (NNFile *file in taggedFiles)
//	{
//		//NSLog(@"Writing %@: %@",file,[file tags]);
//		
//		[file initiateSave];
//		
//		// clean up finder comments
//		NSString *finderCommentWithoutTags = [oldTagToFileWriter finderCommentIgnoringKeywordsForFile:file];
//		[oldTagToFileWriter setComment:finderCommentWithoutTags	forURL:[file url]];
//	}
//	
//	// once done, increment pref version so that the migration won't happen again
//	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
//	
//	if ([userDefaults integerForKey:@"Version"] < 3)
//	{
//		[userDefaults setInteger:3 forKey:@"Version"];
//	}

	[oldTagToFileWriter release];
	[newTagToFileWriter release];

	[self stopModal:self];
}

@end
