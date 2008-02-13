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
- (NNTaggableObject*)fileDropData:(id)data
{
	NNFile *file = [[NNFile alloc] initUsingSpotlightDBWithPath:data];
	return [file autorelease];
}

- (NSDragOperation)performedDragOperation
{
	if ([self shouldManageFiles])
		return NSDragOperationMove;
	else
		return NSDragOperationLink;
}

@end
