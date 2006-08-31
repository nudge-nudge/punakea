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
	[[self window] setFrameAutosaveName:@"punakea.browser"];
	
	BrowserViewController *browserViewController = [[BrowserViewController alloc] initWithNibName:@"BrowserView"];
	[[self window] setContentView:[browserViewController mainView]];
	
	// insert browserViewController in the responder chain
	//TODO put this into browserviewcontroller to enable independet usage
	[browserViewController setNextResponder:self];
	[[[self window] contentView] setNextResponder:browserViewController];
}

@end
