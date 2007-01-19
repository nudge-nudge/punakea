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

@end

@implementation PADropDataHandler

- (id)init
{
	if (self = [super init])
	{
		fileManager = [NSFileManager defaultManager];
	}
	return self;
}

- (void)dealloc
{
	[super dealloc];
}

#pragma mark main methods
- (NNTaggableObject*)fileDropData:(id)data
{
	return nil;
}

- (NSArray*)fileDropDataObjects:(NSArray*)dataObjects
{
	NSEnumerator *e = [dataObjects objectEnumerator];
	id data;
	
	NSMutableArray *newObjects = [NSMutableArray array];
	
	while (data = [e nextObject])
	{
		[newObjects addObject:[self fileDropData:data]];
	}
	
	return newObjects;
}

- (NSDragOperation)performedDragOperation
{
	return NSDragOperationNone;
}

- (BOOL)shouldManageFiles
{
	// only manage if there are some tags on the file
	return [[NSUserDefaults standardUserDefaults] boolForKey:@"General.ManageFiles"];
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


@end
