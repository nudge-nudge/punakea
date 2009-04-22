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
	if (([[NSFileManager defaultManager] fileExistsAtPath:data])
		&& [[NSFileManager defaultManager] isReadableFileAtPath:data])
	{	
		NNFile *file = [[NNFile alloc] initWithPath:data];
		return [file autorelease];
	}
	else
	{
		// TODO - logging
		return nil;
	}
}

- (NSDragOperation)performedDragOperation
{
	if ([self shouldManageFiles])
		return NSDragOperationMove;
	else
		return NSDragOperationLink;
}

@end
