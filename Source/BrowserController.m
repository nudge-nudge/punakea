//
//  BrowserController.m
//  punakea
//
//  Created by Johannes Hoffart on 04.07.06.
//  Copyright 2006 nudge:nudge. All rights reserved.
//

#import "BrowserController.h"


@interface BrowserController (PrivateAPI)

- (void)setupToolbar;
- (void)setupStatusBar;

@end


@implementation BrowserController

#pragma mark Init + Dealloc
// TODO: Why are we using this non-designated initializer???
- (id)init
{
	if (self = [super initWithWindowNibName:@"Browser"])
	{
		// Nothing yet
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
	
	[self setupToolbar];
	[self setupStatusBar];
}

- (void)setupToolbar
{	
	NSToolbar *toolbar = [[NSToolbar alloc] initWithIdentifier:@"mainToolbar"];
    [toolbar setDelegate:self];
    [toolbar setAllowsUserCustomization:YES];
    [toolbar setAutosavesConfiguration:NO];
	
	[[self window] setToolbar:[toolbar autorelease]];
}

- (void)setupStatusBar
{
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
	{
		PASourcePanelController *spController = [sourcePanel dataSource];
		
		PASourceItem *parent = [spController itemWithValue:@"FAVORITES"];
		
		PASourceItem *item = [PASourceItem itemWithValue:@"aValue" displayName:@"new name"];
		
		NNTagSet *tagSet = [NNTagSet setWithTags:[tagSetPanel tags]];
		[item setContainedObject:tagSet];
		
		[spController addChild:item toItem:parent];
		
		// Begin editing
		int row = [sourcePanel rowForItem:item];
		[sourcePanel selectRow:row byExtendingSelection:NO];
		[sourcePanel editColumn:0 row:row withEvent:nil select:YES];
	}
}

- (void)addTagSet:(id)sender
{	
	[tagSetPanel removeAllTags];
	
	[NSApp beginSheet:tagSetPanel
	   modalForWindow:[sender window]
		modalDelegate:self
	   didEndSelector:@selector(tagSetPanelDidEnd:returnCode:contextInfo:)
		  contextInfo:NULL];
}

- (void)manageTags:(id)sender
{
	[sourcePanel selectItemWithValue:@"MANAGE_TAGS"];
}

- (void)sortByName:(id)sender
{
	[[NSUserDefaults standardUserDefaults] setInteger:PATagCloudNameSortKey forKey:@"TagCloud.SortKey"];
	[browserViewController reloadData];
}

- (void)sortByRating:(id)sender
{
	[[NSUserDefaults standardUserDefaults] setInteger:PATagCloudRatingSortKey forKey:@"TagCloud.SortKey"];
	[browserViewController reloadData];
}


#pragma mark Toolbar Delegate
- (NSToolbarItem *)toolbar:(NSToolbar *)toolbar
	 itemForItemIdentifier:(NSString *)itemIdentifier
 willBeInsertedIntoToolbar:(BOOL)flag
{
	NSToolbarItem *item = nil;
	
	if([itemIdentifier isEqualTo:@"ShowTagger"])
	{
		item = [[[NSToolbarItem alloc] initWithItemIdentifier:@"ShowTagger"] autorelease];
		[item setLabel:NSLocalizedStringFromTable(@"SHOW_TAGGER", @"Toolbars", nil)];
		[item setToolTip:NSLocalizedStringFromTable(@"SHOW_TAGGER_TOOLTIP", @"Toolbars", nil)];
		[item setImage:[NSImage imageNamed:@"toolbar-show-tagger"]];
		[item setPaletteLabel:[item label]];
		[item setTarget:[[NSApplication sharedApplication] delegate]];
		[item setAction:@selector(showTagger:)];
	}	
	else if([itemIdentifier isEqualTo:@"ManageTags"])
	{
		item = [[[NSToolbarItem alloc] initWithItemIdentifier:@"ManageTags"] autorelease];
		[item setLabel:NSLocalizedStringFromTable(@"MANAGE_TAGS", @"Toolbars", nil)];
		[item setToolTip:NSLocalizedStringFromTable(@"MANAGE_TAGS_TOOLTIP", @"Toolbars", nil)];
		[item setImage:[NSImage imageNamed:@"toolbar-manage-tags"]];
		[item setPaletteLabel:[item label]];
		[item setTarget:self];
		[item setAction:@selector(manageTags:)];
	}	
	else if([itemIdentifier isEqualTo:@"SortByName"])
	{
		item = [[[NSToolbarItem alloc] initWithItemIdentifier:@"SortByName"] autorelease];
		[item setLabel:NSLocalizedStringFromTable(@"SORT_BY_NAME", @"Toolbars", nil)];
		[item setToolTip:NSLocalizedStringFromTable(@"SORT_BY_NAME_TOOLTIP", @"Toolbars", nil)];
		[item setImage:[NSImage imageNamed:@"toolbar-sort-by-name"]];
		[item setPaletteLabel:[item label]];
		[item setTarget:self];
		[item setAction:@selector(sortByName:)];
	}	
	else if([itemIdentifier isEqualTo:@"SortByRating"])
	{
		item = [[[NSToolbarItem alloc] initWithItemIdentifier:@"SortByRating"] autorelease];
		[item setLabel:NSLocalizedStringFromTable(@"SORT_BY_RATING", @"Toolbars", nil)];
		[item setToolTip:NSLocalizedStringFromTable(@"SORT_BY_RATING_TOOLTIP", @"Toolbars", nil)];
		[item setImage:[NSImage imageNamed:@"toolbar-sort-by-rating"]];
		[item setPaletteLabel:[item label]];
		[item setTarget:self];
		[item setAction:@selector(sortByRating:)];
	}
	else if([itemIdentifier isEqualTo:@"Search"])
	{
		NSSearchField *searchField = [[[NSSearchField alloc] initWithFrame:NSMakeRect(0, 0, 130, 22)] autorelease];
		
		item = [[[NSToolbarItem alloc] initWithItemIdentifier:@"Search"] autorelease];
		[item setLabel:NSLocalizedStringFromTable(@"SEARCH", @"Toolbars", nil)];
		[item setToolTip:NSLocalizedStringFromTable(@"SEARCH_TOOLTIP", @"Toolbars", nil)];
		[item setView:searchField];
		[item setPaletteLabel:[item label]];
		[item setMinSize:NSMakeSize(130, 22)];
		[item setMaxSize:NSMakeSize(180, 22)];
	}
	
	return item;
}

- (NSArray *)toolbarAllowedItemIdentifiers:(NSToolbar*)toolbar
{
    return [NSArray arrayWithObjects:NSToolbarSeparatorItemIdentifier,
        NSToolbarSpaceItemIdentifier,
        NSToolbarFlexibleSpaceItemIdentifier,
        NSToolbarCustomizeToolbarItemIdentifier, @"ShowTagger", 
		@"ManageTags", @"SortByName", @"SortByRating", @"Search", nil];
}

- (NSArray *)toolbarDefaultItemIdentifiers:(NSToolbar*)toolbar
{
    return [NSArray arrayWithObjects:@"ShowTagger", @"ManageTags", 
		NSToolbarFlexibleSpaceItemIdentifier, @"Search", nil];
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


#pragma mark Window Delegate
/*- (id)windowWillReturnFieldEditor:(NSWindow *)sender toObject:(id)anObject
{
	if([anObject isMemberOfClass:[PASourcePanel class]])
		return [[[NSTextField alloc] initWithFrame:NSMakeRect(0,0,50,20)] autorelease];
	
	return nil;
}*/


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
