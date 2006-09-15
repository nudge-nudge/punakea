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

- (BOOL)handleDrop:(NSPasteboard*)pasteboard
{
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

@end
