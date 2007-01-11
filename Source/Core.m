#import "Core.h"

@interface Core (PrivateAPI)

- (void)selectedTagsHaveChanged;
- (void)relatedTagsHaveChanged;
- (void)allTagsHaveChanged;
- (PATag*)tagWithBestAbsoluteRating:(NSArray*)tagSet;
- (void)setupToolbar;
- (void)displayWarningWithMessage:(NSString*)messageInfo;
- (void)createManagedFilesDirIfNeeded;

+ (BOOL)wasLaunchedAsLoginItem;
+ (BOOL)wasLaunchedByProcess:(NSString*)creator;

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
	
	//[[PANotificationReceiver alloc] init];
}

- (id)init
{
    if (self = [super init])
    {
		globalTags = [PATags sharedTags];
		[self loadDataFromDisk];
		
		tagSave = [[PATagSave alloc] init];
		
		nc = [NSNotificationCenter defaultCenter];
		[nc addObserver:self selector:@selector(tagsHaveChanged:) name:nil object:globalTags];
		
		printf("compiled on %s at %s\n",__DATE__,__TIME__);
	}
    return self;
}

- (void)dealloc
{
	[tagSave release];
	[preferenceController release];
	[nc removeObserver:self];
    [super dealloc];
}

- (void)awakeFromNib
{
	[NSApp setDelegate:self]; 
	[self setupToolbar];
		
	if (![Core wasLaunchedAsLoginItem])
	{
		[self showBrowser:self];
	}
	
	SidebarController *sidebarController = [[SidebarController alloc] initWithWindowNibName:@"Sidebar"];
	[sidebarController window];
	
	[self createManagedFilesDirIfNeeded];
}

- (void)applicationWillTerminate:(NSNotification *)note 
{ 
	[[NSUserDefaults standardUserDefaults] synchronize];
	[self saveDataToDisk]; 
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

#pragma mark loading and saving tags
- (NSString *)pathForDataFile 
{ 
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSString *folder = @"~/Library/Application Support/Punakea/"; 
	folder = [folder stringByExpandingTildeInPath]; 
	
	if ([fileManager fileExistsAtPath: folder] == NO) 
		[fileManager createDirectoryAtPath: folder attributes: nil];
	
	NSString *fileName = @"tags.plist"; 
	return [folder stringByAppendingPathComponent: fileName]; 
}

- (void)saveDataToDisk 
{	
	NSString *path  = [self pathForDataFile];
	NSMutableDictionary *rootObject = [NSMutableDictionary dictionary];
	[rootObject setValue:[globalTags tags] forKey:@"tags"];
	
	NSMutableData *data = [NSMutableData data];
	NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
	[archiver setOutputFormat:NSPropertyListXMLFormat_v1_0];
	[archiver encodeObject:rootObject];
	[archiver finishEncoding];
	[data writeToFile:path atomically:YES];
	[archiver release];
}

- (void)loadDataFromDisk 
{
	NSString *path = [self pathForDataFile];
	NSMutableData *data = [NSData dataWithContentsOfFile:path];
	
	if (data)
	{
		NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
		NSMutableDictionary *rootObject = [unarchiver decodeObject];
		[unarchiver finishDecoding];
		[unarchiver release];
	
		NSMutableArray *loadedTags = [rootObject valueForKey:@"tags"];
	
		if ([loadedTags count] > 0)
		{
			[globalTags setTags:loadedTags];
		}
	}
	else
	{
		// on first startup there will be no data, create empty mutable array
		[globalTags setTags:[NSMutableArray array]];
	}
}	

- (void)tagsHaveChanged:(NSNotification*)notification
{
	NSDictionary *userInfo = [notification userInfo];
	PATagChangeOperation tagOperation = [[userInfo objectForKey:PATagOperation] intValue];
	
	// ignore use count and increments ... will be saved on app termination
	if (tagOperation != PATagUseIncrementOperation
		&& tagOperation != PATagClickIncrementOperation)
	{
		[self saveDataToDisk];
	}
}

- (void)createManagedFilesDirIfNeeded
{
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	
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
- (IBAction)showResults:(id)sender
{
	if(![self appHasBrowser])
		[self showBrowser:self];
	
	[[browserController browserViewController] showResults];
	[[viewMenu itemWithTag:0] setState:NSOnState];
	[[viewMenu itemWithTag:1] setState:NSOffState];
}

- (IBAction)manageTags:(id)sender
{	
	if(![self appHasBrowser])
		[self showBrowser:self];
	
	[[browserController browserViewController] manageTags];
	[[viewMenu itemWithTag:0] setState:NSOffState];
	[[viewMenu itemWithTag:1] setState:NSOnState];
}

- (IBAction)showPreferences:(id)sender
{
	if (!preferenceController)
	{
		preferenceController = [[PreferenceController alloc] initWithCore:self];
	}
	[preferenceController showWindow:self];
}

- (IBAction)openFiles:(id)sender
{	
	if(![self appHasBrowser])
		[self showBrowser:self];
	
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

- (IBAction)deleteFiles:(id)sender
{	
	if(![self appHasBrowser])
		[self showBrowser:self];
	
	PABrowserViewMainController *mainController = [[browserController browserViewController] mainController];
	
	if ([mainController isKindOfClass:[PAResultsViewController class]])
	{
		PAResultsOutlineView *ov = [(PAResultsViewController*)mainController outlineView];
		[[ov target] performSelector:@selector(deleteFilesForVisibleSelectedItems:)];
	}
}

- (IBAction)editTagsOnFiles:(id)sender
{
	if(![self appHasBrowser])
		[self showBrowser:self];
	
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
	if(![self appHasBrowser])
		[self showBrowser:self];
	
	PABrowserViewMainController *mainController = [[browserController browserViewController] mainController];
	
	if ([mainController isKindOfClass:[PAResultsViewController class]])
	{
		PAResultsOutlineView *ov = [(PAResultsViewController*)mainController outlineView];
		[ov selectAll:sender];
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
	TaggerController *taggerController = [[TaggerController alloc] init];
	[taggerController showWindow:self];
	NSWindow *taggerWindow = [taggerController window];
	[taggerWindow makeKeyAndOrderFront:nil];
}

- (IBAction)showDonationWebsite:(id)sender
{
	[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://www.nudgenudge.eu/donate"]];
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
	[taggerController addTaggableObjects:[PAFile filesWithFilepaths:filenames]];
	[taggerWindow makeKeyAndOrderFront:nil];
}

#pragma mark debug
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

@end
