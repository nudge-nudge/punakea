#import "Core.h"

@interface Core (PrivateAPI)

- (void)setupToolbar;
- (void)showStatusItem;

- (void)displayWarningWithMessage:(NSString*)messageInfo;
- (void)createManagedFilesDirIfNeeded;

- (void)applicationWillTerminate:(NSNotification *)note;

+ (BOOL)wasLaunchedAsLoginItem;
+ (BOOL)wasLaunchedByProcess:(NSString*)creator;

- (BOOL)appHasTagger;
- (BOOL)appHasPreferences;

@end

@implementation Core

#pragma mark init + dealloc
+ (void)initialize
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

	NSString *path = [[NSBundle mainBundle] pathForResource:@"UserDefaults" ofType:@"plist"];
	NSDictionary *appDefaults = [NSDictionary dictionaryWithContentsOfFile:path];
	[defaults registerDefaults:appDefaults];
	
	// register value transformers
	PACollectionNotEmpty *collectionNotEmpty = [[[PACollectionNotEmpty alloc] init] autorelease];
	[NSValueTransformer setValueTransformer:collectionNotEmpty
									forName:@"PACollectionNotEmpty"];
}

- (id)init
{
    if (self = [super init])
    {
		globalTags = [NNTags sharedTags];
		
		userDefaults = [NSUserDefaults standardUserDefaults];
		
		printf("compiled on %s at %s\n",__DATE__,__TIME__);
	}
    return self;
}

- (void)awakeFromNib
{
	[NSApp setDelegate:self]; 
	[self setupToolbar];
	
	if (![Core wasLaunchedAsLoginItem])
	{
		[self showBrowser:self];
	}
	
	if ([userDefaults boolForKey:@"General.LoadSidebar"])
	{
		sidebarController = [[SidebarController alloc] initWithWindowNibName:@"Sidebar"];
		[sidebarController window];
	}
	
	if ([userDefaults boolForKey:@"General.LoadStatusItem"])
	{
		[self showStatusItem];
	}
	
	NSUserDefaultsController *udc = [NSUserDefaultsController sharedUserDefaultsController];
	
	// listen for sidebar pref changes
	[udc addObserver:self 
		  forKeyPath:@"values.General.LoadSidebar" 
			 options:0 
			 context:NULL];
	
	// listen for status item pref changes
	[udc addObserver:self 
		  forKeyPath:@"values.General.LoadStatusItem" 
			 options:0 
			 context:NULL];
	
	[self createManagedFilesDirIfNeeded];
}

- (void)dealloc
{
	[statusMenu release];
	
	NSUserDefaultsController *udc = [NSUserDefaultsController sharedUserDefaultsController];
	
	[udc removeObserver:self forKeyPath:@"values.General.LoadSidebar"];
	[udc removeObserver:self forKeyPath:@"values.General.LoadStatusItem"];
	
	[preferenceController release];
	[nc removeObserver:self];
    [super dealloc];
}

- (void)applicationWillTerminate:(NSNotification *)note 
{ 
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

#pragma mark events
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{	
	if ((object == [NSUserDefaultsController sharedUserDefaultsController]) && [keyPath isEqualToString:@"values.General.LoadSidebar"])
	{
		BOOL showSidebar = [[NSUserDefaults standardUserDefaults] boolForKey:@"General.LoadSidebar"];
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
	else if ((object == [NSUserDefaultsController sharedUserDefaultsController]) && [keyPath isEqualToString:@"values.General.LoadStatusItem"])
	{
		if ([[NSUserDefaults standardUserDefaults] boolForKey:@"General.LoadStatusItem"])
			[self showStatusItem];
		else
			[self unloadStatusItem];
	}
}			

- (void)createManagedFilesDirIfNeeded
{
	if (![userDefaults boolForKey:@"General.ManageFiles"])
		return;
	
	// create managed files dir if needed
	NSString *managedFilesDir = [userDefaults stringForKey:@"General.ManagedFilesLocation"];
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
		if([[[browserController window] toolbar] isVisible])
			[item setTitle:@"Hide Toolbar"];
		else
			[item setTitle:@"Show Toolbar"];
	}	
	
	// Check all items that are browser-specific
	if(![self appHasBrowser])
	{
		// File menu
		if([item action] == @selector(openFiles:)) return NO;
		
		// Edit menu
		if([item action] == @selector(delete:)) return NO;
		if([item action] == @selector(editTagsOnFiles:)) return NO;
		if([item action] == @selector(selectAll:)) return NO;
		
		// View menu
		if([item action] == @selector(showResults:)) return NO;
		if([item action] == @selector(manageTags:)) return NO;
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
	}
	
	return YES;
}

- (IBAction)showResults:(id)sender
{	
	[[browserController browserViewController] showResults];
	[[viewMenu itemWithTag:0] setState:NSOnState];
	[[viewMenu itemWithTag:1] setState:NSOffState];
}

- (IBAction)manageTags:(id)sender
{		
	[[browserController browserViewController] manageTags];
	[[viewMenu itemWithTag:0] setState:NSOffState];
	[[viewMenu itemWithTag:1] setState:NSOnState];
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
	}
}

- (IBAction)editTagsOnFiles:(id)sender
{	
	TaggerController *taggerController = [[TaggerController alloc] init];
	[taggerController showWindow:self];
	NSWindow *taggerWindow = [taggerController window];
	[taggerWindow makeKeyAndOrderFront:nil];
	
	PABrowserViewMainController *mainController = [[browserController browserViewController] mainController];
	
	if ([mainController isKindOfClass:[PAResultsViewController class]])
	{
		PAResultsOutlineView *ov = [(PAResultsViewController*)mainController outlineView];
	
		[taggerController addTaggableObjects:[ov visibleSelectedItems]];
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
	[browserController showWindow:self];
	[[browserController window] makeKeyAndOrderFront:self];
}

- (IBAction)showTagger:(id)sender
{
	/*
	// Implementation of multiple tagger windows 
	
	TaggerController *taggerController = [[TaggerController alloc] init];
	[taggerController showWindow:self];
	NSWindow *taggerWindow = [taggerController window];
	[taggerWindow makeKeyAndOrderFront:nil];*/
	
	// Implementation of single tagger window
	
	if(![self appHasTagger])
	{
		taggerController =  [[TaggerController alloc] init];
	}
	[taggerController showWindow:self];
	[[taggerController window] makeKeyAndOrderFront:self];
}

- (IBAction)showWebsite:(id)sender
{
	[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://www.nudgenudge.eu/punakea"]];
}

- (IBAction)showDonationWebsite:(id)sender
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

- (IBAction)searchForTag:(NNTag*)aTag
{
	[self showBrowser:self];
	[[browserController browserViewController] searchForTag:aTag];
}


#pragma mark NSApplication delegate
- (BOOL)applicationShouldHandleReopen:(NSApplication *)theApplication hasVisibleWindows:(BOOL)flag
{
	[self showBrowser:self];
	return YES;
}

- (void)applicationDidBecomeActive:(NSNotification *)aNotification
{
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
	TaggerController *taggerController = [[TaggerController alloc] init];
	[taggerController showWindow:self];
	NSWindow *taggerWindow = [taggerController window];
	[taggerController addTaggableObjects:[NNFile filesWithFilepaths:filenames]];
	[taggerWindow makeKeyAndOrderFront:nil];
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

- (BOOL)appHasTagger
{
	BOOL hasTagger = NO;
	
	NSArray *windows = [[NSApplication sharedApplication] windows];
	
	NSEnumerator *e = [windows objectEnumerator];
	NSWindow *window;
	
	while (window = [e nextObject])
	{
		if ([window delegate] && [[window delegate] isKindOfClass:[TaggerController class]])
			hasTagger = YES;
	}
	
	return hasTagger;
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

@end
