// Copyright (c) 2006-2012 nudge:nudge (Johannes Hoffart & Daniel Bär). All rights reserved.
// 
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "BrowserController.h"


@interface BrowserController (PrivateAPI)

- (NSSearchField*)createSearchField ;
- (void)setupTabPanel;
- (void)setupFieldEditor;
- (void)setupToolbar;
- (void)setupStatusBar;

- (void)togglePaneWithIdentifier:(NSString *)identifier;
- (BOOL)paneWithIdentifierIsVisible:(NSString *)identifier;

- (CGFloat)splitView:(NSSplitView *)sender constrainMaxCoordinate:(CGFloat)proposedMin ofSubviewAt:(NSInteger)offset;

- (void)loadFavorites;
- (void)loadUserDefaults;

- (NSString *)pathOfFavoritesFile;

@end


NSString * const FILENAME_FAVORITES_PLIST = @"favorites.plist";
NSUInteger const VERSION_FAVORITES_PLIST = 1;

NSString * const VERTICAL_SPLITVIEW_DEFAULTS = @"0 0 200 553 0 201 0 494 553 0";
NSString * const HORIZONTAL_SPLITVIEW_DEFAULTS = @"0 0 202 361 0 0 362 202 168 0";


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
	titleBar = (PATitleBar *)((PABrowserWindow *)self.window).titleBarView;
	
	// this keeps the windowcontroller from auto-placing the window
	// - window is always opened where it was closed
	[self setShouldCascadeWindows:NO];
	
	[[self window] setFrameAutosaveName:@"punakea.browser"];
	
	// Set autosave names for split views
	[verticalSplitView setAutosaveName:@"PASplitView Configuration VerticalSplitView" defaults:VERTICAL_SPLITVIEW_DEFAULTS];
	[horizontalSplitView setAutosaveName:@"PASplitView Configuration HorizontalSplitView" defaults:HORIZONTAL_SPLITVIEW_DEFAULTS];
	
	// Initialize browserViewController
	browserViewController = [[BrowserViewController alloc] init];
	[rightContentView replaceSubview:mainPlaceholderView with:[browserViewController view]];
	
	// Fix frame of this new view
	NSRect rect = [mainPlaceholderView frame];
	rect.size.width = [[[verticalSplitView subviews] objectAtIndex:1] frame].size.width;
	[[browserViewController view] setFrame:rect];
	
	// insert browserViewController in the responder chain
	[browserViewController setNextResponder:[self window]];
	[[[self window] contentView] setNextResponder:browserViewController];
	
	// create searchfield
	searchField = [[self createSearchField] retain];
	
	// Set the title bar height
	PABrowserWindow *aWindow = (PABrowserWindow *)[self window];
    aWindow.titleBarHeight = 40.0;
	
	// setup stuff
	[self setupToolbar];
	[self setupStatusBar];
	[self setupTabPanel];
	[self setupFieldEditor];	
		
	// Register for notifications
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	[nc addObserver:self
		   selector:@selector(resultsOutlineViewSelectionDidChange:)
			   name:(id)PAResultsOutlineViewSelectionDidChangeNotification
			 object:nil];
	
	// Load favorites
	[self loadFavorites];
	
	// Load User Defaults
	[self loadUserDefaults];
}

- (void)dealloc
{
	[statusBarProgressIndicator release];
	
	if (searchField) [searchField release];
	
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	[sourcePanelFieldEditor release];
	
	[browserViewController release];
	
	[super dealloc];
}

- (void)windowDidLoad
{
    [super windowDidLoad];

	// Inform the user that extended attributes will be added to tagged files
	// in order to comply with Apple's sandboxing policy.
	bool messageExtAttrShown = [[NSUserDefaults standardUserDefaults] boolForKey:@"Message.ExtendedAttributesWillBeAddedToTaggedFiles.Shown"];
	
	if (!messageExtAttrShown)
	{
		NSAlert *alert = [[NSAlert alloc] init];
		
		// NSLocalizedStringFromTable(@"CHANGE_FILE_EXTENSION", @"FileManager", @"")
		
		NSString *text = NSLocalizedStringFromTable(@"MSG_EXTENDED_ATTRIBUTES_WILL_BE_ADDED_TO_TAGGED_FILES_TITLE", @"Global", @"");
		[alert setMessageText:text];
		
		text = NSLocalizedStringFromTable(@"MSG_EXTENDED_ATTRIBUTES_WILL_BE_ADDED_TO_TAGGED_FILES_MESSAGE", @"Global", @"");
		[alert setInformativeText:text];
		
		text = NSLocalizedStringFromTable(@"MSG_EXTENDED_ATTRIBUTES_WILL_BE_ADDED_TO_TAGGED_FILES_BUTTON_OK", @"Global", @"");
		[alert addButtonWithTitle:text];
		
		text = NSLocalizedStringFromTable(@"MSG_EXTENDED_ATTRIBUTES_WILL_BE_ADDED_TO_TAGGED_FILES_BUTTON_CANCEL", @"Global", @"");
		[alert addButtonWithTitle:text];
		
		[alert beginSheetModalForWindow:[self window]
						  modalDelegate:self
						 didEndSelector:@selector(learnMoreAboutExtendedAttributes:returnCode:contextInfo:)
							contextInfo:nil];
    }
}

- (void)learnMoreAboutExtendedAttributes:(NSAlert *)alert returnCode:(NSInteger)returnCode contextInfo:(void *)context
{
	if (returnCode == NSAlertFirstButtonReturn)
	{
		[[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"Message.ExtendedAttributesWillBeAddedToTaggedFiles.Shown"];
	}
	else if (returnCode == NSAlertSecondButtonReturn)
	{
		[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://www.nudgenudge.eu/tutorial"]];
		[NSApp terminate:nil];
	}
}

- (NSSearchField*)createSearchField 
{
	// get current category
	PASearchType type = [[NSUserDefaults standardUserDefaults] integerForKey:@"General.Search.Type"];
	
	// configure search field
	NSSearchField *field = [[[NSSearchField alloc] initWithFrame:NSMakeRect(0, 0, 130, 22)] autorelease];
	[field setFont:[NSFont systemFontOfSize:[NSFont systemFontSizeForControlSize:NSSmallControlSize]]];
	[field setDelegate:browserViewController];
	[browserViewController setSearchField:field];
	
	// create menu for determining search type
	NSMenu *searchTypeMenu = [[NSMenu alloc] initWithTitle:@""];
	
	NSMenuItem *prefixTagSearchItem = [[[NSMenuItem alloc] initWithTitle:NSLocalizedStringFromTable(@"FIND_TAG_BY_PREFIX",@"Toolbars",@"")
									   action:@selector(setSearchTypeFrom:)
								keyEquivalent:@""] autorelease];
	[prefixTagSearchItem setEnabled:YES];
	[prefixTagSearchItem setTag:PATagPrefixSearchType];
	[prefixTagSearchItem setTarget:browserViewController];
	[searchTypeMenu insertItem:prefixTagSearchItem atIndex:0];
	
	if (type == PATagPrefixSearchType) {
		[prefixTagSearchItem setState:NSOnState];
	} else {
		[prefixTagSearchItem setState:NSOffState];
	}
	
	NSMenuItem *tagSearchItem = [[[NSMenuItem alloc] initWithTitle:NSLocalizedStringFromTable(@"FIND_TAG_BY_SUBSTRING",@"Toolbars",@"")
																  action:@selector(setSearchTypeFrom:)
														   keyEquivalent:@""] autorelease];
	[tagSearchItem setEnabled:YES];
	[tagSearchItem setTag:PATagSearchType];
	[tagSearchItem setTarget:browserViewController];
	[searchTypeMenu insertItem:tagSearchItem atIndex:1];
	
	if (type == PATagSearchType) {
		[tagSearchItem setState:NSOnState]; 
	} else {
		[tagSearchItem setState:NSOffState];
	}
	
	// create menu for determining search type
	NSMenuItem *fulltextSearchItem = [[[NSMenuItem alloc] initWithTitle:NSLocalizedStringFromTable(@"FIND_IN_RESULTS",@"Toolbars",@"")
																  action:@selector(setSearchTypeFrom:)
														   keyEquivalent:@""] autorelease];
	[fulltextSearchItem setEnabled:YES];
	[fulltextSearchItem setTag:PAFullTextSearchType];
	[fulltextSearchItem setTarget:browserViewController];
	[searchTypeMenu insertItem:fulltextSearchItem atIndex:2];
	
	[[field cell] setSearchMenuTemplate:searchTypeMenu];
	
	return field;
}

- (void)setupToolbar
{	
	/*NSToolbar *toolbar = [[NSToolbar alloc] initWithIdentifier:@"BrowserToolbar"];
    [toolbar setDelegate:self];
    [toolbar setAllowsUserCustomization:YES];
    [toolbar setAutosavesConfiguration:YES];*/
	
	//[[self window] setToolbar:[toolbar autorelease]];
	
	PATitleBarButton *tbitem = [PATitleBarButton titleBarButton];
	[tbitem setIdentifier:@"sync"];
	[tbitem setImage:[NSImage imageNamed:@"toolbar-sync"]];
	[tbitem setToolTip:NSLocalizedStringFromTable(@"SYNC_TAGS_TOOLTIP", @"Toolbars", nil)];
	[tbitem setTarget:[NSApp delegate]];
	[tbitem setAction:@selector(syncTags:)];
	[titleBar addSubview:tbitem positioned:PATitleBarButtonRightAlignment];
	
	PATitleBarSearchButton *tbsitem = [PATitleBarSearchButton titleBarButton];
	[tbsitem setIdentifier:@"search"];
	[tbsitem setExtensionWidth:235.0];
	[tbsitem setSearchField:[self createSearchField]];
	[tbsitem setImage:[NSImage imageNamed:@"toolbar-search"]];
	[titleBar addSubview:tbsitem positioned:PATitleBarButtonRightAlignment];
	
	/*PATitleBarButton *tbitem = [PATitleBarButton titleBarButton];
	[tbitem setToolTip:@"Add new tag set to favorites"];
	[tbitem setImage:[NSImage imageNamed:@"toolbar-show-tagger"]];
	[titleBar addSubview:tbitem positioned:PATitleBarButtonRightAlignment];*/
}

- (void)setupStatusBar
{
	// Source Panel StatusBar
	
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
	[sbitem setAction:@selector(toggleInfoPane:)];
	[sourcePanelStatusBar addItem:sbitem];
	
	sbitem = [PAStatusBarButton statusBarButton];
	[sbitem setToolTip:@"Toggle tags panel"];
	[sbitem setButtonType:NSToggleButton];
	[sbitem setImage:[NSImage imageNamed:@"statusbar-button-tags"]];
	[sbitem setAlternateImage:[NSImage imageNamed:@"statusbar-button-tags-on"]];
	[sbitem setAction:@selector(toggleTagsPane:)];
	[sourcePanelStatusBar addItem:sbitem];
	
	// Right StatusBar	
	statusBarProgressIndicator = [[PAStatusBarProgressIndicator statusBarProgressIndicator] retain];
	[statusBarProgressIndicator setStringValue:@"Gathering Tags"];
	[statusBarProgressIndicator setHidden:YES];
	[rightStatusBar addItem:statusBarProgressIndicator];	
}

- (void)setupTabPanel
{
	//-- First, set up the INFO tabview item
	
	NSTabViewItem *infoItem = [tabPanel tabViewItemAtIndex:[tabPanel indexOfTabViewItemWithIdentifier:@"INFO"]];
	
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
	[item setView:infoPaneMultipleSelectionView];	
	[infoPane addTabViewItem:item];
	[item release];
	
	[infoItem setView:infoPane];
	[infoPane release];
	
	//-- Next, we set up the TAGS item
	
	NSTabViewItem *tagsItem = [tabPanel tabViewItemAtIndex:[tabPanel indexOfTabViewItemWithIdentifier:@"TAGS"]];
	
	tagsPane = [[NSTabView alloc] initWithFrame:[[tagsItem view] frame]];
	[tagsPane setTabViewType:NSNoTabsNoBorder];
	
	// Placeholder
	item = [[NSTabViewItem alloc] initWithIdentifier:@"PLACEHOLDER"];
	[item setView:tagsPanePlaceholderView];
	[tagsPane addTabViewItem:item];
	[item release];
	
	// Tags
	item = [[NSTabViewItem alloc] initWithIdentifier:@"TAGS"];
	[item setView:tagsPaneTagsView];
	[tagsPane addTabViewItem:item];
	[item release];
	
	[tagsItem setView:tagsPane];
	[tagsPane release];
}

- (void)setupFieldEditor
{
	// Create custom field editor for source panel
	
	NSTextView *editor = [[NSTextView alloc] initWithFrame:NSMakeRect(0,0,50,20)];
	[editor setFieldEditor:YES];
	
	[editor setBackgroundColor:[NSColor whiteColor]];
	[editor setFocusRingType:NSFocusRingTypeNone];
	
	[editor setFont:[NSFont systemFontOfSize:11]];
	[editor setTextContainerInset:NSMakeSize(-3,1)];
	
	[editor setAutoresizingMask:NSViewWidthSizable];
	
	[editor setMinSize:NSMakeSize(0.0, 16.0)];
	[editor setMaxSize:NSMakeSize(CGFLOAT_MAX, 16.0)];
	
	[editor setVerticallyResizable:NO];
	[editor setHorizontallyResizable:YES];
	
	sourcePanelFieldEditor = editor;
}

- (void)loadUserDefaults
{
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	
	// Make the right pane appear	
	NSString *identifier = [userDefaults stringForKey:@"Appearance.InfoPane.Active"];	
	[tabPanel selectTabViewItemWithIdentifier:identifier];
	
	[sourcePanelStatusBar reloadData];
}

#pragma mark Events
- (void)flagsChanged:(NSEvent *)theEvent
{
	if ([theEvent modifierFlags] & NSAlternateKeyMask)
	{
		[sourcePanelStatusBar setAlternateState:YES];
		[[PADropManager sharedInstance] setAlternateState:YES];
	} else {
		[sourcePanelStatusBar setAlternateState:NO];
		[[PADropManager sharedInstance] setAlternateState:NO];
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

- (void)tagSetPanelDidEnd:(PATagSetPanel *)panel returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo
{
	if (returnCode == NSOKButton)
	{
		PASourcePanelController *spController = [sourcePanel dataSource];
		
		PASourceItem *parent = [sourcePanel itemWithValue:@"FAVORITES"];		
		PASourceItem *item;
		
		BOOL usesDefaultDisplayName = NO;
		
		if([panel sourceItem])
		{
			item = [panel sourceItem];
			usesDefaultDisplayName = [[item displayName] isEqualTo:[item defaultDisplayName]];
		} else {
			item = [PASourceItem itemWithValue:@"aValue" displayName:@"New Tag Set"];
		}
		
		// Set the right icon for a single tag or a tag set
		if([[tagSetPanel tags] count] == 1)
			[item setImage:[NSImage imageNamed:@"source-panel-tag"]];
		else
			[item setImage:[NSImage imageNamed:@"source-panel-tag-set"]];
		
		NNTagSet *tagSet = [NNTagSet setWithTags:[tagSetPanel tags] name:[item displayName]];
		[item setContainedObject:tagSet];
		
		// Is this a new set?
		if(![panel sourceItem])
		{
			[spController addChild:item toItem:parent];
		
			[item validateDisplayName];
		
			// Begin editing
			NSInteger row = [sourcePanel rowForItem:item];
			[sourcePanel selectRow:row byExtendingSelection:NO];
			[sourcePanel editColumn:0 row:row withEvent:nil select:YES];
		} else {
			// If we were using the default display name, stick to this
			if(usesDefaultDisplayName)
				[item setDisplayName:[item defaultDisplayName]];
		}
		
		[self saveFavorites];
	}
}

- (void)addTagSet:(id)sender
{	
	[tagSetPanel removeAllTags];
	[tagSetPanel setSourceItem:nil];
	
	[NSApp beginSheet:tagSetPanel
	   modalForWindow:[self window]
		modalDelegate:self
	   didEndSelector:@selector(tagSetPanelDidEnd:returnCode:contextInfo:)
		  contextInfo:NULL];
}

- (void)toggleInfoPane:(id)sender
{
	[self togglePaneWithIdentifier:@"INFO"];
}

- (void)toggleTagsPane:(id)sender
{
	[self togglePaneWithIdentifier:@"TAGS"];
}

- (void)togglePaneWithIdentifier:(NSString *)identifier
{
	BOOL paneSelected = [[tabPanel selectedTabViewItem] isEqualTo:[tabPanel tabViewItemAtIndex:[tabPanel indexOfTabViewItemWithIdentifier:identifier]]];
	
	if(paneSelected)
	{
		[horizontalSplitView toggleSubviewAtIndex:1];
	}
	else
	{
		[tabPanel selectTabViewItemWithIdentifier:identifier];
		
		// Ensure pane is visible
		if([[[horizontalSplitView subviews] objectAtIndex:1] isHidden])
			[horizontalSplitView toggleSubviewAtIndex:1];
	}
	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults setObject:identifier forKey:@"Appearance.InfoPane.Active"];
}

- (BOOL)infoPaneIsVisible
{
	return [self paneWithIdentifierIsVisible:@"INFO"];
}

- (BOOL)tagsPaneIsVisible
{
	return [self paneWithIdentifierIsVisible:@"TAGS"];
}

- (BOOL)paneWithIdentifierIsVisible:(NSString *)identifier
{
	// Any pane is visible?
	if([[[horizontalSplitView subviews] objectAtIndex:1] isHidden])
		return NO;

	BOOL paneSelected = [[tabPanel selectedTabViewItem] isEqualTo:[tabPanel tabViewItemAtIndex:[tabPanel indexOfTabViewItemWithIdentifier:identifier]]];
	
	return paneSelected;
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
	// TODO why is this needed to make the tagcloud the next responder on pressing enter in searchField?
	return;
}

- (IBAction)editTagSet:(id)sender
{
	NSOutlineView *ov;
	
	if([sender isKindOfClass:[NSOutlineView class]])
	   ov = sender;
	else
	   ov = [[(NSMenuItem *)sender menu] delegate];
	
	PASourceItem *sourceItem = [ov itemAtRow:[ov selectedRow]];
	
	[tagSetPanel setSourceItem:sourceItem];
	
	if([[sourceItem containedObject] isMemberOfClass:[NNTagSet class]])
	{
		[tagSetPanel setTags:[[sourceItem containedObject] tags]];
	} else {
		[tagSetPanel setTags:[NSArray arrayWithObject:[sourceItem containedObject]]];
	}
	
	[NSApp beginSheet:tagSetPanel
	   modalForWindow:[self window]
		modalDelegate:self
	   didEndSelector:@selector(tagSetPanelDidEnd:returnCode:contextInfo:)
		  contextInfo:NULL];
}

- (IBAction)removeTagSet:(id)sender
{
	[[[NSApplication sharedApplication] delegate] delete:sender];
}

- (void)setSearchType:(PASearchType)type
{
	[(PATitleBarSearchButton *)[titleBar buttonWithIdentifier:@"search"] selectSearchMenuItemWithTag:type];
}

- (void)abortSearch:(id)sender
{
	[(PATitleBarSearchButton *)[titleBar buttonWithIdentifier:@"search"] abortSearch:sender];
}


#pragma mark Misc
- (NSString *)pathOfFavoritesFile
{	
	// use default location in app support
	NSBundle *bundle = [NSBundle mainBundle];
	NSString *path = [bundle bundlePath];
	NSString *appName = [[path lastPathComponent] stringByDeletingPathExtension]; 
	
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSString *folder = [NSString stringWithFormat:@"~/Library/Application Support/%@/",appName];
	folder = [folder stringByExpandingTildeInPath]; 
	
	if ([fileManager fileExistsAtPath: folder] == NO) 
		[fileManager createDirectoryAtPath:folder withIntermediateDirectories:YES attributes:nil error:NULL];
	
	return [folder stringByAppendingPathComponent:FILENAME_FAVORITES_PLIST]; 
}

- (void)saveFavorites
{
	NSMutableDictionary *dict = [NSMutableDictionary dictionary];
	
	// Store version number for future versions and easy update procedure
	[dict setObject:[NSNumber numberWithInteger:VERSION_FAVORITES_PLIST] forKey:@"Version"];
	
	NSMutableArray *favorites = [NSMutableArray array];
	
	NSEnumerator *e = [[(PASourceItem *)[sourcePanel itemWithValue:@"FAVORITES"] children] objectEnumerator];
	PASourceItem *item;
	
	while(item = [e nextObject])
	{
		NSMutableDictionary *itemDict = [NSMutableDictionary dictionary];
		
		// Save display name
		[itemDict setObject:[item displayName] forKey:@"DisplayName"];
		
		// Save tags		
		NSMutableArray *tags = [NSMutableArray array];
		
		if([[item containedObject] isKindOfClass:[NNTag class]])
		{
			NNTag *tag = [item containedObject];
			[tags addObject:[tag name]];
		}
		else
		{
			NNTagSet *tagSet = [item containedObject];
			
			NSEnumerator *tagE = [[tagSet tags] objectEnumerator];
			NNTag *tag;
			while(tag = [tagE nextObject])
			{
				[tags addObject:[tag name]];
			}
		}
		
		[itemDict setObject:tags forKey:@"Tags"];
		
		[favorites addObject:itemDict];
	}	
	
	[dict setObject:favorites forKey:@"Favorites"];
	
	[dict writeToFile:[self pathOfFavoritesFile] atomically:YES];
}

- (void)loadFavorites
{
	NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:[self pathOfFavoritesFile]];
	
	NSArray *favorites = [dict objectForKey:@"Favorites"];
	
	PASourceItem *favSourceItem = [sourcePanel itemWithValue:@"FAVORITES"];
	
	NSEnumerator *e = [favorites objectEnumerator];
	NSDictionary *itemDict;
	while(itemDict = [e nextObject])
	{
		// Create item with restored display name
		PASourceItem *favorite = [PASourceItem itemWithValue:[itemDict objectForKey:@"DisplayName"] 
												 displayName:[itemDict objectForKey:@"DisplayName"]];
		
		// Restore tags
		NNTagSet *tagSet = [NNTagSet setWithTags:[NSArray array] name:[favorite displayName]];
		
		NSEnumerator *tagE = [(NSArray *)[itemDict objectForKey:@"Tags"] objectEnumerator];
		NSString *tagName;
		while(tagName = [tagE nextObject])
		{
			NNTag *tag = [[NNTags sharedTags] tagForName:tagName];
			
			if(tag)
				[tagSet addTag:tag];
		}
		
		// Set the right image for a single tag or a tag  set
		if([[tagSet tags] count] == 1)
			[favorite setImage:[NSImage imageNamed:@"source-panel-tag"]];
		else
			[favorite setImage:[NSImage imageNamed:@"source-panel-tag-set"]];
		
		[favorite setContainedObject:tagSet];
		
		// Add favorite set to favorites group
		[favSourceItem addChild:favorite];
	}
	
	// Reload data
	[sourcePanel reloadData];
}

- (void)startProgressAnimationWithDescription:(NSString *)aString
{
	if([aString isNotEqualTo:[statusBarProgressIndicator stringValue]])
		[statusBarProgressIndicator setStringValue:aString];	
	[statusBarProgressIndicator setHidden:NO];
	[rightStatusBar setNeedsDisplay:YES];
}

- (void)stopProgressAnimation
{
	[statusBarProgressIndicator setHidden:YES];
	[rightStatusBar setNeedsDisplay:YES];
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
- (CGFloat)splitView:(NSSplitView *)sender constrainMinCoordinate:(CGFloat)proposedMin ofSubviewAt:(NSInteger)offset
{
	if([sender isEqualTo:verticalSplitView])
	{
		// left, right subview
		if(offset == 0) return 200.0;
		if(offset == 1) return 300.0;
	}
	else
	{
		// top, bottom subview
		if(offset == 0) return [sender frame].size.height - [self splitView:sender constrainMaxCoordinate:0.0 ofSubviewAt:1];
		if(offset == 1) return 150.0;
	}
	
	return 0.0;
}

- (CGFloat)splitView:(NSSplitView *)sender constrainMaxCoordinate:(CGFloat)proposedMin ofSubviewAt:(NSInteger)offset
{
	if([sender isEqualTo:verticalSplitView])
	{
		// NSLog(@"told left %f is %f", 300.0, [[[verticalSplitView subviews] objectAtIndex:0] frame].size.width);
		
		// left, right subview
		if(offset == 0) return 600.0;
		if(offset == 1) return [sender frame].size.width - [self splitView:sender constrainMinCoordinate:0.0 ofSubviewAt:0];
	}
	else
	{
		// top, bottom subview
		if(offset == 0) return [sender frame].size.height - [self splitView:sender constrainMinCoordinate:0.0 ofSubviewAt:1];
		if(offset == 1) return 200.0;
	}
	
	return 0.0;
}


#pragma mark StatusBar Delegate
- (BOOL)statusBar:(PAStatusBar *)sender validateItem:(PAStatusBarButton *)item
{	
	if([item action] == @selector(toggleInfoPane:))
	{
		if([self infoPaneIsVisible])
			[item setAlternateState:YES];
		else
			[item setAlternateState:NO];
	}
	
	if([item action] == @selector(toggleTagsPane:))
	{
		if([self tagsPaneIsVisible])
			[item setAlternateState:YES];
		else
			[item setAlternateState:NO];
	}
	
	return YES;
}


#pragma mark Window Delegate
- (id)windowWillReturnFieldEditor:(NSWindow *)sender toObject:(id)anObject
{
	if([anObject isMemberOfClass:[PASourcePanel class]])
		return sourcePanelFieldEditor;
	
	return nil;
}

- (NSRect)window:(NSWindow *)window willPositionSheet:(NSWindow *)sheet usingRect:(NSRect)rect
{
	rect.origin.y = window.frame.size.height - ((PABrowserWindow *)self.window).titleBarView.frame.size.height;
	return rect;
}


#pragma mark Notifications
- (void)windowWillClose:(NSNotification *)notification
{
	[self autorelease];
}

- (void)resultsOutlineViewSelectionDidChange:(NSNotification *)notification
{
	NSArray *selectedItems = [[notification userInfo] objectForKey:@"SelectedItems"];
	
	// Update Info Pane
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
		NSTabViewItem *tvItem = [infoPane tabViewItemAtIndex:[infoPane indexOfTabViewItemWithIdentifier:@"MULTIPLE_SELECTION"]];
		PAInfoPaneMultipleSelectionView *view = [tvItem view];
		
		[view setFiles:selectedItems];
		
		[infoPane selectTabViewItemWithIdentifier:@"MULTIPLE_SELECTION"];
	}
	
	// Update Tags Pane
	if([selectedItems count] == 0)
	{
		// If no selection, use placeholder
		[tagsPane selectTabViewItemWithIdentifier:@"PLACEHOLDER"];
	}
	else if([selectedItems count] == 1)
	{
		// Show all tags from file		
		NNTaggableObject *taggableObject = [selectedItems objectAtIndex:0];
		[tagsPaneTagsView setTags:[[taggableObject tags] allObjects]];
		[tagsPaneTagsView setTaggableObject:taggableObject];
		
		[tagsPaneTagsView setLabel:NSLocalizedStringFromTable(@"EDIT_TAGS", @"Tags", nil)];
		
		[tagsPane selectTabViewItemWithIdentifier:@"TAGS"];
	}
	else
	{
		// Show common tags				
		NSMutableSet *commonTagSet = [NSMutableSet set];
		BOOL firstLoop = YES;
		
		for(NNTaggableObject *taggableObject in selectedItems)
		{		
			if(firstLoop)
			{
				[commonTagSet unionSet:[taggableObject tags]];
				firstLoop = NO;
			} else {
				[commonTagSet intersectSet:[taggableObject tags]];
			}
		}
		
		[tagsPaneTagsView setTags:[commonTagSet allObjects]];
		[tagsPaneTagsView setTaggableObjects:selectedItems];
		
		[tagsPaneTagsView setLabel:NSLocalizedStringFromTable(@"EDIT_COMMON_TAGS", @"Tags", nil)];

		[tagsPane selectTabViewItemWithIdentifier:@"TAGS"];
	}
	
	// Update right statusbar to reveal location of the selected file (if applicable)
	if([selectedItems count] == 1)
	{
		NNFile *file = [selectedItems objectAtIndex:0];
		NSString *path = [[[file path] stringByAbbreviatingWithTildeInPath] stringByDeletingLastPathComponent];
		
		[rightStatusBar setStringValue:path];
		[rightStatusBar setFilePath:[file path]];
	} else {
		[rightStatusBar setStringValue:nil];
		[rightStatusBar setFilePath:nil];
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

- (PAStatusBar *)rightStatusBar
{
	return rightStatusBar;
}

- (PASourcePanel *)sourcePanel
{
	return sourcePanel;
}

- (NSSearchField *)searchField
{
	return [[titleBar buttonWithIdentifier:@"search"] searchField];
}

- (PATitleBar *)titleBar
{
	return titleBar;
}

@end
