//
//  PAInstaller.m
//  punakea
//
//  Created by Johannes Hoffart on 22.05.07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "PAInstaller.h"

//#import "NNTagging/NNTagToFileWriter.h"
//#import "NNTagging/NNSecureTagToFileWriter.h"
//#import "NNTagging/NNTagToOpenMetaWriter.h"
//#import "NNTagging/NNFile.h"

@interface PAInstaller (PrivateAPI)

+ (void)removeOldWeblocImporter;
//+ (void)migrateSpotlightCommentsToOpenMeta;

@end

@implementation PAInstaller

+ (void)install
{
	// version 0.3 had a webloc importer installed in the user's library directory
	[PAInstaller removeOldWeblocImporter];
	//[PAInstaller copyWeblocImporter];
	
	// TODO check if upgrade to openmeta has already been done
	// check if Settings exist at default location
	
	// upgrade if needed - TODO make sure that no tag is accidently overwritten?
	// what happens when update was interrrupted? Best to store all the tag-file relations!
	
	// write Settings with OpenMetaWriter to disk
}

+ (void)removeOldWeblocImporter
{
	NSFileManager *fm = [NSFileManager defaultManager];
	
	NSString *targetPath = [@"~/Library/Spotlight/WeblocImporter.mdimporter" stringByExpandingTildeInPath];
	
	if ([fm fileExistsAtPath:targetPath])
	{
		[fm removeFileAtPath:targetPath handler:NULL];
		NSLog(@"cleaned up old WeblocImporter.mdimporter");
	}
}

// TODO this should give user feedback, right?
//- (void)migrateSpotlightCommentsToOpenMeta
//{
//	NNTagStoreManager *tagStoreManager = [NNTagStoreManager defaultManager];
//	
//	// get all old files 
//	NNSecureTagToFileWriter *oldTagToFileWriter = [[NNSecureTagToFileWriter alloc] init];
//	[tagStoreManager setTagPrefix:@"@"];
//	[tagStoreManager setTagToFileWriter:oldTagToFileWriter];
//	[oldTagToFileWriter release];
//	
//	NSArray *taggedFiles = [oldTagToFileWriter allTaggedObjects];
//	
//	// now all files are loaded, including their tags
//	// switch to new tagToOpenMetaWriter
//	NNTagToFileWriter *newTagToFileWriter = [[NNTagToOpenMetaWriter alloc] init];
//	[tagStoreManager setTagToFileWriter:newTagToFileWriter];
//	[newTagToFileWriter release];
//	
//	// now save all files using the new tagToFileWriter
//	// this writes all tags to the new storage and we're good
//	// to go!
//	for (NNFile *file in taggedFiles)
//	{
//		[file initiateSave];
//		
//		// clean up finder comments
//		NSString *finderCommentWithoutTags = [oldTagToFileWriter finderCommentIgnoringKeywordsForFile:file];
//		[oldTagToFileWriter setComment:finderCommentWithoutTags	forURL:[file url]];
//	}
//}

@end
