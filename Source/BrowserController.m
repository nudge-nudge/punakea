//
//  BrowserController.m
//  punakea
//
//  Created by Johannes Hoffart on 04.07.06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "BrowserController.h"


@implementation BrowserController

- (void)awakeFromNib
{
	BrowserViewController *browserViewController = [[BrowserViewController alloc] initWithNibName:@"BrowserView"];
	[[self window] setContentView:[browserViewController mainView]];
	
	//insert browserViewController in the responder chain
	[browserViewController setNextResponder:self];
	[[[self window] contentView] setNextResponder:browserViewController];
}

@end
