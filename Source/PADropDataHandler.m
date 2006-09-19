//
//  PAFileHandler.m
//  punakea
//
//  Created by Johannes Hoffart on 10.09.06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "PADropDataHandler.h"


@implementation PADropDataHandler

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
- (NSArray*)fileDropDataObjects:(NSArray*)dataObjects
{
	NSEnumerator *e = [dataObjects objectEnumerator];
	id data;
	
	NSMutableArray *newFiles = [NSMutableArray array];
	
	while (data = [e nextObject])
	{
		[newFiles addObject:[self fileDropData:data]];
	}
	
	return newFiles;
}

- (PAFile*)destinationForNewFile:(NSString*)fileName
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
	
	return [PAFile fileWithPath:newDestination];
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
