//
//  PAInstaller.m
//  punakea
//
//  Created by Johannes Hoffart on 22.05.07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "PAInstaller.h"

@interface PAInstaller (PrivateAPI)

+ (void)removeOldWeblocImporter;

@end

@implementation PAInstaller

+ (void)install
{
	// version 0.3 had a webloc importer installed in the user's library directory
	[PAInstaller removeOldWeblocImporter];
	//[PAInstaller copyWeblocImporter];
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

// not used at the moment
//+ (void)copyWeblocImporter
//{
//	NSFileManager *fm = [NSFileManager defaultManager];
//	
//	// get path of webloc importer bundle
//	NSString *importerPath = [NSBundle pathForResource:@"WeblocImporter"
//												ofType:@"mdimporter"
//										   inDirectory:[[NSBundle mainBundle] builtInPlugInsPath]];
//	
//	NSString *targetPath = [@"~/Library/Spotlight" stringByExpandingTildeInPath];
//	BOOL isDirectory;
//	
//	// create dir if it does not exits
//	if (![fm fileExistsAtPath:targetPath isDirectory:&isDirectory])
//	{
//		[fm createDirectoryAtPath:targetPath attributes:nil];
//	}
//	else if (!isDirectory)
//	{
//		NSLog(@"critical error: Please make sure that '%@' is a directory",targetPath);
//		return;
//	}
//
//	// targetPath is now a directory
//	NSString *target = [targetPath stringByAppendingPathComponent:[importerPath lastPathComponent]];
//	
//	if ([fm fileExistsAtPath:target])
//	{
//		// check creation date
//		NSDictionary *targetAttribute = [fm fileAttributesAtPath:target traverseLink:NO];
//		NSDate *targetCreation = [targetAttribute objectForKey:NSFileCreationDate];
//		
//		NSDictionary *sourceAttribute = [fm fileAttributesAtPath:importerPath traverseLink:NO];
//		NSDate *sourceCreation = [sourceAttribute objectForKey:NSFileCreationDate];
//		
//		if ([targetCreation compare:sourceCreation] == NSOrderedAscending)
//		{
//			[fm removeFileAtPath:target handler:NULL];
//			[fm copyPath:importerPath toPath:target handler:NULL];	
//		}			
//	}
//	else
//	{
//		[fm copyPath:importerPath toPath:target handler:NULL];	
//	}
//}

@end
