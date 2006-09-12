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
		pboardType = [@"BookmarkDictionaryListPboardType" retain];
		dataHandler = [[PAURLDropDataHandler alloc] init];
	}
	return self;
}

- (BOOL)handleDrop:(NSPasteboard*)pasteboard
{
	NSDictionary *bookmarkDictionary = [[pasteboard propertyListForType:pboardType] objectAtIndex:0];
	NSDictionary *uriDictionary = [bookmarkDictionary objectForKey:@"URIDictionary"];
	[self setContent:uriDictionary];
	
	return YES;
}

- (NSArray*)contentFiles
{
	NSString *pathToFile = [dataHandler fileDropData:content];
	return [NSArray arrayWithObject:pathToFile];
}

- (NSImage*)iconForContent
{
	//TODO url image
	return [[NSWorkspace sharedWorkspace] iconForFileType:NSPlainFileType];
}

@end
