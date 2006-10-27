//
//  PATaggerTableView.m
//  punakea
//
//  Created by Daniel on 27.10.06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "PATaggerTableView.h"


@implementation PATaggerTableView

#pragma mark Init + Dealloc
- (id)initWithFrame:(NSRect)frameRect
{
	self = [super initWithFrame:frameRect];
	if(self)
	{
		// nothing yet
	}	
	return self;
}

- (void)dealloc
{
	[super dealloc];
}


#pragma mark Live Resizing
- (BOOL) _wantsLiveResizeToUseCachedImage;
{
    return NO;
}

- (BOOL) _shouldLiveResizeUseCachedImage;
{
    return NO;
}

@end
