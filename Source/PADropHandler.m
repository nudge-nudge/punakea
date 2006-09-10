//
//  PADropHandler.m
//  punakea
//
//  Created by Johannes Hoffart on 08.09.06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "PADropHandler.h"


@implementation PADropHandler

- (id)init
{
	if (self = [super init])
	{
		pboardTypes = [[NSMutableArray alloc] init];
	}
	return self;
}

- (void)dealloc
{
	[content release];
	[dataHandler release];
	[pboardTypes release];
	[super dealloc];
}

- (NSArray*)pboardTypes
{
	return pboardTypes;
}

- (void)setContent:(id)aContent
{
	[aContent retain];
	[content release];
	content = aContent;
}

- (BOOL)handleDrop:(NSPasteboard*)pasteboard
{
	return NO;
}

- (NSImage*)iconForContent
{
	return [[NSWorkspace sharedWorkspace] iconForFileType:NSPlainFileType];
}

@end
