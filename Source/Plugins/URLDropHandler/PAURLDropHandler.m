//
//  PABookmarkDictionaryListDropHandler.m
//  punakea
//
//  Created by Johannes Hoffart on 10.09.06.
//  Copyright 2006 nudge:nudge. All rights reserved.
//

#import "PAURLDropHandler.h"


@implementation PAURLDropHandler

- (id)init
{
	if (self = [super init])
	{
		pboardType = [@"WebURLsWithTitlesPboardType" retain];
		dataHandler = [[PAURLDropDataHandler alloc] init];
	}
	return self;
}

- (BOOL)willHandleDrop:(NSPasteboard*)pasteboard
{
	NSArray *WebURLsWithTitlesPboardTypeArray = [pasteboard propertyListForType:pboardType];
	
	if ([WebURLsWithTitlesPboardTypeArray count] == 2)
		return YES;
	else
		return NO;
}

- (NSArray*)handleDrop:(NSPasteboard*)pasteboard
{
	NSArray *WebURLsWithTitlesPboardTypeArray = [pasteboard propertyListForType:pboardType];
	NSArray *urls = [WebURLsWithTitlesPboardTypeArray objectAtIndex:0];
	NSArray *titles = [WebURLsWithTitlesPboardTypeArray objectAtIndex:1];
	
	NSMutableArray *files = [NSMutableArray array];
	
	for (int i=0;i<[urls count];i++)
	{
		NSString *url = [urls objectAtIndex:i];
		NSString *title = [titles objectAtIndex:i];
		
		NSString *urlDictionary = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:url,title,nil]
															  forKeys:[NSArray arrayWithObjects:@"url",@"title",nil]];
		
		[files addObject:[dataHandler fileDropData:urlDictionary]];
	}
		
	return files;
}

- (NSDragOperation)performedDragOperation:(NSPasteboard*)pasteboard
{
	if ([self willHandleDrop:pasteboard])
		return [dataHandler performedDragOperation];
	else
		return NSDragOperationNone;
}

@end
