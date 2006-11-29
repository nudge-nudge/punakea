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
	PAFile *file = [PAFile fileWithPath:path];

	NSArray *files = [NSArray arrayWithObject:[file name]];
	NSString *sourceDir = [file directory]; 
	NSString *trashDir = [NSHomeDirectory() stringByAppendingPathComponent:@".Trash"];
	int tag;

	return [[NSWorkspace sharedWorkspace] performFileOperation:NSWorkspaceRecycleOperation
								  source:sourceDir destination:trashDir files:files tag:&tag];
}

@end
