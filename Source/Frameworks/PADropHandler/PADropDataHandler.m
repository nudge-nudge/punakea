//
//  PAFileHandler.m
//  punakea
//
//  Created by Johannes Hoffart on 10.09.06.
//  Copyright 2006 nudge:nudge. All rights reserved.
//

#import "PADropDataHandler.h"

@interface PADropDataHandler (PrivateAPI)

- (NSString*)pathForFiles;
- (BOOL)pathIsInManagedHierarchy:(NSString*)path;

@end

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
- (NSString*)fileDropData:(id)data
{
	return nil;
}

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

- (NSDragOperation)performedDragOperation
{
	return NSDragOperationNone;
}

- (NSString*)destinationForNewFile:(NSString*)fileName
{
	// check if main directory folder contains file
	// increment until directory is found/created where file can be place
	NSString *managedRoot = [self pathForFiles];
	NSString *destination;
	int i = 1;

	while (true)
	{
		NSString *directory = [managedRoot stringByAppendingFormat:@"/%i/",i];
		
		if ([fileManager fileExistsAtPath:directory] == NO) 
			[fileManager createDirectoryAtPath:directory attributes:nil];
		
		destination = [directory stringByAppendingPathComponent:fileName];
		
		// if file doesn't exists in directory, use this one
		if (![fileManager fileExistsAtPath:destination])
			break;
		
		i++;
	}
	
	return destination;
}

- (NSString*)pathForFiles
{ 
	NSString *directory = [[NSUserDefaults standardUserDefaults] objectForKey:@"General.ManagedFilesLocation"];
	directory = [directory stringByExpandingTildeInPath]; 
	
	if ([fileManager fileExistsAtPath:directory] == NO) 
		[fileManager createDirectoryAtPath:directory attributes: nil];
	
	return directory; 
}

- (BOOL)pathIsInManagedHierarchy:(NSString*)path
{
	NSString *managedRoot = [self pathForFiles];
	return [path hasPrefix:managedRoot];
}

@end
