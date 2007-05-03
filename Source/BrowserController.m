//
//  BrowserController.m
//  punakea
//
//  Created by Johannes Hoffart on 04.07.06.
//  Copyright 2006 nudge:nudge. All rights reserved.
//

#import "BrowserController.h"

@implementation BrowserController

#pragma mark Init + Dealloc
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
	[verticalSplitView replaceSubview:mainPlaceholderView with:[browserViewController view]];
	
	// insert browserViewController in the responder chain
	[browserViewController setNextResponder:[self window]];
	[[[self window] contentView] setNextResponder:browserViewController];
	
	// Setup status bar for source panel
	PAStatusBarButton *sbitem = [PAStatusBarButton statusBarButton];
	[sbitem setToolTip:@"Add tag set"];
	[sbitem setImage:[NSImage imageNamed:@"statusbar-button-plus"]];
	[sbitem setAlternateImage:[NSImage imageNamed:@"statusbar-button-gear"]];
	[sbitem setAction:@selector(addTagSet:)];
	[sourcePanelStatusBar addItem:sbitem];
	
	sbitem = [PAStatusBarButton statusBarButton];
	[sbitem setButtonType:NSToggleButton];
	[sbitem setImage:[NSImage imageNamed:@"statusbar-button-info"]];
	[sbitem setAlternateImage:[NSImage imageNamed:@"statusbar-button-gear"]];
	[sourcePanelStatusBar addItem:sbitem];
}

- (void)dealloc
{
	// unbind stuff for retain count
	[browserViewController release];
	[super dealloc];
}


#pragma mark Events
- (void)flagsChanged:(NSEvent *)theEvent
{
	if ([theEvent modifierFlags] & NSAlternateKeyMask) {
		[sourcePanelStatusBar setAlternateState:YES];
	} else {
		[sourcePanelStatusBar setAlternateState:NO];
	}
}


#pragma mark Actions
- (IBAction)confirmSheet:(id)sender
{
	NSWindow *theSheet = [sender window];
	
	[NSApp endSheet:theSheet returnCode:NSOKButton];
	[theSheet orderOut:nil];
}

- (IBAction)cancelSheet:(id)sender
{
	NSWindow *theSheet = [sender window];
	
	[NSApp endSheet:theSheet returnCode:NSCancelButton];
	[theSheet orderOut:nil];
}

- (void)tagSetPanelDidEnd:(PATagSetPanel *)panel returnCode:(int)returnCode contextInfo:(void *)contextInfo
{
	if (returnCode == NSOKButton)
		NSLog(@"jau");
}

- (void)addTagSet:(id)sender
{
	[NSApp beginSheet:editTagSetSheet
	   modalForWindow:[sender window]
		modalDelegate:self
	   didEndSelector:@selector(tagSetPanelDidEnd:returnCode:contextInfo:)
		  contextInfo:NULL];
}


#pragma mark SplitView Delegate
- (float)splitView:(NSSplitView *)sender constrainMinCoordinate:(float)proposedMin ofSubviewAt:(int)offset
{
	if([sender isEqualTo:verticalSplitView])
	{
		// left subview
		if(offset == 0) return 120.0;
	}
	else
	{
		// bottom subview
		if(offset == 1) return 120.0;
	}
	
	return nil;
}

- (float)splitView:(NSSplitView *)sender constrainMaxCoordinate:(float)proposedMin ofSubviewAt:(int)offset
{
	if([sender isEqualTo:verticalSplitView])
	{
		// left subview
		if(offset == 0) return [sender frame].size.width - [self splitView:sender constrainMinCoordinate:0.0 ofSubviewAt:0];
	}
	else
	{
		// bottom subview
		if(offset == 1) return [sender frame].size.height - [self splitView:sender constrainMinCoordinate:0.0 ofSubviewAt:1];
	}
	
	return nil;
}


#pragma mark Notifications
- (void)windowWillClose:(NSNotification *)aNotification
{
	[browserViewController unbindAll];
	[self autorelease];
}


#pragma mark Accessors
- (BrowserViewController*)browserViewController
{
	return browserViewController;
}

@end
