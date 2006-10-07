//
//  PADropHandler.m
//  punakea
//
//  Created by Johannes Hoffart on 08.09.06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "PADropHandler.h"


@implementation PADropHandler

- (void)dealloc
{
	[dataHandler release];
	[pboardType release];
	[super dealloc];
}

- (NSString*)pboardType
{
	return pboardType;
}

- (BOOL)willHandleDrop:(NSPasteboard*)pasteboard
{
	return NO;
}

- (NSArray*)handleDrop:(NSPasteboard*)pasteboard
{
	return nil;
}

- (NSDragOperation)performedDragOperation:(NSPasteboard*)pasteboard
{
	return NSDragOperationNone;
}

@end
