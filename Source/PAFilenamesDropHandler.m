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
		[pboardTypes addObject:[NSFilenamesPboardType retain]];
		dataHandler = [[PAFilenamesDropDataHandler alloc] init];
	}
	return self;
}

- (BOOL)handleDrop:(NSPasteboard*)pasteboard
{
	NSArray *droppedFiles = [pasteboard propertyListForType:[pboardTypes objectAtIndex:0]];
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
