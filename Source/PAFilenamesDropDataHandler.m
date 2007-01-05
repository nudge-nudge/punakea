//
//  PAFilenamesDropDataHandler.m
//  punakea
//
//  Created by Johannes Hoffart on 10.09.06.
//  Copyright 2006 nudge:nudge. All rights reserved.
//

#import "PAFilenamesDropDataHandler.h"


@implementation PAFilenamesDropDataHandler

// data is NSString (filepath)
- (PATaggableObject*)fileDropData:(id)data
{
	return [PAFile fileWithPath:data];
}

- (NSDragOperation)performedDragOperation
{
	if ([self shouldManageFiles])
		return NSDragOperationMove;
	else
		return NSDragOperationGeneric;
}

@end
