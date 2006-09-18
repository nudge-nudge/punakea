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
	NSArray *bookmarkDictionaries = [pasteboard propertyListForType:pboardType];
	NSDictionary *uriDictionary = [[bookmarkDictionaries objectAtIndex:0] objectForKey:@"URIDictionary"];
	
	if (uriDictionary)
	{
		[self setContent:bookmarkDictionaries];
		return YES;
	}
	else
	{
		return NO;
	}
}

- (NSArray*)contentFiles
{
	NSMutableArray *files = [NSMutableArray array];
	
	NSEnumerator *e = [content objectEnumerator];
	NSDictionary *uriDicitonary;
	
	while (uriDicitonary = [[e nextObject] objectForKey:@"URIDictionary"])
	{
		[files addObject:[dataHandler fileDropData:uriDicitonary]];
	}
	
	return files;
}

@end
