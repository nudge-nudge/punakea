//
//  PreferenceController.m
//  punakea
//
//  Created by Johannes Hoffart on 29.08.06.
//  Copyright 2006 nudge:nudge. All rights reserved.
//

#import "PreferenceController.h"
#import "Core.h"

@interface PreferenceController (PrivateAPI)

- (void)startOnLoginHasChanged;
- (void)scheduledUpdateCheckIntervalHasChanged;
- (void)tagsFolderStateHasChanged;
- (void)dropBoxStateHasChanged;

- (void)updateCurrentLocationForPopUpButton:(NSPopUpButton *)button;
- (void)switchLocationFromPath:(NSString*)oldPath toPath:(NSString*)newPath tag:(int)tag;

- (void)displayWarningWithMessage:(NSString*)messageInfo;

- (NSString *)controllerKeyPathForMenuItemTag:(int)tag;
- (NSPopUpButton *)popUpButtonForMenuItemTag:(int)tag;

- (BOOL)isLoginItem;
- (CFIndex)loginItemIndex;
- (void)removeTagsFolder:(NSString *)dir;

@end


NSString * const MANAGED_FOLDER_LOCATION_CONTROLLER_KEYPATH = @"values.ManageFiles.ManagedFolder.Location";
NSString * const TAGS_FOLDER_LOCATION_CONTROLLER_KEYPATH = @"values.ManageFiles.TagsFolder.Location";
NSString * const DROP_BOX_LOCATION_CONTROLLER_KEYPATH = @"values.ManageFiles.DropBox.Location";


@implementation PreferenceController

#pragma mark init+dealloc
- (id)initWithCore:(Core*)aCore
{
	if (self = [super initWithWindowNibName:@"Preferences"])
	{
		userDefaultsController = [NSUserDefaultsController sharedUserDefaultsController];
		core = aCore;
	}
	return self;
}

- (void)awakeFromNib
{	
	BOOL isLoginItem = [self isLoginItem];
	
	[[NSUserDefaults standardUserDefaults] setBool:isLoginItem
											forKey:@"General.StartOnLogin"];
	
	[userDefaultsController addObserver:self
							 forKeyPath:@"values.General.StartOnLogin"
								options:0
								context:NULL];
	
	[userDefaultsController addObserver:self
							 forKeyPath:@"values.PAScheduledUpdateCheckInterval"
								options:0
								context:NULL];
	
	[userDefaultsController addObserver:self
							 forKeyPath:@"values.ManageFiles.ManagedFolder.Enabled"
								options:0
								context:NULL];
	
	[userDefaultsController addObserver:self
							 forKeyPath:@"values.ManageFiles.TagsFolder.Enabled"
								options:0
								context:NULL];
	
	[userDefaultsController addObserver:self
							 forKeyPath:@"values.ManageFiles.DropBox.Enabled"
								options:0
								context:NULL];
	
	[self updateCurrentLocationForPopUpButton:managedFolderPopUpButton];
	[self updateCurrentLocationForPopUpButton:tagsFolderPopUpButton];
	[self updateCurrentLocationForPopUpButton:dropBoxPopUpButton];
}

- (void)dealloc
{
	[userDefaultsController removeObserver:self
								forKeyPath:@"values.General.StartOnLogin"];
	[userDefaultsController removeObserver:self
								forKeyPath:@"values.PAScheduledUpdateCheckInterval"];
	[userDefaultsController removeObserver:self
								forKeyPath:@"values.ManageFiles.ManagedFolder.Enabled"];
	[userDefaultsController removeObserver:self
								forKeyPath:@"values.ManageFiles.TagsFolder.Enabled"];
	[userDefaultsController removeObserver:self
								forKeyPath:@"values.ManageFiles.DropBox.Enabled"];

	[super dealloc];
}

#pragma mark observing
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	if ([keyPath isEqualToString:@"values.General.StartOnLogin"])
	{
		[self startOnLoginHasChanged];
	}
	else if ([keyPath isEqualToString:@"values.PAScheduledUpdateCheckInterval"])
	{
		[self scheduledUpdateCheckIntervalHasChanged];
	}
	else if ([keyPath isEqualToString:@"values.ManageFiles.ManagedFolder.Enabled"])
	{
		[core createDirectoriesIfNeeded];
		[self updateCurrentLocationForPopUpButton:managedFolderPopUpButton];
	}
	else if ([keyPath isEqualToString:@"values.ManageFiles.TagsFolder.Enabled"])
	{
		[self tagsFolderStateHasChanged];
	}
	else if ([keyPath isEqualToString:@"values.ManageFiles.DropBox.Enabled"])
	{
		[self dropBoxStateHasChanged];
	}
}

#pragma mark window delegate
- (void)windowWillClose:(NSNotification *)aNotification
{		
	[self autorelease];
}

#pragma mark event handling
- (void)startOnLoginHasChanged
{	
	// add app to login items
	CFIndex itemIndex = [self loginItemIndex];
	BOOL found = [self isLoginItem];
	BOOL startOnLogin = [[NSUserDefaults standardUserDefaults] boolForKey:@"General.StartOnLogin"];
		
	NSString *path = [[NSBundle mainBundle] bundlePath];
	CFURLRef url = CFURLCreateWithFileSystemPath(kCFAllocatorDefault, (CFStringRef)path, kCFURLPOSIXPathStyle, true); 

	if (found && !startOnLogin)
		LIAERemove(itemIndex);
		
	if (startOnLogin) 
		LIAEAddURLAtEnd(url, false);
	
	CFRelease(url);
}

- (void)scheduledUpdateCheckIntervalHasChanged
{
	PAScheduledUpdateCheckInterval interval = [[NSUserDefaults standardUserDefaults] integerForKey:@"PAScheduledUpdateCheckInterval"];
	NSTimeInterval timeInterval = 60.0*60.0*24.0*7.0*30.0;
	
	switch (interval)
	{
		case PAScheduledUpdateCheckDaily:
			timeInterval = 60.0*60.0*24.0;
			break;
		case PAScheduledUpdateCheckWeekly:
			timeInterval = 60.0*60.0*24.0*7.0;
			break;
		case PAScheduledUpdateCheckMonthly:
			timeInterval = 60.0*60.0*24.0*7.0*30.0;
			break;
	}
	
	[[NSUserDefaults standardUserDefaults] setInteger:(int)timeInterval forKey:@"SUScheduledCheckInterval"];
	[[core updater] scheduleCheckWithInterval:timeInterval];
}		

- (void)tagsFolderStateHasChanged
{	
	[core createDirectoriesIfNeeded];
	[self updateCurrentLocationForPopUpButton:tagsFolderPopUpButton];
	
	BusyWindowController *busyWindowController = [busyWindow delegate];
	
	if([[userDefaultsController valueForKeyPath:@"values.ManageFiles.TagsFolder.Enabled"] boolValue])
	{	
		[busyWindowController setMessage:NSLocalizedStringFromTable(@"BUSY_WINDOW_MESSAGE_REBUILDING_TAGS_FOLDER", @"FileManager", nil)];
		[busyWindowController performBusySelector:@selector(createDirectoryStructure)
										 onObject:[NNTagging tagging]];
	}
	else 
	{
		NSString *tagsFolderDir = [userDefaultsController valueForKeyPath:TAGS_FOLDER_LOCATION_CONTROLLER_KEYPATH];
		tagsFolderDir = [tagsFolderDir stringByStandardizingPath];
		
		[busyWindowController setMessage:NSLocalizedStringFromTable(@"BUSY_WINDOW_MESSAGE_REMOVING_TAGS_FOLDER", @"FileManager", nil)];
		[busyWindowController performBusySelector:@selector(removeTagsFolder:)
										 onObject:self
									   withObject:tagsFolderDir];
	}	
	
	[busyWindow center];
	[NSApp runModalForWindow:busyWindow];
}

- (void)dropBoxStateHasChanged
{	
	[core createDirectoriesIfNeeded];
	[self updateCurrentLocationForPopUpButton:dropBoxPopUpButton];
	
	NSString *dropBoxDir = [userDefaultsController valueForKeyPath:DROP_BOX_LOCATION_CONTROLLER_KEYPATH];
	dropBoxDir = [dropBoxDir stringByStandardizingPath];
	
	NSString *targetDir = @"~/Library/Scripts/Folder Action Scripts/";
	targetDir = [targetDir stringByStandardizingPath];
	
	NSString *targetScriptName = @"Punakea - Drop Box.scpt";
	
	NSString *targetPath = [targetDir stringByAppendingPathComponent:targetScriptName];
	
	NSFileManager *fileManager = [NSFileManager defaultManager];
	
	if([[userDefaultsController valueForKeyPath:@"values.ManageFiles.DropBox.Enabled"] boolValue])
	{	
		// Copy Folder Action Script to Library
		
		NSString *scriptPath = [[NSBundle mainBundle] pathForResource:@"DropBox" ofType:@"scpt"];
		
		BOOL isDir;
		
		if(!([fileManager fileExistsAtPath:targetDir isDirectory:&isDir] && isDir))
		{
			[fileManager createDirectoryAtPath:targetDir
				   withIntermediateDirectories:YES
									attributes:nil
										 error:NULL];
		}
		
		[fileManager copyItemAtPath:scriptPath
							 toPath:targetPath
							  error:NULL];
		
		// Make executable??
		
		//NSDictionary *attr = [NSMutableDictionary dictionaryWithCapacity:1];
		//[attr setValue:[NSNumber numberWithInt:511] forKey:NSFilePosixPermissions];
		
		//[fileManager changeFileAttributes:attr atPath:targetPath];
		
		// Attach Folder Action
		
		NSString *s = @"tell application \"System Events\"\n";
		
		s = [s stringByAppendingString:@"set folder actions enabled to true\n"];
		
		s = [s stringByAppendingString:@"set scriptPath to (path to Folder Action scripts as Unicode text) & \""];
		s = [s stringByAppendingString:targetScriptName];
		s = [s stringByAppendingString:@"\"\n"];
		
		s = [s stringByAppendingString:@"attach action to \""];
		s = [s stringByAppendingString:dropBoxDir];
		s = [s stringByAppendingString:@"\" using file scriptPath\n"];
		s = [s stringByAppendingString:@"end tell"];

		NSAppleScript *folderActionScript = [[NSAppleScript alloc] initWithSource:s];
		[folderActionScript executeAndReturnError:nil];
		
		/*
		 
		// Scripting Bridge Version
		// Couldn't get this piece of code to work :(
		 
		SystemEventsApplication *systemEvents = [SBApplication applicationWithBundleIdentifier:@"com.apple.systemevents"];
		
		SBElementArray *folderActions = [systemEvents folderActions];
		for(SystemEventsFolderAction *folderAction in folderActions)
		{
			NSLog(folderAction.name);
		}
		
		SystemEventsFolder *homeFolder = systemEvents.homeFolder;
		
		//SystemEventsFolder *item = [[homeFolder folders] obje:@"Documents"];
		NSLog(@"TEST: %@", homeFolder.name);
		[homeFolder attachActionToUsing:@"/Users/daniel/Desktop/Punakea - Drop Box.scpt"];*/		
		
		
	}
	else 
	{
		// Remove Script File		
		[fileManager removeFileAtPath:targetPath handler:NULL];
		
		// [fileManager trashFileAtPath:dropBoxDir];
	}	
}


#pragma mark file location
- (IBAction)locateDirectory:(id)sender
{
	NSString *keyPath = [self controllerKeyPathForMenuItemTag:[sender tag]];
	
	NSString *currentPath = [[userDefaultsController valueForKeyPath:keyPath] retain];
	
	// create open panel with the needed settings
	NSOpenPanel *openPanel = [NSOpenPanel openPanel];
	
	[openPanel setAllowsMultipleSelection:NO];
	[openPanel setCanChooseFiles:NO];
	[openPanel setCanChooseDirectories:YES];
	[openPanel setCanCreateDirectories:YES];
	
	[openPanel beginSheetForDirectory:[currentPath stringByStandardizingPath]
								   file:nil
								  types:[NSArray arrayWithObject:NSFileTypeDirectory]
						 modalForWindow:[self window]
						  modalDelegate:self
						 didEndSelector:@selector(openPanelDidEnd:returnCode:contextInfo:) 
							contextInfo:sender];
}

- (IBAction)switchToDefaultDirectory:(id)sender
{
	NSPopUpButton *popUpButton = [self popUpButtonForMenuItemTag:[sender tag]];	
	NSString *keyPath = [self controllerKeyPathForMenuItemTag:[sender tag]];
	
	NSString *oldDir = [userDefaultsController valueForKeyPath:keyPath];
	
	NSString *path = [[NSBundle mainBundle] pathForResource:@"UserDefaults" ofType:@"plist"];
	NSDictionary *appDefaults = [NSDictionary dictionaryWithContentsOfFile:path];
	
	// set path to default path
	NSString *defaultDir = [appDefaults objectForKey:[keyPath substringFromIndex:7]];
	defaultDir = [defaultDir stringByStandardizingPath];
	
	NSFileManager *fileManager = [NSFileManager defaultManager];
	BOOL isDirectory;
	
	if ([fileManager fileExistsAtPath:defaultDir isDirectory:&isDirectory])
	{
		if (!isDirectory)
		{
			[self displayWarningWithMessage:NSLocalizedStringFromTable(@"DESTINATION_NOT_FOLDER_ERROR",@"FileManager",@"")];
			[popUpButton selectItemAtIndex:0];
			return;
		}
	}
	else
	{
		[fileManager createDirectoryAtPath:defaultDir withIntermediateDirectories:YES attributes:nil error:NULL];
	}
	
	[self switchLocationFromPath:oldDir toPath:defaultDir tag:[sender tag]];
	[popUpButton selectItemAtIndex:0];
}

- (void)openPanelDidEnd:(NSOpenPanel *)panel returnCode:(int)returnCode contextInfo:(void  *)contextInfo
{	
	if (returnCode == NSOKButton)
	{
		NSString *newDir = [[panel filenames] objectAtIndex:0];
		
		NSString *keyPath = [self controllerKeyPathForMenuItemTag:[contextInfo tag]];
		
		NSString *oldDir = [userDefaultsController valueForKeyPath:keyPath];
						
		[self switchLocationFromPath:oldDir toPath:newDir tag:[contextInfo tag]];
	}

	NSPopUpButton *popUpButton = [self popUpButtonForMenuItemTag:[contextInfo tag]];	
	
	[popUpButton selectItemAtIndex:0];
}

#pragma mark file error handler
- (BOOL)fileManager:(NSFileManager *)manager shouldProceedAfterError:(NSDictionary *)errorInfo
{
	// there shouldn't be many errors, as the app
	// checks before starting to move. still some possibility remains
	NSString *oldPath = [errorInfo objectForKey:@"Path"];
	NSString *error = [errorInfo objectForKey:@"Error"];
	NSString *newPath = [errorInfo objectForKey:@"ToPath"];
	
	if (!newPath)
	{
		[self displayWarningWithMessage:NSLocalizedStringFromTable(@"CRITICAL_MOVING_ERROR",@"FileManager",@"")];
	}
	else
	{
		[self displayWarningWithMessage:[NSString stringWithFormat:
			NSLocalizedStringFromTable(@"ERROR_MOVING_DIR",@"FileManager",@""),error,oldPath]];
		
		// move all dirs already moved back to original location
		NSString *oldManagedPath = [oldPath stringByDeletingLastPathComponent];
		NSString *newManagedPath = [newPath stringByDeletingLastPathComponent];
		
		NSString *dirName = [oldPath lastPathComponent];
		int i = [dirName intValue];
			
		for (i;i>0;i--)
		{
			NSString *newDirName = [NSString stringWithFormat:@"%i",i];
			[manager movePath:[newManagedPath stringByAppendingPathComponent:newDirName]
						   toPath:[oldManagedPath stringByAppendingPathComponent:newDirName]
						  handler:nil];
		}
	}
	return NO;
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

- (void)alertDidEnd:(NSAlert *)alert returnCode:(int)returnCode contextInfo:(void *)contextInfo
{
	// noting
	return;
}

#pragma mark helper
- (void)updateCurrentLocationForPopUpButton:(NSPopUpButton *)button
{
	id currentLocation = [button itemAtIndex:0];
	
	NSString *keyPath = @"";
	if(button == managedFolderPopUpButton)	keyPath = MANAGED_FOLDER_LOCATION_CONTROLLER_KEYPATH;
	if(button == tagsFolderPopUpButton)		keyPath = TAGS_FOLDER_LOCATION_CONTROLLER_KEYPATH;
	if(button == dropBoxPopUpButton)		keyPath = DROP_BOX_LOCATION_CONTROLLER_KEYPATH;
	   
	NSString *dir = [userDefaultsController valueForKeyPath:keyPath];
	dir = [dir stringByExpandingTildeInPath];
	
	BOOL isDirectory;
	
	if([[NSFileManager defaultManager] fileExistsAtPath:dir isDirectory:&isDirectory] && isDirectory)
	{	
		NSImage *icon = [[NSWorkspace sharedWorkspace] iconForFile:dir];
		[icon setSize:NSMakeSize(16.0,16.0)];
		
		[currentLocation setImage:icon];
		[currentLocation setTitle:[dir lastPathComponent]];
	}
	else
	{
		[currentLocation setImage:nil];
		[currentLocation setTitle:@""];
	}
	
	
}

- (void)switchLocationFromPath:(NSString*)oldPath toPath:(NSString*)newPath tag:(int)tag
{
	NSString *standardizedOldPath = [oldPath stringByStandardizingPath];
	NSString *standardizedNewPath = [newPath stringByStandardizingPath];
	
	if ([standardizedOldPath isEqualToString:standardizedNewPath])
		return;
		
	// move old files if there are any - 
	// only copy the numbered folders!
	NSFileManager *fileManager = [NSFileManager defaultManager];
		
	// first check if the destination is writable and a directory
	if (![fileManager isWritableFileAtPath:standardizedNewPath ])
	{
		[self displayWarningWithMessage:NSLocalizedStringFromTable(@"DESTINATION_NOT_WRITABLE",@"FileManager",@"")];
		return;
	}
			
	// then collect all dirs to move
	// for tag == 0 (Managed Folder) we collect only numbered directories
	
	NSMutableArray *directories;
	int i = 1;
	NSString *currentNumberedDir;
	NSString *directory;
	BOOL isDirectory;
	
	if(tag == 0) 
	{	
		// Copy only the numbered dirs
		
		directories = [NSMutableArray array];
		
		while (true)
		{
			currentNumberedDir = [NSString stringWithFormat:@"/%i/",i];
			directory = [standardizedOldPath stringByAppendingPathComponent:currentNumberedDir];
		
			if ([fileManager fileExistsAtPath:directory isDirectory:&isDirectory])
			{
				if (isDirectory)
				{
					[directories addObject:directory];
					i++;
				}
			}
			else
			{
				break;
			}
		}
	}
	else
	{
		// We'll copy all stuff
		
		directories = [NSMutableArray arrayWithArray:[fileManager contentsOfDirectoryAtPath:standardizedOldPath error:NULL]];
		
		for(int j=0; j < [directories count]; j++)
		{
			// Prefix each dir with its full path
			NSString *fullPath = [standardizedOldPath stringByAppendingPathComponent:[directories objectAtIndex:j]];
			[directories replaceObjectAtIndex:j withObject:fullPath];
		}
	}
	
	// now all dirs are in directories 
	// check if destination is void of all those dirnames
	
	NSEnumerator *dirEnumerator = [directories objectEnumerator];
	NSString *dirName;
	NSString *newDir;

	while (directory = [dirEnumerator nextObject])
	{
		dirName = [directory lastPathComponent];
		newDir = [standardizedNewPath stringByAppendingPathComponent:dirName];
		
		if ([fileManager fileExistsAtPath:newDir isDirectory:&isDirectory])
		{
			if (isDirectory)
			{
				[self displayWarningWithMessage:[NSString stringWithFormat:
					NSLocalizedStringFromTable(@"DESTINATION_CONTAINS_NEEDED_DIR",@"FileManager",@""),dirName,dirName]];
				return;
			}
		}
	}
	
	// if everything is ok, move them
	
	dirEnumerator = [directories objectEnumerator];
	
	while (directory = [dirEnumerator nextObject])
	{
		directory = [directory stringByStandardizingPath];
		
		dirName = [directory lastPathComponent];
		newDir = [standardizedNewPath stringByAppendingPathComponent:dirName];
		
		[fileManager movePath:directory toPath:newDir handler:self];
	}
		
	NSPopUpButton *popUpButton = [self popUpButtonForMenuItemTag:tag];	
	NSString *keyPath = [self controllerKeyPathForMenuItemTag:tag];
	
	[userDefaultsController setValue:newPath forKeyPath:keyPath];
	[self updateCurrentLocationForPopUpButton:popUpButton];
	
	// If tag == 1 (Tags Folder), we update the folder's icon
	[[NSWorkspace sharedWorkspace] setIcon:[NSImage imageNamed:@"TagFolder"] 
								   forFile:standardizedNewPath
								   options:NSExclude10_4ElementsIconCreationOption];
}

- (NSString *)controllerKeyPathForMenuItemTag:(int)tag
{
	switch (tag)
	{
		case 1:		return TAGS_FOLDER_LOCATION_CONTROLLER_KEYPATH;
		case 2:		return DROP_BOX_LOCATION_CONTROLLER_KEYPATH;
		default:	return MANAGED_FOLDER_LOCATION_CONTROLLER_KEYPATH;
	}
}

- (NSPopUpButton *)popUpButtonForMenuItemTag:(int)tag
{
	switch (tag)
	{
		case 1:		return tagsFolderPopUpButton;
		case 2:		return dropBoxPopUpButton;
		default:	return managedFolderPopUpButton;
	}
}

- (BOOL)isLoginItem
{
	OSStatus	status;
	CFIndex		itemIndex;
	CFIndex 	itemCount;
	CFArrayRef loginItems = NULL; 
	
	status = LIAECopyLoginItems(&loginItems); 
	
	if (status == noErr) 
	{
		itemCount = CFArrayGetCount(loginItems);
		CFRelease(loginItems);
		
		itemIndex = [self loginItemIndex];
		
		return (itemIndex < itemCount);
	}
	else 
	{
		return NO;
	}
}

- (CFIndex)loginItemIndex
{
	OSStatus	status;
	CFIndex 	itemCount;
	CFIndex 	itemIndex;
	
	NSString *path = [[NSBundle mainBundle] bundlePath];
	
	CFArrayRef loginItems = NULL; 
	CFURLRef url = CFURLCreateWithFileSystemPath(kCFAllocatorDefault, (CFStringRef)path, kCFURLPOSIXPathStyle, true); 
	status = LIAECopyLoginItems(&loginItems); 
	
	itemIndex = INT32_MAX;
	
	if (status == noErr) {
		itemCount = CFArrayGetCount(loginItems);
		itemIndex = 0;
		
		CFDictionaryRef dic;
		CFURLRef dicUrl;
		
		while (itemIndex < itemCount) {
			dic = CFArrayGetValueAtIndex(loginItems,itemIndex);
			dicUrl = CFDictionaryGetValue(dic,@"URL");
			
			if (CFEqual(url,dicUrl))
				break;
			else
				itemIndex++;
		}
		
		CFRelease(loginItems);
	}
	
	CFRelease(url);
	
	return itemIndex;
}

- (IBAction)checkForUpdates:(id)sender
{
	[[core updater] checkForUpdates:self];
}

- (void)removeTagsFolder:(NSString *)dir
{
	[[NSFileManager defaultManager] removeFileAtPath:dir handler:NULL];
	
	NSMutableDictionary *dict = [NSMutableDictionary dictionary];
	[dict setObject:[NSNumber numberWithDouble:1.0] forKey:@"doubleValue"];
	[dict setObject:[NSNumber numberWithDouble:1.0] forKey:@"maxValue"];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:NNProgressDidUpdateNotification
														object:dict];
}

@end
