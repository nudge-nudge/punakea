//
//  PAThumbnailItem.m
//  punakea
//
//  Created by Daniel on 31.08.06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "PAThumbnailItem.h"


@implementation PAThumbnailItem

#pragma mark Init + Dealloc
- (id)initForFile:(NSString *)path inView:(NSView *)aView frame:(NSRect)aFrame
{
	self = [super init];
	if(self)
	{
		filename = path;
		view = aView;
		frame = aFrame;
	}
	return self;
}

- (void)dealloc
{
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

@end
