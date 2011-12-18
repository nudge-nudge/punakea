// Copyright (c) 2006-2011 nudge:nudge (Johannes Hoffart & Daniel BŠr)
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

#import "Core.h";

#define RUNNING_LION (floor(NSAppKitVersionNumber) > NSAppKitVersionNumber10_6)

@interface Core (PrivateAPI)

- (void)loadQuickLookFramework;

- (void)setupToolbar;
- (void)showStatusItem;

- (void)createDirectoriesIfNeeded:(BOOL)flag generateContent:(BOOL)generateContent;
- (void)displayWarningWithMessage:(NSString*)messageInfo;

- (void)showTagger:(id)sender enableManageFiles:(BOOL)flag activatesLastActiveApp:(BOOL)activatesLastActiveApp;

- (void)applicationWillTerminate:(NSNotification *)note;

+ (BOOL)wasLaunchedAsLoginItem;
+ (BOOL)wasLaunchedByProcess:(NSString*)creator;

- (BOOL)appHasPreferences;
- (BOOL)appIsActive;

- (void)loadUserDefaults;
- (void)updateUserDefaultsToVersion:(NSInteger)newVersion;

- (void)loadTagCache;
- (void)saveTagCache;
- (NSString*)pathForTagCacheFile;

- (void)setTaggerController:(TaggerController *)controller;

@end

@implementation Core

#pragma mark init + dealloc
+ (void)initialize
{
	// register value transformers
	
	PACollectionNotEmpty *collectionNotEmpty = [[[PACollectionNotEmpty alloc] init] autorelease];
	[NSValueTransformer setValueTransformer:collectionNotEmpty
									forName:@"PACollectionNotEmpty"];
	
	PABoolToColorTransformer *boolToColorTransformer = [[[PABoolToColorTransformer alloc] init] autorelease];
	[NSValueTransformer setValueTransformer:boolToColorTransformer
									forName:@"PABoolToColorTransformer"];
}

- (id)init
{
    if (self = [super init])
    {
		lcl_configure_by_name("main/*", lcl_vTrace);
		
		// dynamically load QuickLook framework to keep 10.5 compatibility
		[self loadQuickLookFramework];
		
		userDefaults = [NSUserDefaults standardUserDefaults];
		[self loadUserDefaults];
		
		[PAInstaller install];
		
		globalTags = [NNTags sharedTags];
		
		tagging = [NNTagging tagging];
			
		lcl_log(lcl_cglobal,lcl_vInfo, @"Punakea (compiled on %s at %s) started",__DATE__,__TIME__);
		
//		@"Punakea compiled on %s at %s\n",__DATE__,__TIME__
	}
    return self;
}

- (void)awakeFromNib
{
	[NSApp setDelegate:self]; 
	[self setupToolbar];
	
	// load cache
	[self loadTagCache];
	
	if (![Core wasLaunchedAsLoginItem])
	{
		[self showBrowser:self];
	}
	
	if ([userDefaults boolForKey:@"General.Sidebar.Enabled"])
	{
		sidebarController = [[SidebarController alloc] initWithWindowNibName:@"Sidebar"];
		[sidebarController window];
	}
	
	if ([userDefaults boolForKey:@"General.StatusItem.Enabled"])
	{
		[self showStatusItem];
	}
	
	NSUserDefaultsController *udc = [NSUserDefaultsController sharedUserDefaultsController];
	
	// listen for sidebar pref changes
	[udc addObserver:self 
		  forKeyPath:@"values.General.Sidebar.Enabled" 
			 options:0 
			 context:NULL];
	
	// listen for status item pref changes
	[udc addObserver:self 
		  forKeyPath:@"values.General.StatusItem.Enabled" 
			 options:0 
			 context:NULL];
	
	// Listen for Tagger Hotkey Changes and initialize hotkey
	[udc addObserver:self 
		  forKeyPath:@"values.General.Hotkey.Tagger.KeyCode" 
			 options:0 
			 context:NULL];
	[udc addObserver:self 
		  forKeyPath:@"values.General.Hotkey.Tagger.Modifiers" 
			 options:0 
			 context:NULL];
	[self registerHotkeyForTagger];
	
	// load services class and set as service provides
	services =  [[PAServices alloc] init];
	[NSApp setServicesProvider:services];
	
	// register for punakea:// url
	[[NSAppleEventManager sharedAppleEventManager] setEventHandler:self 
													   andSelector:@selector(getUrl:withReplyEvent:) 
													 forEventClass:kInternetEventClass 
														andEventID:kAEGetURL];

	// DEBUG
	//[[PANotificationReceiver alloc] init];
	
	UKCrashReporterCheckForCrash();
}

- (void)dealloc
{
	[services release];
	
	[statusMenu release];
	
	NSUserDefaultsController *udc = [NSUserDefaultsController sharedUserDefaultsController];
	
	[udc removeObserver:self forKeyPath:@"values.General.Sidebar.Enabled"];
	[udc removeObserver:self forKeyPath:@"values.General.StatusItem.Enabled"];
	
	[udc removeObserver:self forKeyPath:@"values.General.Hotkey.Tagger.KeyCode"];
	[udc removeObserver:self forKeyPath:@"values.General.Hotkey.Tagger.Modifiers"];
	
	[preferenceController release];
	
    [super dealloc];
}

- (void)applicationWillTerminate:(NSNotification *)note 
{ 
	// save tag cache
	[self saveTagCache];
	
	[userDefaults synchronize];
} 

- (void)setupToolbar
{
    NSToolbar *toolbar = [[NSToolbar alloc] initWithIdentifier:@"mainToolbar"];
    [toolbar setDelegate:self];
    [toolbar setAllowsUserCustomization:YES];
    [toolbar setAutosavesConfiguration:YES];
    [[self window] setToolbar:[toolbar autorelease]];
}

- (SUUpdater*)updater
{
	return updater;
}

- (void)showStatusItem
{
	// create status item
	NSStatusBar *bar = [NSStatusBar systemStatusBar];
	statusItem = [bar statusItemWithLength:30.0];
	[statusItem retain];
	
	// set images
	[statusItem setImage:[NSImage imageNamed:@"MenuBarIcon"]];
	[statusItem setAlternateImage:[NSImage imageNamed:@"MenuBarIconAlt"]];
	[statusItem setHighlightMode:YES];
	
	// set menu
	[statusItem setMenu:statusMenu];
}

- (void)unloadStatusItem
{
	NSStatusBar *bar = [NSStatusBar systemStatusBar];
	[bar removeStatusItem:statusItem];
	[statusItem release];
	statusItem = nil;
}

#pragma mark storage
- (void)loadTagCache
{
	NSString *path = [self pathForTagCacheFile];
	NSMutableData *data = [NSData dataWithContentsOfFile:path];
	
	if (data)
	{
		NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
		NSMutableDictionary *rootObject = [unarchiver decodeObject];
		[unarchiver finishDecoding];
		[unarchiver release];
		
		[[PATagCache sharedInstance] setCache:[rootObject valueForKey:@"tagCache"]];
	}
}

- (void)saveTagCache
{
	NSString *path  = [self pathForTagCacheFile];
	NSMutableDictionary *rootObject = [NSMutableDictionary dictionary];
	[rootObject setValue:[[PATagCache sharedInstance] cache] forKey:@"tagCache"];
	
	NSMutableData *data = [NSMutableData data];
	NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
	[archiver setOutputFormat:NSPropertyListBinaryFormat_v1_0];
	[archiver encodeObject:rootObject];
	[archiver finishEncoding];
	[data writeToFile:path atomically:YES];
	[archiver release];
}

- (NSString*)pathForTagCacheFile
{
	NSString *fileName = @"tagCache.plist"; 
	
	// use default location in app support
	NSBundle *bundle = [NSBundle mainBundle];
	NSString *path = [bundle bundlePath];
	NSString *appName = [[path lastPathComponent] stringByDeletingPathExtension]; 
		
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSString *folder = [NSString stringWithFormat:@"~/Library/Application Support/%@/",appName];
	folder = [folder stringByExpandingTildeInPath]; 
		
	if ([fileManager fileExistsAtPath: folder] == NO) 
		[fileManager createDirectoryAtPath:folder withIntermediateDirectories:YES attributes:nil error:NULL];
		
	return [folder stringByAppendingPathComponent:fileName]; 
}

#pragma mark events
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{	
	if (object == [NSUserDefaultsController sharedUserDefaultsController])
	{
		if ([keyPath isEqualToString:@"values.General.Sidebar.Enabled"])
		{
			BOOL showSidebar = [[NSUserDefaults standardUserDefaults] boolForKey:@"General.Sidebar.Enabled"];
			BOOL sidebarIsLoaded = NO;
			
			// look if sidebar is already loaded
			NSEnumerator *windowEnumerator = [[[NSApplication sharedApplication] windows] objectEnumerator];
			NSWindow *window;
			
			while (window = [windowEnumerator nextObject])
			{
				if ([[window title] isEqualToString:@"Punakea : Sidebar"])
					sidebarIsLoaded = YES;
			}
			
			// don't do anything if flags are equal
			if (showSidebar != sidebarIsLoaded)
			{
				if (showSidebar)
				{
					sidebarController = [[SidebarController alloc] initWithWindowNibName:@"Sidebar"];
					[sidebarController window];
				}
				else
				{
					[sidebarController release];
				}
			}
		}
		else if ([keyPath isEqualToString:@"values.General.StatusItem.Enabled"])
		{
			if ([[NSUserDefaults standardUserDefaults] boolForKey:@"General.StatusItem.Enabled"])
				[self showStatusItem];
			else
				[self unloadStatusItem];
		}
		else if ([keyPath isEqualToString:@"values.General.Hotkey.Tagger.KeyCode"] ||
				 [keyPath isEqualToString:@"values.General.Hotkey.Tagger.Modifiers"])
		{
			[self registerHotkeyForTagger];
		}
	}
}			


#pragma mark MainMenu actions
- (BOOL)validateMenuItem:(NSMenuItem *)item
{
	// Adjust dynamic titles
	if([item action] == @selector(toggleToolbarShown:))
	{
		if([self appHasBrowser] && [[[browserController window] toolbar] isVisible])
			[item setTitle:@"Hide Toolbar"];
		else
			[item setTitle:@"Show Toolbar"];
	}

	// Check on common stuff first
	
	// Check all items that are browser-specific
	if(![self appHasBrowser])
	{			
		// File menu
		if([item action] == @selector(addTagSet:)) return NO;
		if([item action] == @selector(openFiles:)) return NO;
		if([item action] == @selector(getInfo:)) return NO;
		if([item action] == @selector(revealInFinder:)) return NO;
		
		// Edit menu
		if([item action] == @selector(delete:)) return NO;
		if([item action] == @selector(selectAll:)) return NO;
		if([item action] == @selector(findTag:)) return NO;
		if([item action] == @selector(findInResults:)) return NO;
		
		// View menu
		if([item action] == @selector(goHome:)) return NO;
		if([item action] == @selector(toggleInfoPane:)) return NO;
		if([item action] == @selector(toggleTagsPane:)) return NO;
		if([item action] == @selector(goToAllItems:)) return NO;
		if([item action] == @selector(goToManageTags:)) return NO;
		[arrangeByMenuItem setEnabled:NO];
		if([item action] == @selector(toggleFullScreen:)) return NO;
		
		if([item action] == @selector(toggleToolbarShown:)) return NO;
		if([item action] == @selector(runToolbarCustomizationPalette:)) return NO;		
	}
	
	// Check all items that are browser-specific and have constraints	
	if([self appHasBrowser])
	{
		NSResponder *firstResponder = [[browserController window] firstResponder];
		
		// File menu
		if([item action] == @selector(getInfo:))
		{
			if([firstResponder isMemberOfClass:[PAResultsOutlineView class]])
			{
				PAResultsOutlineView *ov = (PAResultsOutlineView *)firstResponder;
				if([ov numberOfSelectedItems] >= 1)
					return YES;
			}
			
			return NO;
		}
		else if([item action] == @selector(revealInFinder:))
		{
			if([firstResponder isMemberOfClass:[PAResultsOutlineView class]])
			{
				PAResultsOutlineView *ov = (PAResultsOutlineView *)firstResponder;
				if([ov numberOfSelectedItems] == 1)
					return YES;
			}
			
			return NO;
		}
		
		// Edit menu
		if([item action] == @selector(delete:))
		{
			if([firstResponder isMemberOfClass:[PAResultsOutlineView class]])
			{
				PAResultsOutlineView *ov = (PAResultsOutlineView *)firstResponder;
				if([ov numberOfSelectedItems] > 0)
					return YES;
			}
			
			if([firstResponder isMemberOfClass:[PASourcePanel class]])
			{
				PASourcePanel *sp = (PASourcePanel *)firstResponder;
				if([sp numberOfSelectedRows] > 0 &&
				   [(PASourceItem *)[sp itemAtRow:[sp selectedRow]] isEditable])
					return YES;
			}
				
			return NO;
		}
		else if([item action] == @selector(openFiles:))
		{
			if([firstResponder isMemberOfClass:[PAResultsOutlineView class]])
			{
				PAResultsOutlineView *ov = (PAResultsOutlineView *)firstResponder;
				if([ov numberOfSelectedItems] > 0)
					return YES;
			}
			
			return NO;
		}
		
		// View menu
		if([item action] == @selector(toggleInfoPane:))
		{
			if(![browserController infoPaneIsVisible])
				[item setTitle:NSLocalizedStringFromTable(@"SHOW_INFO", @"Menus", nil)];
			else
				[item setTitle:NSLocalizedStringFromTable(@"HIDE_INFO", @"Menus", nil)];
		}
		else if([item action] == @selector(toggleTagsPane:))
		{
			if(![browserController tagsPaneIsVisible])
				[item setTitle:NSLocalizedStringFromTable(@"SHOW_TAGS", @"Menus", nil)];
			else
				[item setTitle:NSLocalizedStringFromTable(@"HIDE_TAGS", @"Menus", nil)];
		}
		else if([item action] == @selector(goToAllItems:))
		{			
			PASourcePanel *sp = [browserController sourcePanel];
			if([sp selectedRow] ==	[sp rowForItem:[sp itemWithValue:@"ALL_ITEMS"]])
				[item setState:NSOnState];
			else
				[item setState:NSOffState];
		}
		else if([item action] == @selector(goToManageTags:))
		{
			PASourcePanel *sp = [browserController sourcePanel];
			if([sp selectedRow] ==	[sp rowForItem:[sp itemWithValue:@"MANAGE_TAGS"]])
				[item setState:NSOnState];
			else
				[item setState:NSOffState];
		}
		
		// View menu Lion only
		if (!RUNNING_LION && ([item action] == @selector(toggleFullScreen:)))
		{
			NSInteger separatorIdx = [[item menu] indexOfItem:item] - 1;
			[[[item menu] itemAtIndex:separatorIdx] setHidden:YES];
		}
		else if (RUNNING_LION && ([item action] == @selector(toggleFullScreen:)))
		{
			if ([[browserController window] isFullScreen])
				[item setTitle:NSLocalizedStringFromTable(@"EXIT_FULL_SCREEN", @"Menus", nil)];
			else
				[item setTitle:NSLocalizedStringFromTable(@"ENTER_FULL_SCREEN", @"Menus", nil)];
		}
		[arrangeByMenuItem setEnabled:YES];
	}
	
	return YES;
}

- (IBAction)addTagSet:(id)sender
{
	[browserController addTagSet:sender];
}

- (IBAction)goHome:(id)sender
{
	[[browserController sourcePanel] selectItemWithValue:@"ALL_ITEMS"];
	[[browserController browserViewController] reset];
}

- (IBAction)toggleInfoPane:(id)sender
{
	[browserController toggleInfoPane:sender];
	[[browserController sourcePanelStatusBar] reloadData];
}

- (IBAction)toggleTagsPane:(id)sender
{
	[browserController toggleTagsPane:sender];
	[[browserController sourcePanelStatusBar] reloadData];
}

- (IBAction)goToAllItems:(id)sender
{	
	[[browserController sourcePanel] selectItemWithValue:@"ALL_ITEMS"];
	[[browserController window] makeFirstResponder:[browserController sourcePanel]];
}

- (IBAction)goToManageTags:(id)sender
{		
	[[browserController sourcePanel] selectItemWithValue:@"MANAGE_TAGS"];
	[[browserController window] makeFirstResponder:[browserController sourcePanel]];
}

- (IBAction)arrangeBy:(id)sender
{
	NSString *type = [sender title];

	PABrowserViewMainController *mainController = [[browserController browserViewController] mainController];
	if ([mainController isKindOfClass:[PAResultsViewController class]])
	{
		PAResultsViewController *rvc = (PAResultsViewController*)mainController;
		[rvc arrangeBy:type];
		[[rvc outlineView] reloadData];
	}
}

- (IBAction)toggleResultsGrouping:(id)sender 
{
	PABrowserViewMainController *mainController = [[browserController browserViewController] mainController];
	if ([mainController isKindOfClass:[PAResultsViewController class]])
	{
		PAResultsViewController *rvc = (PAResultsViewController*)mainController;
		[rvc toggleResultsGrouping];
		[[rvc outlineView] reloadData];
	}
}

- (IBAction)showPreferences:(id)sender
{
	if (![self appHasPreferences])
	{
		preferenceController = [[PreferenceController alloc] initWithCore:self];	
	}
	
	[preferenceController showWindow:self];
	[[preferenceController window] makeKeyAndOrderFront:self];
}

- (IBAction)openFiles:(id)sender
{		
	PABrowserViewMainController *mainController = [[browserController browserViewController] mainController];

	if ([mainController isKindOfClass:[PAResultsViewController class]])
	{
		PAResultsOutlineView *ov = [(PAResultsViewController*)mainController outlineView];
	
		if([ov responder])
			[[[ov responder] target] performSelector:@selector(doubleAction)];
		else	
			[[ov target] performSelector:@selector(doubleAction:)];
	}
}

- (IBAction)delete:(id)sender
{		
	NSResponder *firstResponder = [[browserController window] firstResponder];
	
	if([firstResponder isMemberOfClass:[PAResultsOutlineView class]])
	{
		PAResultsOutlineView *ov = (PAResultsOutlineView *)firstResponder;
		[[ov target] performSelector:@selector(deleteFilesForSelectedItems:)];
	}
	
	if([firstResponder isMemberOfClass:[PASourcePanel class]])
	{
		PASourcePanel *sp = (PASourcePanel *)firstResponder;
		[sp removeSelectedItem];
		[browserController saveFavorites];
	}
}

- (IBAction)selectAll:(id)sender
{	
	PABrowserViewMainController *mainController = [[browserController browserViewController] mainController];
	
	if ([mainController isKindOfClass:[PAResultsViewController class]])
	{
		PAResultsOutlineView *ov = [(PAResultsViewController*)mainController outlineView];
		[ov selectAll:sender];
	}
}

- (IBAction)findTag:(id)sender
{
	[[browserController titleBar] performClickOnButtonWithIdentifier:@"search"];
} 

- (IBAction)findInResults:(id)sender
{
	[[browserController titleBar] performClickOnButtonWithIdentifier:@"search"];
} 

- (IBAction)showBrowser:(id)sender
{
	BOOL appHadBrowser = [self appHasBrowser];
	
	if (!appHadBrowser)
	{
		browserController = [[BrowserController alloc] init];
	}
	
	if (![self appIsActive])
		[[NSApplication sharedApplication] activateIgnoringOtherApps:YES];
	
	// Show window
	[browserController showWindow:self];
	
	if(!appHadBrowser) 
	{
		// Select all items of library
		[[browserController sourcePanel] selectItemWithValue:@"ALL_ITEMS"];	
			
		// Focus tag cloud
		[[browserController window] makeFirstResponder:[[browserController browserViewController] tagCloud]];
	}
	
	[[browserController window] makeKeyAndOrderFront:self];
}

- (IBAction)showBrowserResults:(id)sender
{
	[[browserController browserViewController] showResults];
}

- (IBAction)showBrowserManageTags:(id)sender
{
	[[browserController browserViewController] manageTags];
}

- (IBAction)toggleFullScreen:(id)sender
{
	[[browserController window] toggleFullScreen:self];
}

- (IBAction)resetBrowser:(id)sender
{
	[[browserController browserViewController] reset];
}

- (IBAction)showTagger:(id)sender
{
	[self showTagger:sender enableManageFiles:YES activatesLastActiveApp:NO];
}

- (IBAction)showTaggerActivatingLastActiveApp:(BOOL)activatesLastActiveApp
{
	[self showTagger:self enableManageFiles:YES activatesLastActiveApp:activatesLastActiveApp];
}

- (void)showTagger:(id)sender enableManageFiles:(BOOL)flag activatesLastActiveApp:(BOOL)activatesLastActiveApp
{
	TaggerController *taggerController = [self taggerController];
	
	if(!taggerController)
	{
		taggerController = [[TaggerController alloc] init];
		
		[taggerController setShowsManageFiles:flag];
		
		if(!flag)
			[taggerController resizeTokenField];
	}
	
	if (activatesLastActiveApp)
	{
		ProcessSerialNumber psn;
		GetFrontProcess(&psn);
		
		NNActiveAppSavingPanel *taggerWindow = (NNActiveAppSavingPanel*) [taggerController window];
		[taggerWindow setLastActiveApp:psn];
		[taggerWindow setActivatesLastActiveApp:YES];
	}
	
	if (![self appIsActive])
		[[NSApplication sharedApplication] activateIgnoringOtherApps:YES];
	
	[taggerController showWindow:self];	
	[[taggerController window] makeKeyAndOrderFront:self];
}

- (IBAction)showTaggerForObjects:(NSArray*)taggableObjects
{
	[self showTagger:self];
	[[self taggerController] addTaggableObjects:taggableObjects];
	[[NSApplication sharedApplication] activateIgnoringOtherApps:YES];
}

- (IBAction)openFAQ:(id)sender
{
	NSURL *url = [NSURL URLWithString:NSLocalizedStringFromTable(@"FAQ", @"Urls", nil)];
	[[NSWorkspace sharedWorkspace] openURL:url];
}

- (IBAction)openScreencast:(id)sender
{
	NSURL *url = [NSURL URLWithString:NSLocalizedStringFromTable(@"SCREENCAST", @"Urls", nil)];
	[[NSWorkspace sharedWorkspace] openURL:url];
}

- (IBAction)openWebsite:(id)sender
{
	NSURL *url = [NSURL URLWithString:NSLocalizedStringFromTable(@"PUNAKEA", @"Urls", nil)];
	[[NSWorkspace sharedWorkspace] openURL:url];
}

- (IBAction)cleanTagDB:(id)sender
{
	BusyWindowController *busyWindowController = [[self busyWindow] delegate];
	
	[busyWindowController setMessage:NSLocalizedStringFromTable(@"BUSY_WINDOW_MESSAGE_REBUILDING_TAG_DB", @"FileManager", nil)];
	[busyWindowController performBusySelector:@selector(cleanTagDB)
									 onObject:[NNTagging tagging]];
	
	[[self busyWindow] center];
	[NSApp runModalForWindow:[self busyWindow]];
}

- (IBAction)getInfo:(id)sender
{
	PAResultsOutlineView *ov = (PAResultsOutlineView *)[[browserController window] firstResponder];
	
	for (NNFile *file in [ov selectedItems])
	{
		NSString *s = @"tell application \"Finder\"\n";
		
		s = [s stringByAppendingString:@"set p to \""];
		s = [s stringByAppendingString:[file path]];
		s = [s stringByAppendingString:@"\"\n"];
		
		s = [s stringByAppendingString:@"set f to POSIX file p as string\n"];
		
		s = [s stringByAppendingString:@"activate\n"];
		s = [s stringByAppendingString:@"open information window of alias f\n"];
		
		s = [s stringByAppendingString:@"end tell"];
		
		NSAppleScript *folderActionScript = [[NSAppleScript alloc] initWithSource:s];
		[folderActionScript executeAndReturnError:nil];
	}
}

- (IBAction)revealInFinder:(id)sender
{
	[[browserController rightStatusBar] revealInFinder:self];
}

- (IBAction)importFolder:(id)sender
{
	NSOpenPanel *openPanel = [NSOpenPanel openPanel];
	[openPanel setCanChooseDirectories:YES];
	
	NSButton *checkBox = [[NSButton alloc] initWithFrame:NSMakeRect(0.0, 0.0, 25.0, 10.0)];
	NSButtonCell *checkBoxCell = [checkBox cell];
	[checkBoxCell setButtonType:NSSwitchButton];
	[checkBoxCell setTitle:NSLocalizedStringFromTable(@"MOVE_FILES_ON_IMPORTING",@"FileManager",@"")];
	
	// set checkbox according to userDefaults
	if ([userDefaults boolForKey:@"ManageFiles.ManagedFolder.Enabled"])
	{
		[checkBoxCell setState:NSOnState];
	}	
	
	[checkBox sizeToFit];
	[openPanel setAccessoryView:checkBox];
	[checkBox release];
	
	if ([openPanel runModal] == NSOKButton)
	{
		NSArray *filenames = [openPanel filenames];
		
		NNFolderToTagImporter *importer = [[NNFolderToTagImporter alloc] init];
				
		NSButton *accessoryView = (NSButton*) [openPanel accessoryView];
		
		if ([accessoryView state] == NSOnState)
		{
			[importer setManagesFiles:YES];
		}
		
		BusyWindowController *bwc = [[self busyWindow] delegate];
		
		[bwc setMessage:NSLocalizedStringFromTable(@"BUSY_WINDOW_MESSAGE_IMPORTING_FOLDER",@"FileManager",@"")];
		[bwc performBusySelector:@selector(importPath:)
						onObject:importer
					  withObject:[filenames objectAtIndex:0]];
		
		[busyWindow center];
		[NSApp runModalForWindow:busyWindow];
	}
}

- (IBAction)toggleToolbarShown:(id)sender
{
	[self showBrowser:self];
	[[browserController window] toggleToolbarShown:sender];
}

- (IBAction)runToolbarCustomizationPalette:(id)sender
{
	[self showBrowser:self];
	[[browserController window] runToolbarCustomizationPalette:sender];
}

#pragma mark Misc
- (IBAction)searchForTags:(NSArray*)someTags
{
	[self showBrowser:self];
	[[browserController browserViewController] searchForTags:someTags];
}

#pragma mark NSApplication Delegate
- (BOOL)applicationShouldHandleReopen:(NSApplication *)theApplication hasVisibleWindows:(BOOL)flag
{
	[self showBrowser:self];
	return YES;
}

- (BOOL)application:(NSApplication *)theApplication openFile:(NSString *)filename
{
	// accept every file
	[self application:theApplication openFiles:[NSArray arrayWithObject:filename]];
	return YES;
}

- (void)application:(NSApplication *)sender openFiles:(NSArray *)filenames
{
	[self showTagger:self];
	[[self taggerController] setTaggableObjects:[NNFile filesWithFilepaths:filenames]];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	// Ensure all necessary directories are ready
	[self createDirectoriesIfNeeded:YES generateContent:YES];
}

//#pragma mark debug
//- (void)keyDown:(NSEvent*)event 
//{
//	NSLog(@"NSApp keydown: %@",event);
//}

#pragma mark Helpers
- (void)createDirectoriesIfNeeded
{
	[self createDirectoriesIfNeeded:YES generateContent:NO];
}

- (void)createDirectoriesIfNeeded:(BOOL)flag generateContent:(BOOL)generateContent
{
	NSFileManager *fileManager = [NSFileManager defaultManager];
	BOOL isDirectory = NO;
	NSString *dir = nil;
	
	BOOL success;
	NSError *error;
	
	// Managed Folder
	if ([userDefaults boolForKey:@"ManageFiles.ManagedFolder.Enabled"])
	{	
		dir = [userDefaults stringForKey:@"ManageFiles.ManagedFolder.Location"];
		dir = [dir stringByStandardizingPath];		
		
		if ([fileManager fileExistsAtPath:dir isDirectory:&isDirectory])
		{
			if (!isDirectory)
			{
				[self displayWarningWithMessage:[NSString stringWithFormat:
												 NSLocalizedStringFromTable(@"DESTINATION_NOT_FOLDER_ERROR", @"FileManager", @""), dir]];
			}
		}
		else
		{
			[fileManager createDirectoryAtPath:dir withIntermediateDirectories:YES attributes:nil error:NULL];
		}
	}
	
	// Tags Folder
	if ([userDefaults boolForKey:@"ManageFiles.TagsFolder.Enabled"])
	{	
		dir = [userDefaults stringForKey:@"ManageFiles.TagsFolder.Location"];
		dir = [dir stringByStandardizingPath];		
		
		if ([fileManager fileExistsAtPath:dir isDirectory:&isDirectory])
		{
			if (!isDirectory)
			{
				[self displayWarningWithMessage:[NSString stringWithFormat:
												 NSLocalizedStringFromTable(@"DESTINATION_NOT_FOLDER_ERROR", @"FileManager", @""), dir]];
			}
		}
		else
		{
			[fileManager createDirectoryAtPath:dir withIntermediateDirectories:YES attributes:nil error:NULL];
			
			// make sure the directory is writable before setting the icon
			NSDictionary *writableAttributes = [NSDictionary dictionaryWithObject:[NSNumber numberWithLong:448]
																		   forKey:NSFilePosixPermissions];
			success = [fileManager setAttributes:writableAttributes
									ofItemAtPath:dir
										   error:&error];
			
			// set the icon
			[[NSWorkspace sharedWorkspace] setIcon:[NSImage imageNamed:@"TagFolder"] 
										   forFile:dir
										   options:NSExclude10_4ElementsIconCreationOption];
		
			if(generateContent)
			{
				// Generate folder hierarchy from scratch
				BusyWindowController *busyWindowController = [busyWindow delegate];
				
				[busyWindowController setMessage:NSLocalizedStringFromTable(@"BUSY_WINDOW_MESSAGE_REBUILDING_TAGS_FOLDER", @"FileManager", nil)];
				[busyWindowController performBusySelector:@selector(createDirectoryStructure)
												 onObject:[NNTagging tagging]];
				
				[busyWindow center];
				[NSApp runModalForWindow:busyWindow];
			}
		}
	}
	
	// Drop Box
	if ([userDefaults boolForKey:@"ManageFiles.DropBox.Enabled"])
	{	
		dir = [userDefaults stringForKey:@"ManageFiles.DropBox.Location"];
		dir = [dir stringByStandardizingPath];		
		
		if ([fileManager fileExistsAtPath:dir isDirectory:&isDirectory])
		{
			if (!isDirectory)
			{
				[self displayWarningWithMessage:[NSString stringWithFormat:
												 NSLocalizedStringFromTable(@"DESTINATION_NOT_FOLDER_ERROR", @"FileManager", @""), dir]];
			}
		}
		else
		{
			[fileManager createDirectoryAtPath:dir withIntermediateDirectories:YES attributes:nil error:NULL];
		}
	}
}

- (void)displayWarningWithMessage:(NSString*)messageInfo
{
	NSAlert *alert = [[[NSAlert alloc] init] autorelease];
	[alert setMessageText:NSLocalizedStringFromTable(@"ERROR",@"Global",@"")];
	[alert setInformativeText:messageInfo];
	[alert addButtonWithTitle:NSLocalizedStringFromTable(@"OK",@"Global",@"")];
	
	[alert setAlertStyle:NSWarningAlertStyle];
	
	[alert beginSheetModalForWindow:nil
					  modalDelegate:self 
					 didEndSelector:@selector(alertDidEnd:returnCode:contextInfo:)
						contextInfo:nil];
}

- (void)alertDidEnd:(NSAlert *)alert returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo
{
	// terminate app (no path was found)
	[[NSApplication sharedApplication] terminate:self];
}

+ (BOOL)wasLaunchedAsLoginItem
{
	// If the launching process was 'loginwindow', we were launched as a
	// login item
	return [self wasLaunchedByProcess:@"lgnw"];
}

+ (BOOL)wasLaunchedByProcess:(NSString*)creator
{
	BOOL    wasLaunchedByProcess = NO;
	
	// Get our PSN
	OSStatus    err;
	ProcessSerialNumber    currPSN;
	err = GetCurrentProcess (&currPSN);
	if (!err) {
		// Get information about our process
		NSDictionary* currDict = (NSDictionary*)ProcessInformationCopyDictionary (&currPSN,kProcessDictionaryIncludeAllInformationMask);
		
		// Get the PSN of the app that *launched* us.  Its not really the
		// parent app, in the unix sense.
		long long    temp = [[currDict objectForKey:@"ParentPSN"] longLongValue];
		[currDict release];
		ProcessSerialNumber    parentPSN = {(temp >> 32) & 0x00000000FFFFFFFFLL,
			(temp >> 0) & 0x00000000FFFFFFFFLL};
		
		// Get info on the launching process
		NSDictionary*    parentDict = (NSDictionary*)ProcessInformationCopyDictionary (&parentPSN,kProcessDictionaryIncludeAllInformationMask);
		
		// Test the creator code of the launching app
		wasLaunchedByProcess = [[parentDict objectForKey:@"FileCreator"] isEqualToString:creator];
		[parentDict release];
	}
	
	return wasLaunchedByProcess;
}

- (BOOL)appHasBrowser
{
	BOOL hasBrowser = NO;
	
	NSArray *windows = [[NSApplication sharedApplication] windows];
	
	NSEnumerator *e = [windows objectEnumerator];
	NSWindow *window;
	
	while (window = [e nextObject])
	{
		if ([window delegate] && [[window delegate] isKindOfClass:[BrowserController class]])
			hasBrowser = YES;
	}
	
	return hasBrowser;
}

- (BOOL)appHasPreferences
{
	BOOL hasPreferences = NO;
	
	NSArray *windows = [[NSApplication sharedApplication] windows];
	
	NSEnumerator *e = [windows objectEnumerator];
	NSWindow *window;
	
	while (window = [e nextObject])
	{
		if ([window delegate] && [[window delegate] isKindOfClass:[PreferenceController class]])
			hasPreferences = YES;
	}
	
	return hasPreferences;
}

- (BOOL)appIsActive
{
	NSDictionary *activeAppDict = [[NSWorkspace sharedWorkspace] activeApplication];
	NSString *strApplicationBundleIdentifier = [activeAppDict objectForKey:@"NSApplicationBundleIdentifier"];
	
	return ([strApplicationBundleIdentifier isEqualToString:[[NSBundle mainBundle] bundleIdentifier]]);
}

- (void)loadUserDefaults
{	
	NSString *path = [[NSBundle mainBundle] pathForResource:@"UserDefaults" ofType:@"plist"];
	NSDictionary *appDefaults = [NSDictionary dictionaryWithContentsOfFile:path];
	
	[userDefaults registerDefaults:appDefaults];
	
	// Check for Version Information of User Defaults
	NSInteger currentVersion = [userDefaults integerForKey:@"Version"];	
	if (currentVersion == 0)
	{
		// Below v0.4 there was no version information available!		
		
		NSDate *suLastCheckTime = [userDefaults objectForKey:@"SULastCheckTime"];
		
		if(suLastCheckTime) {
			// The current defaults are v1
			[self updateUserDefaultsToVersion:2];
		} else {
			// Mark defaults as being v2
			[userDefaults setObject:[NSNumber numberWithInteger:2] forKey:@"Version"];
		}
	}
}

- (void)loadQuickLookFramework 
{
	NSUInteger major = 0;
	NSUInteger minor = 0;
	NSUInteger bugFix = 0;
	
	[NSApp getSystemVersionMajor:&major
						   minor:&minor
						  bugFix:&bugFix];
	
	NSString *qlFrameworkPath;
	
	if (minor < 5 ) 
	{
		// pre-leopard do nothing
		return;
	}
	
	if (minor == 5) 
	{
		qlFrameworkPath = [NSString stringWithString:@"/System/Library/PrivateFrameworks/QuickLookUI.framework"];
	} 
	else if (minor >= 6)
	{
		qlFrameworkPath = [NSString stringWithString:@"/System/Library/Frameworks/Quartz.framework/Frameworks/QuickLookUI.framework"];
	}
	
	NSBundle *qlFrameworkBundle = [NSBundle bundleWithPath:qlFrameworkPath];
	[qlFrameworkBundle load];
}

- (void)updateUserDefaultsToVersion:(NSInteger)newVersion 
{
	// Unfortunately, valueForKeyPath does NOT work for NSUserController.
	// Chained valueForKey calls do, though... WHAT?!? ;)
	// So we keep this ugly pseudo-hierarchical structure for now...
	
	NSString *key;
	
	if(newVersion == 2)
	{	
		// General		
		key = @"Appearance.SidebarPosition";
		NSInteger intValue = [userDefaults integerForKey:key];
		[userDefaults removeObjectForKey:key];						
		[userDefaults setValue:[NSNumber numberWithInteger:intValue] forKey:@"General.Sidebar.Position"];
		
		key = @"General.LoadSidebar";
		BOOL boolValue = [userDefaults boolForKey:key];
		[userDefaults removeObjectForKey:key];						
		[userDefaults setValue:[NSNumber numberWithBool:boolValue] forKey:@"General.Sidebar.Enabled"];
				
		key = @"General.LoadStatusItem";
		boolValue = [userDefaults boolForKey:key];
		[userDefaults removeObjectForKey:key];	
		[userDefaults setValue:[NSNumber numberWithBool:boolValue] forKey:@"General.StatusItem.Enabled"];	
		
		// Manage Files
		key = @"General.ManageFiles";
		boolValue = [userDefaults boolForKey:key];
		[userDefaults removeObjectForKey:key];	
		[userDefaults setValue:[NSNumber numberWithBool:boolValue] forKey:@"ManageFiles.ManagedFolder.Enabled"];
		
		key = @"General.ManagedFilesLocation";
		NSString *strValue = [userDefaults stringForKey:key];
		if(!strValue) strValue = @"~/Documents/punakea files";
		[userDefaults removeObjectForKey:key];	
		[userDefaults setValue:strValue forKey:@"ManageFiles.ManagedFolder.Location"];
		
		// Update Version Info	
		// This may not be moved to UserDefaults.plist as a default value, as it is then not
		// output to the preferences file!
		[userDefaults setObject:[NSNumber numberWithInteger:2] forKey:@"Version"];
		
	} else
	{
		[NSException raise:NSInvalidArgumentException format:@"User Defaults can only be updated from v1 to v2!"];
	}
}


#pragma mark Accessors
- (BrowserController *)browserController
{
	return [self appHasBrowser] ? browserController : nil;
}

- (TaggerController *)taggerController
{
	_taggerController = nil;
	
	NSArray *windows = [[NSApplication sharedApplication] windows];
	
	NSEnumerator *e = [windows objectEnumerator];
	NSWindow *window;
	
	while (window = [e nextObject])
	{
		if ([window delegate] && [[window delegate] isKindOfClass:[TaggerController class]])
			_taggerController = [window delegate];
	}
	
	return _taggerController;
}

- (NSWindow *)busyWindow
{
	return busyWindow;
}

- (NSMenuItem*)arrangeByMenuItem
{
	return arrangeByMenuItem;
}

@end
