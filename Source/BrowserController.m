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
	if (self = [super initWithWindowNibName:@"Browser"])
	{
		// nothing
	}	
	return self;
}

- (void)awakeFromNib
{
	// this keeps the windowcontroller from auto-placing the window
	// - window is always opened where it was closed
	[self setShouldCascadeWindows:NO];
	
	[[self window] setFrameAutosaveName:@"punakea.browser"];
	
	browserViewController = [[BrowserViewController alloc] init];
	[horizontalSplitView replaceSubview:mainPlaceholderView with:[browserViewController view]];
	
	// insert browserViewController in the responder chain
	[browserViewController setNextResponder:[self window]];
	[[[self window] contentView] setNextResponder:browserViewController];
	
	// Setup status bar for source panel
	PASimpleStatusBarButton *sbitem = [PASimpleStatusBarButton statusBarButton];
	[sourcePanelStatusBar addItem:sbitem];
}

- (void)dealloc
{
	// unbind stuff for retain count
	[browserViewController release];
	[super dealloc];
}

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
