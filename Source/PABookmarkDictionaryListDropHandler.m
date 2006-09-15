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
	
	if (uriDictionary)
	{
		[self setContent:uriDictionary];
		return YES;
	}
	else
	{
		return NO;
	}
}

- (NSArray*)contentFiles
{
	PAFile *file = [dataHandler fileDropData:content];
	return [NSArray arrayWithObject:file];
}

@end
