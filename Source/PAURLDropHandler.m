//
//  PABookmarkDictionaryListDropHandler.m
//  punakea
//
//  Created by Johannes Hoffart on 10.09.06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "PABookmarkDictionaryListDropHandler.h"


@implementation PABookmarkDictionaryListDropHandler

- (id)init
{
	if (self = [super init])
	{
		[pboardTypes addObject:[@"BookmarkDictionaryListPboardType" retain]];
		dataHandler = [[PAURLDropDataHandler alloc] init];
	}
	return self;
}

- (BOOL)handleDrop:(NSPasteboard*)pasteboard
{
	NSURL *url = [[pasteboard propertyListForType:[pboardTypes objectAtIndex:0]] objectAtIndex:0];
	[self setContent:url];
	
	return YES;
}

- (NSArray*)contentFiles
{
	/*
	NSString *pathToFile = [dataHandler fileDropData:content];
	return [NSArray arrayWithObject:pathToFile];
	 */
	return nil;
}

- (NSImage*)iconForContent
{
	//TODO url image
	return [[NSWorkspace sharedWorkspace] iconForFileType:NSPlainFileType];
}

@end
