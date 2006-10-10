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
	if (!manageFiles || [self pathIsInManagedHierarchy:data])
	{
		return [PAFile fileWithPath:data];
	}
	else
	{
		NSString *destination = [self destinationForNewFile:[data lastPathComponent]];
		[fileManager movePath:data toPath:destination handler:self];
		return [PAFile fileWithPath:destination];
	}
}

- (NSDragOperation)performedDragOperation
{
	if (manageFiles)
		return NSDragOperationMove;
	else
		return NSDragOperationGeneric;
}

@end
