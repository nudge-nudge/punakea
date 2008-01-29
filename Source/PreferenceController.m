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

- (void)updateCurrentLocationForPopUpButton:(NSPopUpButton *)button;
- (void)switchManagedLocationFromPath:(NSString*)oldPath toPath:(NSString*)newPath;

- (void)displayWarningWithMessage:(NSString*)messageInfo;

- (BOOL)isLoginItem;
- (CFIndex)loginItemIndex;

@end

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
								forKeyPath:@"values.PAScheduledUpdateCheckInterval"];
	[userDefaultsController removeObserver:self
								forKeyPath:@"values.General.StartOnLogin"];
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
	else if ([keyPath isEqualToString:@"values.ManageFiles.ManagedFolder.Enabled"] ||
			 [keyPath isEqualToString:@"values.ManageFiles.TagsFolder.Enabled"] ||
			 [keyPath isEqualToString:@"values.ManageFiles.DropBox.Enabled"])
	{
		[core createDirectoriesIfNeeded];
		[self updateCurrentLocationForPopUpButton:managedFolderPopUpButton];
		[self updateCurrentLocationForPopUpButton:tagsFolderPopUpButton];
		[self updateCurrentLocationForPopUpButton:dropBoxPopUpButton];
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

#pragma mark file location
- (IBAction)locateDirectory:(id)sender
{
	NSString *currentPath = [[userDefaultsController valueForKeyPath:@"values.ManageFiles.ManagedFolder.Location"] retain];
	
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
							contextInfo:NULL];
}

- (IBAction)switchToDefaultDirectory:(id)sender
{
	NSString *oldPath = [userDefaultsController valueForKeyPath:@"values.ManageFiles.ManagedFolder.Location"];
	
	NSString *path = [[NSBundle mainBundle] pathForResource:@"UserDefaults" ofType:@"plist"];
	NSDictionary *appDefaults = [NSDictionary dictionaryWithContentsOfFile:path];
	
	// set path to default path
	NSString *defaultPath = [appDefaults objectForKey:@"ManageFiles.ManagedFolder.Location"];
	
	NSFileManager *fileManager = [NSFileManager defaultManager];
	BOOL isDirectory;
	
	if ([fileManager fileExistsAtPath:[defaultPath stringByStandardizingPath] isDirectory:&isDirectory])
	{
		if (!isDirectory)
		{
			[self displayWarningWithMessage:NSLocalizedStringFromTable(@"DESTINATION_NOT_FOLDER_ERROR",@"FileManager",@"")];
			[managedFolderPopUpButton selectItemAtIndex:0];
			return;
		}
	}
	else
	{
		[fileManager createDirectoryAtPath:[defaultPath stringByStandardizingPath] withIntermediateDirectories:YES attributes:nil error:NULL];
	}
	
	[self switchManagedLocationFromPath:oldPath toPath:defaultPath];
	[managedFolderPopUpButton selectItemAtIndex:0];
}

- (void)openPanelDidEnd:(NSOpenPanel *)panel returnCode:(int)returnCode  contextInfo:(void  *)contextInfo
{
	if (returnCode == NSOKButton)
	{
		NSString *oldPath = [userDefaultsController valueForKeyPath:@"values.ManageFiles.ManagedFolder.Location"];
		NSString *newPath = [[panel filenames] objectAtIndex:0];
		
		[self switchManagedLocationFromPath:oldPath toPath:newPath];
		
		[managedFolderPopUpButton selectItemAtIndex:0];
	}
	else if (returnCode == NSCancelButton)
	{
		[managedFolderPopUpButton selectItemAtIndex:0];
	}
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
	if(button == managedFolderPopUpButton)	keyPath = @"values.ManageFiles.ManagedFolder.Location";
	if(button == tagsFolderPopUpButton)		keyPath = @"values.ManageFiles.TagsFolder.Location";
	if(button == dropBoxPopUpButton)		keyPath = @"values.ManageFiles.DropBox.Location";
	   
	NSString *dir = [userDefaultsController valueForKeyPath:keyPath];
	dir = [dir stringByExpandingTildeInPath];
	
	NSImage *icon = [[NSWorkspace sharedWorkspace] iconForFile:dir];
	[icon setSize:NSMakeSize(16.0,16.0)];
	
	[currentLocation setTitle:[dir lastPathComponent]];
	[currentLocation setImage:icon];
}

- (void)switchManagedLocationFromPath:(NSString*)oldPath toPath:(NSString*)newPath
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
	NSMutableArray *directories = [NSMutableArray array];
	int i = 1;
	NSString *currentNumberedDir;
	NSString *directory;
	BOOL isDirectory;
	
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
		dirName = [directory lastPathComponent];
		newDir = [standardizedNewPath stringByAppendingPathComponent:dirName];
		
		[fileManager movePath:directory toPath:newDir handler:self];
	}
		
	[userDefaultsController setValue:newPath forKeyPath:@"values.ManageFiles.ManagedFolder.Location"];
	[self updateCurrentLocationForPopUpButton:managedFolderPopUpButton];
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

@end
