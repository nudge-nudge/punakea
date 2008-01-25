#import "Core.h"

@interface Core (PrivateAPI)

- (void)setupToolbar;
- (void)showStatusItem;

- (void)displayWarningWithMessage:(NSString*)messageInfo;
- (void)createManagedFilesDirIfNeeded;

- (void)showTagger:(id)sender enableManageFiles:(BOOL)flag;

- (void)applicationWillTerminate:(NSNotification *)note;

+ (BOOL)wasLaunchedAsLoginItem;
+ (BOOL)wasLaunchedByProcess:(NSString*)creator;

- (BOOL)appHasPreferences;
- (BOOL)appIsActive;

- (void)loadUserDefaults;
- (void)updateUserDefaultsToVersion:(int)newVersion;

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
}

- (id)init
{
    if (self = [super init])
    {
		[PAInstaller install];
		
		globalTags = [NNTags sharedTags];
		
		userDefaults = [NSUserDefaults standardUserDefaults];
		[self loadUserDefaults];
		
		printf("Punakea compiled on %s at %s\n",__DATE__,__TIME__);
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
	
	[self createManagedFilesDirIfNeeded];
	
	// load services class and set as service provides
	services =  [[PAServices alloc] init];
	[NSApp setServicesProvider:services];
	
	// DEBUG
	//[[PANotificationReceiver alloc] init];
}

- (void)dealloc
{
	[services release];
	
	[statusMenu release];
	
	NSUserDefaultsController *udc = [NSUserDefaultsController sharedUserDefaultsController];
	
	[udc removeObserver:self forKeyPath:@"values.General.Sidebar.Enabled"];
	[udc removeObserver:self forKeyPath:@"values.General.StatusItem.Enabled"];
	
	[preferenceController release];
	[nc removeObserver:self];
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
		[fileManager createDirectoryAtPath: folder attributes: nil];
		
	return [folder stringByAppendingPathComponent:fileName]; 
}

#pragma mark events
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{	
	if ((object == [NSUserDefaultsController sharedUserDefaultsController]) && [keyPath isEqualToString:@"values.General.Sidebar.Enabled"])
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
	else if ((object == [NSUserDefaultsController sharedUserDefaultsController]) && [keyPath isEqualToString:@"values.General.StatusItem.Enabled"])
	{
		if ([[NSUserDefaults standardUserDefaults] boolForKey:@"General.StatusItem.Enabled"])
			[self showStatusItem];
		else
			[self unloadStatusItem];
	}
}			

- (void)createManagedFilesDirIfNeeded
{
	if (![userDefaults boolForKey:@"ManageFiles.ManagedFolder.Enabled"])
		return;
	
	// create managed files dir if needed
	NSString *managedFilesDir = [userDefaults stringForKey:@"ManageFiles.ManagedFolder.Location"];
	NSString *standardizedDir = [managedFilesDir stringByStandardizingPath];
	
	NSFileManager *fileManager = [NSFileManager defaultManager];
	BOOL isDirectory;
	
	if ([fileManager fileExistsAtPath:standardizedDir isDirectory:&isDirectory])
	{
		if (!isDirectory)
		{
			[self displayWarningWithMessage:[NSString stringWithFormat:
				NSLocalizedStringFromTable(@"MANAGED_FILES_DESTINATION_NOT_FOLDER_ERROR",@"FileManager",@""),standardizedDir]];
		}
	}
	else
	{
		[fileManager createDirectoryAtPath:standardizedDir
								attributes:nil];
	}
}

#pragma mark MainMenu actions
- (BOOL)validateMenuItem:(id <NSMenuItem>)item
{
	// Adjust dynamic titles
	if([item action] == @selector(toggleToolbarShown:))
	{
		if([self appHasBrowser] && [[[browserController window] toolbar] isVisible])
			[item setTitle:@"Hide Toolbar"];
		else
			[item setTitle:@"Show Toolbar"];
	}	
	
	// Check all items that are browser-specific
	if(![self appHasBrowser])
	{
		// File menu
		if([item action] == @selector(addTagSet:)) return NO;
		if([item action] == @selector(openFiles:)) return NO;
		if([item action] == @selector(editTagsOnFiles:)) return NO;
		
		// Edit menu
		if([item action] == @selector(delete:)) return NO;
		if([item action] == @selector(tagSearch:)) return NO;
		if([item action] == @selector(selectAll:)) return NO;
		
		// View menu
		if([item action] == @selector(goHome:)) return NO;
		if([item action] == @selector(toggleInfo:)) return NO;
		if([item action] == @selector(goToAllItems:)) return NO;
		if([item action] == @selector(goToManageTags:)) return NO;
		if([item action] == @selector(toggleToolbarShown:)) return NO;
		if([item action] == @selector(runToolbarCustomizationPalette:)) return NO;		
	}
	
	// Check all items that are browser-specific and have constraints	
	if([self appHasBrowser])
	{
		NSResponder *firstResponder = [[browserController window] firstResponder];
		
		// Edit menu
		if([item action] == @selector(delete:))
		{
			if([firstResponder isMemberOfClass:[PAResultsOutlineView class]])
			{
				PAResultsOutlineView *ov = (PAResultsOutlineView *)firstResponder;
				if([ov numberOfSelectedRows] > 0)
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
		else if([item action] == @selector(openFiles:) ||
				[item action] == @selector(editTagsOnFiles:))
		{
			if([firstResponder isMemberOfClass:[PAResultsOutlineView class]])
			{
				PAResultsOutlineView *ov = (PAResultsOutlineView *)firstResponder;
				if([ov numberOfSelectedRows] > 0)
					return YES;
			}
			
			return NO;
		}
		
		// View menu
		if([item action] == @selector(toggleInfo:))
		{
			NSView *subview = [[[browserController horizontalSplitView] subviews] objectAtIndex:1];
			if([subview isHidden])
				[item setTitle:NSLocalizedStringFromTable(@"MAINMENU_SHOW_INFO", @"Menus", nil)];
			else
				[item setTitle:NSLocalizedStringFromTable(@"MAINMENU_HIDE_INFO", @"Menus", nil)];
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

- (IBAction)toggleInfo:(id)sender
{
	[[browserController horizontalSplitView] toggleSubviewAtIndex:1];
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
		[[ov target] performSelector:@selector(deleteFilesForVisibleSelectedItems:)];
	}
	
	if([firstResponder isMemberOfClass:[PASourcePanel class]])
	{
		PASourcePanel *sp = (PASourcePanel *)firstResponder;
		[sp removeSelectedItem];
		[browserController saveFavorites];
	}
}

- (IBAction)editTagsOnFiles:(id)sender
{	
	[self showTagger:self enableManageFiles:NO];
	
	PABrowserViewMainController *mainController = [[browserController browserViewController] mainController];
	
	if ([mainController isKindOfClass:[PAResultsViewController class]])
	{
		PAResultsOutlineView *ov = [(PAResultsViewController*)mainController outlineView];
	
		[[self taggerController] setTaggableObjects:[ov visibleSelectedItems]];
		[ov reloadData];
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

- (IBAction)tagSearch:(id)sender
{
	// Make sure browser toolbar is visible
	NSToolbar *toolbar = [[browserController window] toolbar];	
	if(![toolbar isVisible])
		[toolbar setVisible:YES];
	
	// Make search field the first responder if its toolbar item is visible
	NSEnumerator *e = [[toolbar items] objectEnumerator];
	NSToolbarItem *item;
	while(item = [e nextObject])
	{
		if([[item view] isKindOfClass:[NSSearchField class]])
		{
			[[browserController window] makeFirstResponder:[item view]];
			return;
		}
	}
} 

- (IBAction)showBrowser:(id)sender
{
	if (![self appHasBrowser])
	{
		browserController = [[BrowserController alloc] init];
	}
	
	if (![self appIsActive])
		[[NSApplication sharedApplication] activateIgnoringOtherApps:YES];
	
	[browserController showWindow:self];
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

- (IBAction)resetBrowser:(id)sender
{
	[[browserController browserViewController] reset];
}

- (IBAction)showTagger:(id)sender
{
	[self showTagger:sender enableManageFiles:YES];
}

- (void)showTagger:(id)sender enableManageFiles:(BOOL)flag
{
	TaggerController *taggerController = [self taggerController];
	
	if(!taggerController)
	{
		taggerController = [[TaggerController alloc] init];
		
		[taggerController setShowsManageFiles:flag];
		
		if(!flag)
			[taggerController resizeTokenField];
	}
	
	if (![self appIsActive])
		[[NSApplication sharedApplication] activateIgnoringOtherApps:YES];
	
	[taggerController showWindow:self];	
	[[taggerController window] makeKeyAndOrderFront:self];
}

- (IBAction)showTaggerForObjects:(NSArray*)taggableObjects
{
	[self showTagger:self];
	[[self taggerController] setTaggableObjects:taggableObjects];
	[[NSApplication sharedApplication] activateIgnoringOtherApps:YES];
}

- (IBAction)openWebsite:(id)sender
{
	[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://www.nudgenudge.eu/punakea"]];
}

- (IBAction)openDonationWebsite:(id)sender
{
	[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://www.nudgenudge.eu/donate"]];
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

#pragma mark NSApplication delegate
- (BOOL)applicationShouldHandleReopen:(NSApplication *)theApplication hasVisibleWindows:(BOOL)flag
{
	[self showBrowser:self];
	return YES;
}

- (void)applicationDidBecomeActive:(NSNotification *)aNotification
{
	// do not do anything if mouse is in sidebar
	if ([sidebarController mouseInSidebarWindow])
		return;
	
	NSArray *windows = [[NSApplication sharedApplication] windows];

	NSEnumerator *e = [windows objectEnumerator];
	NSWindow *window;
	
	NSWindow *lastTaggerWindow = nil;
	
	while (window = [e nextObject])
	{
		if ([[window title] isEqualTo:@"Punakea : Tagger"])
		{
			[window orderFront:self];
			lastTaggerWindow = window;
		}
		
		if	([[window title] isEqualTo:@"Punakea : Browser"] ||
			[[window title] hasPrefix:@"Preferences :"])
		{
			[window orderFront:self];
		}
	}
	
	// if tagger window exists, make key, otherwise make browser key (if exists)
	if (lastTaggerWindow)
		[lastTaggerWindow makeKeyAndOrderFront:self];
	else if ([self appHasBrowser])
		[self showBrowser:self];
	
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

//#pragma mark debug
//- (void)keyDown:(NSEvent*)event 
//{
//	NSLog(@"NSApp keydown: %@",event);
//}

#pragma mark helper
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

- (void)alertDidEnd:(NSAlert *)alert returnCode:(int)returnCode contextInfo:(void *)contextInfo
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
	int currentVersion = [userDefaults integerForKey:@"Version"];	
	if (currentVersion == 0)
	{
		// Below v0.4 there was no version information available!		
		
		NSDate *suLastCheckTime = [userDefaults objectForKey:@"SULastCheckTime"];
		
		if(suLastCheckTime) {
			// The current defaults are v1
			[self updateUserDefaultsToVersion:2];
		} else {
			// Mark defaults as being v2
			[userDefaults setObject:[NSNumber numberWithInt:2] forKey:@"Version"];
		}
	}
}

- (void)updateUserDefaultsToVersion:(int)newVersion 
{
	// Unfortunately, valueForKeyPath does NOT work for NSUserController.
	// Chained valueForKey calls do, though... WHAT?!? ;)
	// So we keep this ugly pseudo-hierarchical structure for now...
	
	NSString *key;
	
	if(newVersion == 2)
	{	
		// General		
		key = @"Appearance.SidebarPosition";
		int intValue = [userDefaults integerForKey:key];
		[userDefaults removeObjectForKey:key];						
		[userDefaults setValue:[NSNumber numberWithInt:intValue] forKey:@"General.Sidebar.Position"];
		
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
		[userDefaults setObject:[NSNumber numberWithInt:2] forKey:@"Version"];
		
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

@end
