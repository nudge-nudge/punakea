//
//  PALabel.m
//  punakea
//
//  Created by Daniel on 30.10.06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "PALabel.h"


@implementation PALabel

#pragma mark Init + Dealloc
- (id)initWithFrame:(NSRect)frameRect
{
	if(self = [super initWithFrame:frameRect])
	{
		// nothing yet
	}
	return self;
}

- (void)dealloc
{
	[super dealloc];
}

- (void)awakeFromNib
{
	[self setFont:[NSFont boldSystemFontOfSize:11]];
	[self setTextColor:[NSColor grayColor]];
}

@end
