//
//  PAFilenamesDropDataHandler.m
//  punakea
//
//  Created by Johannes Hoffart on 10.09.06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "PAFilenamesDropDataHandler.h"


@implementation PAFilenamesDropDataHandler

// data is NSString (filepath)
- (PAFile*)fileDropData:(id)data
{
	// only do something if managing files and if file not already in the managed file directory
	if (!manageFiles || ([[data stringByDeletingLastPathComponent] isEqualToString:[self pathForFiles]]))
	{
		return [PAFile fileWithPath:data];
	}

	NSString *newPath = [self destinationForNewFile:[data lastPathComponent]];
	[fileManager movePath:data toPath:newPath handler:self];
	return [PAFile fileWithPath:newPath];
}

@end
