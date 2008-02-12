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

- (void)switchSpecialFolderDir:(NSDictionary *)userInfo;

- (void)updateCurrentLocationForPopUpButton:(NSPopUpButton *)button;
- (void)moveSubdirectoriesFromPath:(NSString*)oldPath toPath:(NSString*)newPath tag:(int)tag;

- (void)displayWarningWithMessage:(NSString*)messageInfo;

- (NSString *)controllerKeyPathForMenuItemTag:(int)tag;
- (NSPopUpButton *)popUpButtonForMenuItemTag:(int)tag;

- (BOOL)isLoginItem;
- (CFIndex)loginItemIndex;
- (void)removeTagsFolder:(NSString *)dir;
- (void)updateDropBoxTagField;

- (void)createTagsFolderStructure;
- (void)removeTagsFolder;

- (void)attachDropBoxFolderAction;
- (void)removeDropBoxFolderAction;

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
	
	[userDefaultsController addObserver:self
							 forKeyPath:@"values.ManageFiles.DropBox.Tags"
								options:0
								context:NULL];
	
	[self updateCurrentLocationForPopUpButton:managedFolderPopUpButton];
	[self updateCurrentLocationForPopUpButton:tagsFolderPopUpButton];
	[self updateCurrentLocationForPopUpButton:dropBoxPopUpButton];
	
	[self updateDropBoxTagField];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(dropBoxTagsHaveChanged:)
												 name:NNSelectedTagsHaveChangedNotification
											   object:nil];
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
	[userDefaultsController removeObserver:self
								forKeyPath:@"values.ManageFiles.DropBox.Tags"];
	
	[[NSNotificationCenter defaultCenter] removeObserver:self];

	[super dealloc];
}

#pragma mark observing
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	if (object == userDefaultsController) 
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
		else if ([keyPath isEqualToString:@"values.ManageFiles.DropBox.Tags"])
		{
			// Write defaults to disk, so that the drop box script can work with the latest tag set
			[[NSUserDefaults standardUserDefaults] synchronize];
		}
	}
}


#pragma mark Notifications
- (void)dropBoxTagsHaveChanged:(NSNotification *)notification
{
	// Write tags to User Defaults
	
	TagAutoCompleteController *tagAutoCompleteController = [tagField delegate];
	
	NNSelectedTags *selectedTags = [tagAutoCompleteController currentCompleteTagsInField];
	
	NSMutableArray *tagNames = [NSMutableArray array];
	
	for(NNTag *tag in [selectedTags selectedTags])
	{
		[tagNames addObject:[tag name]];
	}
	
	[userDefaultsController setValue:tagNames
						  forKeyPath:@"values.ManageFiles.DropBox.Tags"];
}

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

	if([[userDefaultsController valueForKeyPath:@"values.ManageFiles.TagsFolder.Enabled"] boolValue])
		[self createTagsFolderStructure];
	else 
		[self removeTagsFolder];
}

- (void)dropBoxStateHasChanged
{	
	[core createDirectoriesIfNeeded];
	[self updateCurrentLocationForPopUpButton:dropBoxPopUpButton];
	[self updateDropBoxTagField];
	
	NSString *targetDir = @"~/Library/Scripts/Folder Action Scripts/";
	targetDir = [targetDir stringByStandardizingPath];
	
	NSString *targetScriptName = @"Punakea - Drop Box.scpt";
	
	NSString *targetPath = [targetDir stringByAppendingPathComponent:targetScriptName];
	
	if([[userDefaultsController valueForKeyPath:@"values.ManageFiles.DropBox.Enabled"] boolValue])
	{		
		NSFileManager *fileManager = [NSFileManager defaultManager];
		
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
		
		[self attachDropBoxFolderAction];
	}
	else 
	{
		[self removeDropBoxFolderAction];
		
		// Remove Script File		
		
		[[NSFileManager defaultManager] removeFileAtPath:targetPath handler:NULL];
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

- (void)openPanelDidEnd:(NSOpenPanel *)panel returnCode:(int)returnCode contextInfo:(void  *)contextInfo
{	
	NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
	
	if (returnCode == NSOKButton)
	{
		NSString *newDir = [[panel filenames] objectAtIndex:0];
		
		NSString *keyPath = [self controllerKeyPathForMenuItemTag:[(id)contextInfo tag]];
		
		NSString *oldDir = [userDefaultsController valueForKeyPath:keyPath];
						
		[userInfo setObject:oldDir forKey:@"oldDir"];
		[userInfo setObject:newDir forKey:@"newDir"];
		[userInfo setObject:[NSNumber numberWithInt:[(id)contextInfo tag]] forKey:@"tag"];
	}
	else
	{
		// Update UI
		NSPopUpButton *popUpButton = [self popUpButtonForMenuItemTag:[(id)contextInfo tag]];
		[popUpButton selectItemAtIndex:0];
	}
	
	// Perform the actual dir switch outside of this method to ensure neat closing of the Open Panel	
	if (returnCode == NSOKButton)
	{
		[self performSelectorInBackground:@selector(switchSpecialFolderDir:)
							   withObject:userInfo];
	}
}

- (void)switchSpecialFolderDir:(NSDictionary *)userInfo
{
	int		 tag	 = [[userInfo objectForKey:@"tag"] intValue];
	NSString *oldDir = [userInfo objectForKey:@"oldDir"];
	NSString *newDir = [userInfo objectForKey:@"newDir"];
	
	NSPopUpButton *popUpButton = [self popUpButtonForMenuItemTag:tag];
	NSString *keyPath = [self controllerKeyPathForMenuItemTag:tag];
	
	// Break if nothing to do
	if([oldDir isEqualTo:newDir])
	{
		[popUpButton selectItemAtIndex:0];
		return;
	}
	
	if (tag == 0)			// Manage Files
	{
		// Create new dir
		[[NSFileManager defaultManager] createDirectoryAtPath:newDir
								  withIntermediateDirectories:YES
												   attributes:0
													    error:NULL];
		
		// Update UserDefaults
		[userDefaultsController setValue:newDir forKeyPath:keyPath];
		
		// Update UI
		[self updateCurrentLocationForPopUpButton:popUpButton];		
		[popUpButton selectItemAtIndex:0];		
		[popUpButton display];
		
		// Do It!				
		[self moveSubdirectoriesFromPath:oldDir toPath:newDir tag:tag];
	}
	else if (tag == 1)		// Tags Folder
	{
		// Remove old dir
		[self removeTagsFolder];
		
		// Create new dir
		[[NSFileManager defaultManager] createDirectoryAtPath:newDir
								  withIntermediateDirectories:YES
												   attributes:0
													    error:NULL];
		
		[[NSWorkspace sharedWorkspace] setIcon:[NSImage imageNamed:@"TagFolder"] 
									   forFile:newDir
									   options:NSExclude10_4ElementsIconCreationOption];
		
		// Update UserDefaults
		[userDefaultsController setValue:newDir forKeyPath:keyPath];
		
		// Update UI
		[self updateCurrentLocationForPopUpButton:popUpButton];
		[popUpButton selectItemAtIndex:0];		
		[popUpButton display];
		
		// Do It!				
		[self createTagsFolderStructure];
	}
	else if (tag == 2)		// Drop Box
	{
		[self removeDropBoxFolderAction];
		
		// Create new dir
		[[NSFileManager defaultManager] createDirectoryAtPath:newDir
								  withIntermediateDirectories:YES
												   attributes:0
													    error:NULL];
		
		// Update UserDefaults
		[userDefaultsController setValue:newDir forKeyPath:keyPath];
		
		// Update UI
		[self updateCurrentLocationForPopUpButton:popUpButton];
		[popUpButton selectItemAtIndex:0];		
		[popUpButton display];
		
		// Do It!				
		[self moveSubdirectoriesFromPath:oldDir toPath:newDir tag:tag];
		
		[self attachDropBoxFolderAction];
	}
}

- (IBAction)switchSpecialFolderDirToDefault:(id)sender
{
	NSString *keyPath = [self controllerKeyPathForMenuItemTag:[sender tag]];
	
	NSString *oldDir = [userDefaultsController valueForKeyPath:keyPath];
	
	NSString *path = [[NSBundle mainBundle] pathForResource:@"UserDefaults" ofType:@"plist"];
	NSDictionary *appDefaults = [NSDictionary dictionaryWithContentsOfFile:path];
	
	// set path to default path
	NSString *defaultDir = [appDefaults objectForKey:[keyPath substringFromIndex:7]];
	defaultDir = [defaultDir stringByStandardizingPath];
	
	// Do it!
	NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
	
	[userInfo setObject:oldDir forKey:@"oldDir"];
	[userInfo setObject:defaultDir forKey:@"newDir"];
	[userInfo setObject:[NSNumber numberWithInt:[sender tag]] forKey:@"tag"];
	
	[self switchSpecialFolderDir:userInfo];		
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

- (void)moveSubdirectoriesFromPath:(NSString*)oldPath toPath:(NSString*)newPath tag:(int)tag
{
	NSString *standardizedOldPath = [oldPath stringByStandardizingPath];
	NSString *standardizedNewPath = [newPath stringByStandardizingPath];
	
	if ([standardizedOldPath isEqualToString:standardizedNewPath])
		return;
		
	NSFileManager *fileManager = [NSFileManager defaultManager];
		
	// first check if the destination is writable and a directory
	if (![fileManager isWritableFileAtPath:standardizedNewPath ])
	{
		[self displayWarningWithMessage:NSLocalizedStringFromTable(@"DESTINATION_NOT_WRITABLE",@"FileManager",@"")];
		return;
	}
			
	// Move Dirs
	// Managed Folder:	Copy only continuously numbered directories
	// Tags Folder:		Copy nothing, recreate structure from scratch (symlinks will break otherwiese!)
	// Drop Box:		Copy all
	
	NSMutableArray *directories;
	int i = 1;
	NSString *currentNumberedDir;
	NSString *directory;
	BOOL isDirectory;
	
	if (tag == 0)		// Managed Folder - Copy only the numbered dirs
	{		
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
	else if (tag == 1)	// Tags Folder - Copy nothing
	{
		directories = [NSMutableArray array];
	}
	else if (tag == 2)	// Drop Box - Copy everything
	{		
		directories = [NSMutableArray arrayWithArray:[fileManager contentsOfDirectoryAtPath:standardizedOldPath error:NULL]];
		
		for(int j=0; j < [directories count]; j++)
		{
			// Prefix each dir with its full path
			NSString *fullPath = [standardizedOldPath stringByAppendingPathComponent:[directories objectAtIndex:j]];
			[directories replaceObjectAtIndex:j withObject:fullPath];
		}
	}
	
	// Now all dirs to copy are in array 'directories'
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
	
	// Now move
	
	dirEnumerator = [directories objectEnumerator];
	
	while (directory = [dirEnumerator nextObject])
	{
		directory = [directory stringByStandardizingPath];
		
		dirName = [directory lastPathComponent];
		newDir = [standardizedNewPath stringByAppendingPathComponent:dirName];
		
		[fileManager movePath:directory toPath:newDir handler:self];
	}
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

- (void)updateDropBoxTagField
{
	BOOL createTags = YES;
	
	// Do not create tags if Drop Box is disabled	
	BOOL dropBoxEnabled = [[userDefaultsController valueForKeyPath:@"values.ManageFiles.DropBox.Enabled"] boolValue];
	if (!dropBoxEnabled)
		createTags = NO;	
	
	// Get tags from User Defaults and set them for Tag Field
	
	TagAutoCompleteController *tagAutoCompleteController = [tagField delegate];
	
	NSArray *tagNames = [userDefaultsController valueForKeyPath:@"values.ManageFiles.DropBox.Tags"];
	NSMutableArray *tags = [NSMutableArray array];
	
	for (NSString *tagName in tagNames)
	{
		NNTag *tag = [[NNTags sharedTags] tagForName:tagName create:createTags];
		
		if(tag)
			[tags addObject:tag];
	}
	
	NNSelectedTags *selectedTags = [[[NNSelectedTags alloc] initWithTags:tags] autorelease];
	
	[tagField setObjectValue:tags];
	[tagAutoCompleteController setCurrentCompleteTagsInField:selectedTags];
}

- (void)createTagsFolderStructure
{
	// Recreate folder structure from scratch
	
	BusyWindowController *busyWindowController = [[core busyWindow] delegate];
	
	[busyWindowController setMessage:NSLocalizedStringFromTable(@"BUSY_WINDOW_MESSAGE_REBUILDING_TAGS_FOLDER", @"FileManager", nil)];
	[busyWindowController performBusySelector:@selector(createDirectoryStructure)
									 onObject:[NNTagging tagging]];
	
	[[core busyWindow] center];
	[NSApp runModalForWindow:[core busyWindow]];
}

- (void)removeTagsFolder
{
	// Removes all subdirs of tags folder
	
	BusyWindowController *busyWindowController = [[core busyWindow] delegate];
	
	NSString *tagsFolderDir = [userDefaultsController valueForKeyPath:TAGS_FOLDER_LOCATION_CONTROLLER_KEYPATH];
	tagsFolderDir = [tagsFolderDir stringByStandardizingPath];
	
	[busyWindowController setMessage:NSLocalizedStringFromTable(@"BUSY_WINDOW_MESSAGE_REMOVING_TAGS_FOLDER", @"FileManager", nil)];
	[busyWindowController performBusySelector:@selector(removeTagsFolder:)
									 onObject:self
								   withObject:tagsFolderDir];
	
	[[core busyWindow] center];
	[NSApp runModalForWindow:[core busyWindow]];
}

- (void)attachDropBoxFolderAction
{
	NSString *dropBoxDir = [userDefaultsController valueForKeyPath:DROP_BOX_LOCATION_CONTROLLER_KEYPATH];
	dropBoxDir = [dropBoxDir stringByStandardizingPath];
	
	NSString *targetScriptName = @"Punakea - Drop Box.scpt";
	
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
	
	// Make sure the tags that are written by the script are also available in Punakea,
	// i.e. tags exist
	
	NSArray *tagNames = [userDefaultsController valueForKeyPath:@"values.ManageFiles.DropBox.Tags"];
	
	for (NSString *tagName in tagNames)
	{
		// Create tag if not exists
		[[NNTags sharedTags] tagForName:tagName create:YES];
	}
}

- (void)removeDropBoxFolderAction
{
	NSString *dropBoxDir = [userDefaultsController valueForKeyPath:DROP_BOX_LOCATION_CONTROLLER_KEYPATH];
	dropBoxDir = [dropBoxDir stringByStandardizingPath];
	
	// Remove Folder Action
	
	NSString *s = @"tell application \"System Events\"\n";
	
	s = [s stringByAppendingString:@"remove action from \""];
	s = [s stringByAppendingString:dropBoxDir];
	s = [s stringByAppendingString:@"\" using action name \"Punakea - Drop Box.scpt\""];
	s = [s stringByAppendingString:@"\n"];
	
	s = [s stringByAppendingString:@"end tell"];
	
	NSAppleScript *folderActionScript = [[NSAppleScript alloc] initWithSource:s];
	[folderActionScript executeAndReturnError:nil];
}

@end
