//
//  PAFilenamesDropHandler.m
//  punakea
//
//  Created by Johannes Hoffart on 08.09.06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "PAFilenamesDropHandler.h"


@implementation PAFilenamesDropHandler

- (id)init
{
	if (self = [super init])
	{
		pboardType = [NSFilenamesPboardType retain];
		dataHandler = [[PAFilenamesDropDataHandler alloc] init];
	}
	return self;
}

- (BOOL)willHandleDrop:(NSPasteboard*)pasteboard
{
	NSArray *droppedFiles = [pasteboard propertyListForType:pboardType];
	
	if ([droppedFiles count] > 0)
		return YES;
	else
		return NO;
}

- (NSArray*)handleDrop:(NSPasteboard*)pasteboard
{
	if ([self willHandleDrop:pasteboard])
	{
		NSArray *droppedFiles = [pasteboard propertyListForType:pboardType];
		return [dataHandler fileDropDataObjects:droppedFiles];
	}
	else
	{
		return [NSArray array];
	}
}

- (NSDragOperation)performedDragOperation:(NSPasteboard*)pasteboard
{
	if ([self willHandleDrop:pasteboard])
		return [dataHandler performedDragOperation];
	else
		return NSDragOperationNone;
}

@end
