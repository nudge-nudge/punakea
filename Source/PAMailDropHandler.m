//
//  PAMailDropHandler.m
//  punakea
//
//  Created by Johannes Hoffart on 14.09.06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "PAMailDropHandler.h"


@implementation PAMailDropHandler

- (id)init
{
	if (self = [super init])
	{
		pboardType = [@"MV Super-secret message transfer pasteboard type" retain];
		dataHandler = [[PAMailDropDataHandler alloc] init];
	}
	return self;
}

- (BOOL)handleDrop:(NSPasteboard*)pasteboard
{
	NSArray *types = [pasteboard types];
	NSString *string = [pasteboard stringForType:pboardType];
	NSArray *droppedFiles = [pasteboard propertyListForType:pboardType];
	[self setContent:droppedFiles];
	
	if ([content count] > 0)
		return YES;
	else
		return NO;
}

- (NSArray*)contentFiles
{
	return [dataHandler fileDropDataObjects:content];
}

- (NSImage*)iconForContent
{
	if ([content count] > 1)
		return [[NSWorkspace sharedWorkspace] iconForFileType:NSPlainFileType];
	else
		return [[NSWorkspace sharedWorkspace] iconForFiles:content];
}

@end
