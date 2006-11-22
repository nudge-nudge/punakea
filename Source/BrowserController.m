//
//  BrowserController.m
//  punakea
//
//  Created by Johannes Hoffart on 04.07.06.
//  Copyright 2006 nudge:nudge. All rights reserved.
//

#import "BrowserController.h"


@implementation BrowserController

- (id)init
{
	self = [super initWithWindowNibName:@"Browser"];
	return self;
}

- (void)awakeFromNib
{
	[[self window] setFrameAutosaveName:@"punakea.browser"];
	
	browserViewController = [[BrowserViewController alloc] init];
	[[self window] setContentView:[browserViewController view]];
	
	// insert browserViewController in the responder chain
	[browserViewController setNextResponder:[self window]];
	[[[self window] contentView] setNextResponder:browserViewController];
}

- (void)dealloc
{
	// unbind stuff for retain count
	[browserViewController release];
	NSLog(@"bc dealloc");
	[super dealloc];
}

/*
- (BOOL)windowShouldClose:(id)sender
{
	[browserViewController reset];
	return YES;
}
*/

- (void)windowWillClose:(NSNotification *)aNotification
{
	[browserViewController unbindAll];
	[self autorelease];
}

- (BrowserViewController*)browserViewController
{
	return browserViewController;
}

@end
