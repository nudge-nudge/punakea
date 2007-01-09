//
//  PAMZDropHandler.m
//  punakea
//
//  Created by Johannes Hoffart on 09.01.07.
//  Copyright 2007 nudge:nudge. All rights reserved.
//

#import "PAMZDropHandler.h"

@implementation PAMZDropHandler

- (id)init
{
	if (self = [super init])
	{
		pboardType = [@"MOZm" retain];
		dataHandler = [[PAURLDropDataHandler alloc] init];
	}
	return self;
}

- (BOOL)willHandleDrop:(NSPasteboard*)pasteboard
{
	NSLog(@"CALLED");
	
	NSArray *MZPboardTypeArray = [pasteboard propertyListForType:pboardType];
	
	if (MZPboardTypeArray && [MZPboardTypeArray count] == 2)
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
		
		NSDictionary *urlDictionary = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:url,title,nil]
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
