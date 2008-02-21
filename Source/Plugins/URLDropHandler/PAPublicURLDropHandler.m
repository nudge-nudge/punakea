//
//  PAPublicUrlDropHandler.m
//  punakea
//
//  Created by Johannes Hoffart on 20.02.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "PAPublicURLDropHandler.h"


@implementation PAPublicURLDropHandler

- (id)init
{
	if (self = [super init])
	{
		pboardType = [@"public.url" retain];
		dataHandler = [[PAURLDropDataHandler alloc] init];
	}
	return self;
}

- (BOOL)willHandleDrop:(NSPasteboard*)pasteboard
{
	// check for url	
	NSString *url = [pasteboard stringForType:pboardType];
	
	// ignore files
	if (url && ![pasteboard propertyListForType:NSFilenamesPboardType])
		return YES;
	else
		return NO;
}

- (NSArray*)handleDrop:(NSPasteboard*)pasteboard
{
	NSString *url = [pasteboard stringForType:pboardType];
	NSString *urlTitle = [pasteboard stringForType:@"public.url-name"];
		
	NSDictionary *urlDictionary = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:url,urlTitle,nil]
																  forKeys:[NSArray arrayWithObjects:@"url",@"title",nil]];
		
	return [NSArray arrayWithObject:[dataHandler fileDropData:urlDictionary]];
}

- (NSDragOperation)performedDragOperation:(NSPasteboard*)pasteboard
{
	if ([self willHandleDrop:pasteboard])
		return [dataHandler performedDragOperation];
	else
		return NSDragOperationNone;
}

@end
