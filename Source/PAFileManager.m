//
//  PAFileManager.m
//  punakea
//
//  Created by Johannes Hoffart on 04.09.06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "PAFileManager.h"

@interface PAFileManager (PrivateAPI)

- (NSString*)destinationForNewFile:(NSString*)fileName;
- (NSString *)pathForFiles;

@end

@implementation PAFileManager

- (id)init
{
	if (self = [super init])
	{
		[self bind:@"manageFiles" 
		  toObject:[NSUserDefaultsController sharedUserDefaultsController] 
	   withKeyPath:@"values.General.ManageFiles" 
		   options:nil];
		
		fileManager = [NSFileManager defaultManager];
	}
	return self;
}

- (void)dealloc
{
	[super dealloc];
}

#pragma mark main methods
- (NSString*)handleFile:(NSString*)filePath
{
	// only do something if managing files and if file not already in the managed file directory
	if (!manageFiles || ([[filePath stringByDeletingLastPathComponent] isEqualToString:[self pathForFiles]]))
	{
		return filePath;
	}
	
	NSString *newPath = [self destinationForNewFile:[filePath lastPathComponent]];
	[fileManager movePath:filePath toPath:newPath handler:self];
	return newPath;
}

- (NSArray*)handleFiles:(NSArray*)filePaths
{
	NSEnumerator *e = [filePaths objectEnumerator];
	NSString *filePath;
	
	NSMutableArray *newPaths = [NSMutableArray array];
	
	while (filePath = [e nextObject])
	{
		[newPaths addObject:[self handleFile:filePath]];
	}
	
	return newPaths;
}

- (NSString*)destinationForNewFile:(NSString*)fileName
{
	NSString *newDestination = [[self pathForFiles] stringByAppendingPathComponent:fileName];
	
	int idx = 1;
	NSString *suffix = [NSString stringWithFormat:@"-%i",idx];
	
	if ([fileManager fileExistsAtPath:newDestination])
	{
		NSString *name = [fileName stringByDeletingPathExtension];
		NSString *newName = [name stringByAppendingString:suffix];
		NSString *extension = [@"." stringByAppendingString:[fileName pathExtension]];
		NSString *newFileName = [newName stringByAppendingString:extension];
		newDestination = [[self pathForFiles] stringByAppendingPathComponent:newFileName];
	}
		

	while ([fileManager fileExistsAtPath:newDestination])
	{
		idx++;
		NSString *suffix = [NSString stringWithFormat:@"-%i",idx];
		
		//TODO delete -i!!
		NSString *name = [fileName stringByDeletingPathExtension];
		NSString *newName = [name stringByAppendingString:suffix];
		NSString *extension = [@"." stringByAppendingString:[fileName pathExtension]];
		NSString *newFileName = [newName stringByAppendingString:extension];
		newDestination = [[self pathForFiles] stringByAppendingPathComponent:newFileName];
	}
		
	return newDestination;
}

- (NSString*)pathForFiles
{ 
	NSString *folder = @"~/Library/Application Support/Punakea/managedFiles/"; 
	folder = [folder stringByExpandingTildeInPath]; 
	
	if ([fileManager fileExistsAtPath: folder] == NO) 
		[fileManager createDirectoryAtPath: folder attributes: nil];
	
	return folder; 
}

#pragma mark filemanager methods
- (void)fileManager:(NSFileManager *)manager willProcessPath:(NSString *)path
{

}

- (BOOL)fileManager:(NSFileManager *)manager shouldProceedAfterError:(NSDictionary *)errorInfo
{
	return NO;
}

@end
