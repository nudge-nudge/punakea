//
//  PADropHandler.m
//  punakea
//
//  Created by Johannes Hoffart on 08.09.06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "PADropHandler.h"


@implementation PADropHandler

- (void)dealloc
{
	[content release];
	[dataHandler release];
	[pboardType release];
	[super dealloc];
}

- (NSString*)pboardType
{
	return pboardType;
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

@end
