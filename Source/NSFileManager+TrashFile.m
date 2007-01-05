//
//  NSFileManager+TrashFile.m
//  punakea
//
//  Created by Daniel on 02.10.06.
//  Copyright 2006 nudge:nudge. All rights reserved.
//

#import "NSFileManager+TrashFile.h"


@implementation NSFileManager (TrashFile)

- (BOOL)trashFileAtPath:(NSString *)path
{
	NSArray *files = [NSArray arrayWithObject:path];
	NSString *sourceDir = [path stringByDeletingLastPathComponent]; 
	NSString *trashDir = [NSHomeDirectory() stringByAppendingPathComponent:@".Trash"];
	int tag;

	return [[NSWorkspace sharedWorkspace] performFileOperation:NSWorkspaceRecycleOperation
								  source:sourceDir destination:trashDir files:files tag:&tag];
}

@end
