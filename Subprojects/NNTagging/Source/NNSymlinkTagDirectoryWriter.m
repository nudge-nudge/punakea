//
//  NNSymlinkTagDirectoryWriter.m
//  NNTagging
//
//  Created by Johannes Hoffart on 26.03.09.
//  Copyright 2009 nudge:nudge. All rights reserved.
//

#import "NNSymlinkTagDirectoryWriter.h"

#import "lcl.h"

@implementation NNSymlinkTagDirectoryWriter

- (BOOL)createSymlinkToFile:(NNFile*)file inDirectory:(NSString*)directory
{
	BOOL success = YES;
	
	// check if symlink exists
	NSString *symlinkPath;
	
	BOOL exists = [fileManager symlinkExistsForFile:[file path]
										inDirectory:directory
											 atPath:&symlinkPath];
	
	if (!exists)
	{	
		NSError *error = nil;
		
		success = [fileManager createSymbolicLinkAtPath:symlinkPath 
									withDestinationPath:[file path] 
												  error:&error];
		
		if (!success) 
		{
			lcl_log(lcl_cnntagging, lcl_vError, @"Could not create symlink to %@: %@", file, error); 
		}
	}
	
	return success;
}

@end
