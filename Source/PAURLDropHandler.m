//
//  PAURLDropHandler.m
//  punakea
//
//  Created by Johannes Hoffart on 10.09.06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "PAURLDropHandler.h"


@implementation PAURLDropHandler

- (id)init
{
	if (self = [super init])
	{
		pboardType = [NSURLPboardType retain];
	}
	return self;
}

- (BOOL)handleDrop:(NSPasteboard*)pasteboard
{
	return NO;
}

- (NSArray*)contentFiles
{
	return nil;
}

- (NSImage*)iconForContent
{
	return nil;
}

@end
