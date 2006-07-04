//
//  BrowserController.m
//  punakea
//
//  Created by Johannes Hoffart on 04.07.06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "BrowserController.h"


@implementation BrowserController

- (id)initWithWindowNibName:(NSString*)windowNibName tags:allTags
{
	if (self = [super initWithWindowNibName:windowNibName])
	{
		tags = allTags;
	}
	return self;
}

- (void)awakeFromNib
{
	BrowserViewController *browserViewController = [[BrowserViewController alloc] initWithNibName:@"BrowserView" tags:tags];
	[[self window] setContentView:[browserViewController view]];
}

@end
