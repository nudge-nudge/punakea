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


NSString * const VERTICAL_SPLITVIEW_DEFAULTS = @"0 0 180 472 0 181 0 577 472 0";
NSString * const HORIZONTAL_SPLITVIEW_DEFAULTS = @"0 0 182 286 0 0 287 182 162 0";


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
	
	// Set autosave names for split views
	[verticalSplitView setAutosaveName:@"PASplitView Configuration VerticalSplitView" defaults:VERTICAL_SPLITVIEW_DEFAULTS];
	[horizontalSplitView setAutosaveName:@"PASplitView Configuration HorizontalSplitView" defaults:HORIZONTAL_SPLITVIEW_DEFAULTS];
	
	// Initialize browserViewController
	browserViewController = [[BrowserViewController alloc] init];
	[verticalSplitView replaceSubview:mainPlaceholderView with:[browserViewController view]];
	
	// insert browserViewController in the responder chain
	[browserViewController setNextResponder:[self window]];
	[[[self window] contentView] setNextResponder:browserViewController];
	
	[self setupToolbar];
	[self setupStatusBar];
	[self setupTabPanel];
	
	// Register for notifications
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	[nc addObserver:self
		   selector:@selector(resultsOutlineViewSelectionDidChange:)
			   name:(id)PAResultsOutlineViewSelectionDidChangeNotification
			 object:nil];
}

- (void)setupToolbar
{	
	NSToolbar *toolbar = [[NSToolbar alloc] initWithIdentifier:@"BrowserToolbar"];
    [toolbar setDelegate:self];
    [toolbar setAllowsUserCustomization:YES];
    [toolbar setAutosavesConfiguration:YES];
	
	[[self window] setToolbar:[toolbar autorelease]];
}

- (void)setupStatusBar
{
	PAStatusBarButton *sbitem = [PAStatusBarButton statusBarButton];
	[sbitem setToolTip:@"Add new tag set to favorites"];
	[sbitem setImage:[NSImage imageNamed:@"statusbar-button-plus"]];
	//[sbitem setAlternateImage:[NSImage imageNamed:@"statusbar-button-gear"]];
	[sbitem setAction:@selector(addTagSet:)];
	[sourcePanelStatusBar addItem:sbitem];
	
	sbitem = [PAStatusBarButton statusBarButton];
	[sbitem setToolTip:@"Toggle info panel"];
	[sbitem setButtonType:NSToggleButton];
	[sbitem setImage:[NSImage imageNamed:@"statusbar-button-info"]];
	[sbitem setAlternateImage:[NSImage imageNamed:@"statusbar-button-info-on"]];
	[sbitem setAction:@selector(toggleInfo:)];
	
	[sourcePanelStatusBar addItem:sbitem];
}

- (void)setupTabPanel
{
	NSTabViewItem *infoItem = [tabPanel tabViewItemAtIndex:[tabPanel indexOfTabViewItemWithIdentifier:@"INFO"]];
	
	// Add tabview that holds infoPanePlaceholderView, infoPaneSingleSelectionView, infoPaneMultipleSelectionView
	infoPane = [[NSTabView alloc] initWithFrame:[[infoItem view] frame]];
	[infoPane setTabViewType:NSNoTabsNoBorder];
	
	// Placeholder
	NSTabViewItem *item = [[NSTabViewItem alloc] initWithIdentifier:@"PLACEHOLDER"];
	[item setView:infoPanePlaceholderView];
	[infoPane addTabViewItem:item];
	[item release];
	
	// Single selection
	item = [[NSTabViewItem alloc] initWithIdentifier:@"SINGLE_SELECTION"];	
	[item setView:infoPaneSingleSelectionView];	
	[infoPane addTabViewItem:item];
	[item release];
	
	// Multiple selection
	item = [[NSTabViewItem alloc] initWithIdentifier:@"MULTIPLE_SELECTION"];	
	[infoPane addTabViewItem:item];
	[item release];
	
	[infoItem setView:infoPane];
	[infoPane release];
	
	// TEMP
	[infoPane selectTabViewItemAtIndex:1];
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
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
		
		PASourceItem *parent = [sourcePanel itemWithValue:@"FAVORITES"];
		
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

- (void)toggleInfo:(id)sender
{
	[horizontalSplitView toggleSubviewAtIndex:1];
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

- (void)search:(id)sender
{
	NSSearchField *searchField = sender;
	
	[browserViewController setSearchFieldString:[searchField stringValue]];
}


#pragma mark Toolbar Delegate
- (NSToolbarItem *)toolbar:(NSToolbar *)toolbar
	 itemForItemIdentifier:(NSString *)itemIdentifier
 willBeInsertedIntoToolbar:(BOOL)flag
{
	// Check if this itemIdentifier is allowed (after version updates this may occur)
	if(![[self toolbarAllowedItemIdentifiers:toolbar] containsObject:itemIdentifier])
		return nil;
	
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
		[item setTarget:[[NSApplication sharedApplication] delegate]];
		[item setAction:@selector(goToManageTags:)];
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
		[[searchField cell] setSendsSearchStringImmediately:YES];
		[searchField setDelegate:self];
		
		item = [[[NSToolbarItem alloc] initWithItemIdentifier:@"Search"] autorelease];
		[item setLabel:NSLocalizedStringFromTable(@"SEARCH", @"Toolbars", nil)];
		[item setToolTip:NSLocalizedStringFromTable(@"SEARCH_TOOLTIP", @"Toolbars", nil)];
		[item setView:searchField];
		[item setPaletteLabel:[item label]];
		[item setMinSize:NSMakeSize(130, 22)];
		[item setMaxSize:NSMakeSize(180, 22)];
		[item setTarget:self];
		[item setAction:@selector(search:)];
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
		// left, right subview
		if(offset == 0) return 120.0;
		if(offset == 1) return 120.0;
	}
	else
	{
		// top, bottom subview
		if(offset == 0) return [sender frame].size.height - [self splitView:sender constrainMaxCoordinate:0.0 ofSubviewAt:1];
		if(offset == 1) return 120.0;
	}
	
	return nil;
}

- (float)splitView:(NSSplitView *)sender constrainMaxCoordinate:(float)proposedMin ofSubviewAt:(int)offset
{
	if([sender isEqualTo:verticalSplitView])
	{
		// left, right subview
		if(offset == 0) return 400.0;
		if(offset == 1) return [sender frame].size.width - [self splitView:sender constrainMinCoordinate:0.0 ofSubviewAt:0];
	}
	else
	{
		// top, bottom subview
		if(offset == 0) return [sender frame].size.height - [self splitView:sender constrainMinCoordinate:0.0 ofSubviewAt:1];
		if(offset == 1) return 200.0;
	}
	
	return nil;
}


#pragma mark StatusBar Delegate
- (BOOL)statusBar:(PAStatusBar *)sender validateItem:(PAStatusBarButton *)item
{	
	if([item action] == @selector(toggleInfo:))
	{
		if([[[horizontalSplitView subviews] objectAtIndex:1] isHidden])
			[item setAlternateState:NO];
		else
			[item setAlternateState:YES];
	}
	
	return YES;
}


#pragma mark Window Delegate
/*- (id)windowWillReturnFieldEditor:(NSWindow *)sender toObject:(id)anObject
{
	if([anObject isMemberOfClass:[PASourcePanel class]])
		return [[[NSTextField alloc] initWithFrame:NSMakeRect(0,0,50,20)] autorelease];
	
	return nil;
}*/


#pragma mark Notifications
- (void)windowWillClose:(NSNotification *)notification
{
	[browserViewController unbindAll];
	[self autorelease];
}

- (void)controlTextDidEndEditing:(NSNotification *)notification
{
	// Return key in search field makes tag cloud the first responder
	if([[notification object] isMemberOfClass:[NSSearchField class]])
	{
		[[self window] makeFirstResponder:[browserViewController tagCloud]];
	}
}

- (void)resultsOutlineViewSelectionDidChange:(NSNotification *)notification
{
	NSOutlineView *ov = [notification object];
	
	NSArray *selectedItems = [[notification userInfo] objectForKey:@"SelectedItems"];
	
	if([selectedItems count] == 0)
	{
		[infoPane selectTabViewItemWithIdentifier:@"PLACEHOLDER"];
	}
	else if([selectedItems count] == 1)
	{		
		NSTabViewItem *tvItem = [infoPane tabViewItemAtIndex:[infoPane indexOfTabViewItemWithIdentifier:@"SINGLE_SELECTION"]];
		PAInfoPaneSingleSelectionView *view = [tvItem view];
		
		[view setFile:[selectedItems objectAtIndex:0]];
		
		[infoPane selectTabViewItemWithIdentifier:@"SINGLE_SELECTION"];
	} 
	else
	{
		[infoPane selectTabViewItemWithIdentifier:@"MULTIPLE_SELECTION"];
	}
}


#pragma mark Accessors
- (BrowserViewController*)browserViewController
{
	return browserViewController;
}

- (PASplitView *)verticalSplitView
{
	return verticalSplitView;
}

- (PASplitView *)horizontalSplitView
{
	return horizontalSplitView;
}

- (PAStatusBar *)sourcePanelStatusBar
{
	return sourcePanelStatusBar;
}

- (PASourcePanel *)sourcePanel
{
	return sourcePanel;
}

@end
