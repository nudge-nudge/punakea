//
//  PAThumbnailItem.m
//  punakea
//
//  Created by Daniel on 31.08.06.
//  Copyright 2006 nudge:nudge. All rights reserved.
//

#import "PAThumbnailItem.h"


@implementation PAThumbnailItem

#pragma mark Init + Dealloc
- (id)initForFile:(NSString *)path inView:(NSView *)aView frame:(NSRect)aFrame type:(PAThumbnailItemType)itemType
{
	self = [super init];
	if(self)
	{
		filename = [path retain];
		view = [aView retain];
		frame = aFrame;
		type = itemType;
	}
	return self;
}

- (void)dealloc
{
	[view release];
	[filename release];
	[super dealloc];
}


#pragma mark Accessors
- (NSString *)filename
{
	return filename;
}

- (NSView *)view
{
	return view;
}

- (NSRect)frame
{
	return frame;
}

- (PAThumbnailItemType)type
{
	return type;
}

@end
