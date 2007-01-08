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
- (BOOL)shouldManageFiles;

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
- (PATaggableObject*)fileDropData:(id)data
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


@end
