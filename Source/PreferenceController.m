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

#import "PreferenceController.h"
#import "Core.h"

#import "NNTagging/NNTags.h"

@interface PreferenceController (PrivateAPI)

- (void)startOnLoginHasChanged;
- (void)managedFolderStateHasChanged;
- (void)tagsFolderStateHasChanged;
- (void)dropBoxStateHasChanged;

- (void)showTagsFolderWarning:(NSDictionary *)userInfo;
- (void)showDropBoxWarning:(NSDictionary *)userInfo;
- (void)switchSpecialFolderDir:(NSDictionary *)userInfo;

- (void)updateCurrentLocationForPopUpButton:(NSPopUpButton *)button;
- (void)moveSubdirectoriesFromPath:(NSString*)oldPath toPath:(NSString*)newPath tag:(NSInteger)tag;

- (void)displayWarningWithMessage:(NSString*)messageInfo;
- (void)tagsFolderWarningDidEnd:(NSAlert *)alert returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo;
- (void)dropBoxWarningDidEnd:(NSAlert *)alert returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo;

- (NSString *)locationKeyPathForMenuItemTag:(NSInteger)tag;
- (NSString *)enabledKeyPathForMenuItemTag:(NSInteger)tag;
- (NSPopUpButton *)popUpButtonForMenuItemTag:(NSInteger)tag;
- (NSString *)openPanelMessageForMenuItemTag:(NSInteger)tag;

- (BOOL)isLoginItem;
- (CFIndex)loginItemIndex;
- (void)updateDropBoxTagField;

- (void)createTagsFolderStructure;
- (void)cleanTagsFolder;

- (void)attachDropBoxFolderAction;
- (void)removeDropBoxFolderAction;

@end

NSString * const MANAGED_FOLDER_LOCATION_KEYPATH = @"values.ManageFiles.ManagedFolder.Location";
NSString * const TAGS_FOLDER_LOCATION_KEYPATH = @"values.ManageFiles.TagsFolder.Location";
NSString * const DROP_BOX_LOCATION_KEYPATH = @"values.ManageFiles.DropBox.Location";

NSString * const MANAGED_FOLDER_ENABLED_KEYPATH = @"values.ManageFiles.ManagedFolder.Enabled";
NSString * const TAGS_FOLDER_ENABLED_KEYPATH = @"values.ManageFiles.TagsFolder.Enabled";
NSString * const DROP_BOX_ENABLED_KEYPATH = @"values.ManageFiles.DropBox.Enabled";

NSString * const DROP_BOX_SCRIPTNAME = @"Punakea - Drop Box.scpt";


@implementation PreferenceController

#pragma mark init+dealloc
- (id)initWithCore:(Core*)aCore
{
	if (self = [super initWithWindowNibName:@"Preferences"])
	{
		userDefaultsController = [NSUserDefaultsController sharedUserDefaultsController];
				
		core = aCore;
		
		// Check if recentPage from UserDefaults is valid
		NSInteger recentPage = [[NSUserDefaults standardUserDefaults] integerForKey:@"punakea.preferences.prefspanel.recentpage"];
		if (recentPage > [tabView numberOfTabViewItems])
		{
			[[NSUserDefaults standardUserDefaults] setInteger:0
													   forKey:@"punakea.preferences.prefspanel.recentpage"];
		}
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
							 forKeyPath:MANAGED_FOLDER_ENABLED_KEYPATH
								options:0
								context:NULL];
	
	[userDefaultsController addObserver:self
							 forKeyPath:TAGS_FOLDER_ENABLED_KEYPATH
								options:0
								context:NULL];
	
	[userDefaultsController addObserver:self
							 forKeyPath:DROP_BOX_ENABLED_KEYPATH
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
	
	// Hotkey Recorder Control
	[hotkeyRecorderControl setAnimates:YES];
	[hotkeyRecorderControl setStyle:SRGreyStyle];
	
	KeyCombo keyCombo;
	keyCombo.code = [[userDefaultsController valueForKeyPath:@"values.General.Hotkey.Tagger.KeyCode"] shortValue];
	keyCombo.flags = [[userDefaultsController valueForKeyPath:@"values.General.Hotkey.Tagger.Modifiers"] integerValue];
	[hotkeyRecorderControl setKeyCombo:keyCombo];
}

- (void)dealloc
{
	[userDefaultsController removeObserver:self
								forKeyPath:@"values.General.StartOnLogin"];
	[userDefaultsController removeObserver:self
								forKeyPath:@"values.PAScheduledUpdateCheckInterval"];
	[userDefaultsController removeObserver:self
								forKeyPath:MANAGED_FOLDER_ENABLED_KEYPATH];
	[userDefaultsController removeObserver:self
								forKeyPath:TAGS_FOLDER_ENABLED_KEYPATH];
	[userDefaultsController removeObserver:self
								forKeyPath:DROP_BOX_ENABLED_KEYPATH];
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
		else if ([keyPath isEqualToString:MANAGED_FOLDER_ENABLED_KEYPATH])
		{
			[self managedFolderStateHasChanged];
		}
		else if ([keyPath isEqualToString:TAGS_FOLDER_ENABLED_KEYPATH])
		{
			[self tagsFolderStateHasChanged];
		}
		else if ([keyPath isEqualToString:DROP_BOX_ENABLED_KEYPATH])
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

- (void)managedFolderStateHasChanged
{
	if ([[userDefaultsController valueForKeyPath:MANAGED_FOLDER_ENABLED_KEYPATH] boolValue] == YES)
	{
		if ([userDefaultsController valueForKeyPath:MANAGED_FOLDER_LOCATION_KEYPATH] == nil)
		{	
			[self locateDirectory:[[[self popUpButtonForMenuItemTag:0] menu] itemAtIndex:2]];
		}
		else
		{
			[core createDirectoriesIfNeeded];
			[self updateCurrentLocationForPopUpButton:managedFolderPopUpButton];
		}
	}
}

- (void)tagsFolderStateHasChanged
{	
	if ([[userDefaultsController valueForKeyPath:TAGS_FOLDER_ENABLED_KEYPATH] boolValue] == YES)
	{
		if ([userDefaultsController valueForKeyPath:TAGS_FOLDER_LOCATION_KEYPATH] == nil)
		{	
			[self locateDirectory:[[[self popUpButtonForMenuItemTag:1] menu] itemAtIndex:2]];
		}
		else
		{
			[core createDirectoriesIfNeeded];
			[self updateCurrentLocationForPopUpButton:tagsFolderPopUpButton];
			
			[self createTagsFolderStructure];
		}
	}
	else
	{
		// Do some cleanup
		if ([userDefaultsController valueForKeyPath:TAGS_FOLDER_LOCATION_KEYPATH] != nil)
			[self cleanTagsFolder];
	}
}

- (void)dropBoxStateHasChanged
{	
	if ([[userDefaultsController valueForKeyPath:DROP_BOX_ENABLED_KEYPATH] boolValue] == YES)
	{
		if ([userDefaultsController valueForKeyPath:DROP_BOX_LOCATION_KEYPATH] == nil)
		{	
			[self locateDirectory:[[[self popUpButtonForMenuItemTag:2] menu] itemAtIndex:2]];
		}
		else
		{
			[core createDirectoriesIfNeeded];
			[self updateCurrentLocationForPopUpButton:dropBoxPopUpButton];
			
			[self updateDropBoxTagField];
		}
	}
	else
	{
		// Do some cleanup
		if ([userDefaultsController valueForKeyPath:DROP_BOX_LOCATION_KEYPATH] != nil)
		{
			// Remove the action from the folder
			[self removeDropBoxFolderAction];
			
			// Remove Script File	
			NSString *targetDir = @"~/Library/Scripts/Folder Action Scripts/";
			targetDir = [targetDir stringByStandardizingPath];			
			NSString *targetPath = [targetDir stringByAppendingPathComponent:DROP_BOX_SCRIPTNAME];
			
			[[NSFileManager defaultManager] removeFileAtPath:targetPath handler:NULL];
			
			[userDefaultsController setValue:nil forKeyPath:DROP_BOX_LOCATION_KEYPATH];
			
			[self updateCurrentLocationForPopUpButton:dropBoxPopUpButton];
		}
	}
}


#pragma mark file location
- (IBAction)locateDirectory:(id)sender
{
	NSString *keyPath = [self locationKeyPathForMenuItemTag:[sender tag]];
	
	NSString *currentPath = [[userDefaultsController valueForKeyPath:keyPath] retain];
	
	// create open panel with the needed settings
	NSOpenPanel *openPanel = [NSOpenPanel openPanel];
	
	[openPanel setMessage:[self openPanelMessageForMenuItemTag:[sender tag]]];
	
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

- (void)openPanelDidEnd:(NSOpenPanel *)panel returnCode:(NSInteger)returnCode contextInfo:(void  *)contextInfo
{	
	NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
	
	long tag = [(id)contextInfo tag];
	
	NSString *keyPath = [self locationKeyPathForMenuItemTag:tag];
	
	if (returnCode == NSOKButton)
	{
		NSString *newDir = [[panel filenames] objectAtIndex:0];
		
		NSString *oldDir = [userDefaultsController valueForKeyPath:keyPath];
						
		if (oldDir)
			[userInfo setObject:oldDir forKey:@"oldDir"];
		
		[userInfo setObject:newDir forKey:@"newDir"];
		[userInfo setObject:[NSNumber numberWithInteger:tag] forKey:@"tag"];
		
		// For the Tags Folder, show an alert, as files might be deleted from within this folder
		if (tag == 1)
		{		
			[self performSelector:@selector(showTagsFolderWarning:)
					   withObject:userInfo
					   afterDelay:0.2];
		}
		else if (tag == 2)
		{
			[self performSelector:@selector(showDropBoxWarning:)
					   withObject:userInfo
					   afterDelay:0.2];
		}
		else
		{
			[self performSelectorInBackground:@selector(switchSpecialFolderDir:)
								   withObject:userInfo];
		}

//		[self updateCurrentLocationForPopUpButton:popUpButton];
	}
	else
	{
		// Check if there has been a directory selected before.
		// If not, disable the checkbox again
		if ([userDefaultsController valueForKeyPath:keyPath] == nil)
		{
			NSString *enabledKeyPath = [self enabledKeyPathForMenuItemTag:[(id)contextInfo tag]];
			[userDefaultsController setValue:NO forKeyPath:enabledKeyPath];
		} else {
			NSPopUpButton *popUpButton = [self popUpButtonForMenuItemTag:[(id)contextInfo tag]];
			[popUpButton selectItemAtIndex:0];
		}
	}
}

- (void)showTagsFolderWarning:(NSDictionary *)userInfo
{
	NSAlert *alert = [[[NSAlert alloc] init] autorelease];
	[alert setMessageText:[NSString stringWithFormat:
						   NSLocalizedStringFromTable(@"DESTINATION_FOLDER_MAY_GET_DELETED",@"FileManager",@""),[userInfo objectForKey:@"newDir"]]];
	[alert setInformativeText:NSLocalizedStringFromTable(@"DESTINATION_FOLDER_MAY_GET_DELETED_INFORMATIVE",@"FileManager",@"")];
	[alert addButtonWithTitle:NSLocalizedStringFromTable(@"OK",@"Global",@"")];
	[alert addButtonWithTitle:NSLocalizedStringFromTable(@"CANCEL",@"Global",@"")];
	
	[alert setAlertStyle:NSWarningAlertStyle];
	
	[alert beginSheetModalForWindow:[self window]
					  modalDelegate:self 
					 didEndSelector:@selector(tagsFolderWarningDidEnd:returnCode:contextInfo:)
						contextInfo:[userInfo retain]];
}

- (void)showDropBoxWarning:(NSDictionary *)userInfo
{
	NSAlert *alert = [[[NSAlert alloc] init] autorelease];
	[alert setMessageText:[NSString stringWithFormat:
						   NSLocalizedStringFromTable(@"TAGS_FOLDER_NEEDS_TO_COPY_SCRIPT_FILE_MESSAGE",@"FileManager",@""),[userInfo objectForKey:@"newDir"]]];
	[alert setInformativeText:NSLocalizedStringFromTable(@"TAGS_FOLDER_NEEDS_TO_COPY_SCRIPT_FILE_INFORMATIVE",@"FileManager",@"")];
	[alert addButtonWithTitle:NSLocalizedStringFromTable(@"OK",@"Global",@"")];
	[alert addButtonWithTitle:NSLocalizedStringFromTable(@"CANCEL",@"Global",@"")];
	
	[alert setAlertStyle:NSWarningAlertStyle];
	
	[alert beginSheetModalForWindow:[self window]
					  modalDelegate:self 
					 didEndSelector:@selector(dropBoxWarningDidEnd:returnCode:contextInfo:)
						contextInfo:[userInfo retain]];
}

- (void)switchSpecialFolderDir:(NSDictionary *)userInfo
{	
	NSInteger tag	 = [[userInfo objectForKey:@"tag"] integerValue];
	NSString *oldDir = [userInfo objectForKey:@"oldDir"];
	NSString *newDir = [userInfo objectForKey:@"newDir"];
	
	NSPopUpButton *popUpButton = [self popUpButtonForMenuItemTag:tag];
	NSString *keyPath = [self locationKeyPathForMenuItemTag:tag];
	
	// Break if nothing to do
	if(oldDir && [oldDir isEqualTo:newDir])
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
		if (oldDir)
			[self moveSubdirectoriesFromPath:oldDir toPath:newDir tag:tag];
	}
	else if (tag == 1)		// Tags Folder
	{
		// Remove old dir
		if (oldDir)
			[self cleanTagsFolder];
		
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
		if (oldDir)
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
		if (oldDir)
			[self moveSubdirectoriesFromPath:oldDir toPath:newDir tag:tag];
		
		[self attachDropBoxFolderAction];
	}
}

/*- (IBAction)switchSpecialFolderDirToDefault:(id)sender
{
	NSString *keyPath = [self locationKeyPathForMenuItemTag:[sender tag]];
	
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
	[userInfo setObject:[NSNumber numberWithInteger:[sender tag]] forKey:@"tag"];
	
	[self switchSpecialFolderDir:userInfo];		
}*/


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
		NSInteger i = [dirName integerValue];
			
		for (i;i>0;i--)
		{
			NSString *newDirName = [NSString stringWithFormat:@"%ld",i];
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

- (void)alertDidEnd:(NSAlert *)alert returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo
{
	// noting
	return;
}

- (void)tagsFolderWarningDidEnd:(NSAlert *)alert returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo
{	
	NSDictionary* userInfo = (NSDictionary*)contextInfo;
	NSInteger tag = 1;
		
	if (returnCode == NSAlertFirstButtonReturn)
	{		
		[self performSelectorInBackground:@selector(switchSpecialFolderDir:)
							   withObject:userInfo];
	}
	else
	{		
		if ([userDefaultsController valueForKeyPath:[self locationKeyPathForMenuItemTag:tag]] == nil)
		{
			[userDefaultsController setValue:NO forKeyPath:[self enabledKeyPathForMenuItemTag:tag]];
		}
		[self updateCurrentLocationForPopUpButton:[self popUpButtonForMenuItemTag:tag]];
	}
}

- (void)dropBoxWarningDidEnd:(NSAlert *)alert returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo
{	
	NSDictionary* userInfo = (NSDictionary*)contextInfo;
	NSInteger tag = 2;
	
	if (returnCode == NSAlertFirstButtonReturn)
	{
		// Copy Folder Action Script to Library
		
		NSString *targetDir = @"~/Library/Scripts/Folder Action Scripts/";
		targetDir = [targetDir stringByStandardizingPath];
		
		NSString *targetPath = [targetDir stringByAppendingPathComponent:DROP_BOX_SCRIPTNAME];
		
		NSFileManager *fileManager = [NSFileManager defaultManager];
			
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
		
		[self performSelectorInBackground:@selector(switchSpecialFolderDir:)
							   withObject:userInfo];
	}
	else
	{		
		if ([userDefaultsController valueForKeyPath:[self locationKeyPathForMenuItemTag:tag]] == nil)
		{
			[userDefaultsController setValue:NO forKeyPath:[self enabledKeyPathForMenuItemTag:tag]];
		}
		[self updateCurrentLocationForPopUpButton:[self popUpButtonForMenuItemTag:tag]];
	}
}


#pragma mark Shortcut Recorder
- (void)shortcutRecorder:(SRRecorderControl *)aRecorder keyComboDidChange:(KeyCombo)newKeyCombo
{
	[userDefaultsController setValue:[NSNumber numberWithShort:newKeyCombo.code]
						  forKeyPath:@"values.General.Hotkey.Tagger.KeyCode"];
	[userDefaultsController setValue:[NSNumber numberWithUnsignedInt:newKeyCombo.flags]
						  forKeyPath:@"values.General.Hotkey.Tagger.Modifiers"];
	[[NSUserDefaults standardUserDefaults] synchronize];
}


#pragma mark helper
- (void)updateCurrentLocationForPopUpButton:(NSPopUpButton *)button
{
	id currentLocation = [button itemAtIndex:0];
	
	NSString *keyPath = @"";
	if(button == managedFolderPopUpButton)	keyPath = MANAGED_FOLDER_LOCATION_KEYPATH;
	if(button == tagsFolderPopUpButton)		keyPath = TAGS_FOLDER_LOCATION_KEYPATH;
	if(button == dropBoxPopUpButton)		keyPath = DROP_BOX_LOCATION_KEYPATH;
	   
	NSString *dir = [userDefaultsController valueForKeyPath:keyPath];
	dir = [dir stringByExpandingTildeInPath];
	
	BOOL isDirectory;
	
	if (dir)
	{
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
		
		// Select this item
		[button selectItemAtIndex:0];
	} 
	else
	{
		// If there's no path stored, select the "Choose" option
		[button selectItemAtIndex:2];
	}	
}

- (void)moveSubdirectoriesFromPath:(NSString*)oldPath toPath:(NSString*)newPath tag:(NSInteger)tag
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
	NSInteger i = 1;
	NSString *currentNumberedDir;
	NSString *directory;
	BOOL isDirectory;
	
	if (tag == 0)		// Managed Folder - Copy only the numbered dirs
	{		
		directories = [NSMutableArray array];
		
		while (true)
		{
			currentNumberedDir = [NSString stringWithFormat:@"/%ld/",i];
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
		
		for(NSInteger j=0; j < [directories count]; j++)
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

- (NSString *)locationKeyPathForMenuItemTag:(NSInteger)tag
{
	switch (tag)
	{
		case 1:		return TAGS_FOLDER_LOCATION_KEYPATH;
		case 2:		return DROP_BOX_LOCATION_KEYPATH;
		default:	return MANAGED_FOLDER_LOCATION_KEYPATH;
	}
}


- (NSString *)enabledKeyPathForMenuItemTag:(NSInteger)tag
{
	switch (tag)
	{
		case 1:		return TAGS_FOLDER_ENABLED_KEYPATH;
		case 2:		return DROP_BOX_ENABLED_KEYPATH;
		default:	return MANAGED_FOLDER_ENABLED_KEYPATH;
	}
}

- (NSPopUpButton *)popUpButtonForMenuItemTag:(NSInteger)tag
{
	switch (tag)
	{
		case 1:		return tagsFolderPopUpButton;
		case 2:		return dropBoxPopUpButton;
		default:	return managedFolderPopUpButton;
	}
}

- (NSString *)openPanelMessageForMenuItemTag:(NSInteger)tag
{
	switch (tag)
	{
		case 1:		return NSLocalizedStringFromTable(@"CHOOSE_LOCATION_OF_TAGS_FOLDER", @"FileManager", nil);
		case 2:		return NSLocalizedStringFromTable(@"CHOOSE_LOCATION_OF_DROP_BOX", @"FileManager", nil);
		default:	return NSLocalizedStringFromTable(@"CHOOSE_LOCATION_OF_MANAGED_FOLDER", @"FileManager", nil);
;
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

- (void)updateDropBoxTagField
{
	NNTagsCreationOptions creationOptions = NNTagsCreationOptionFull;
	
	// Do not create tags if Drop Box is disabled	
	BOOL dropBoxEnabled = [[userDefaultsController valueForKeyPath:@"values.ManageFiles.DropBox.Enabled"] boolValue];
	if (!dropBoxEnabled)
		creationOptions = NNTagsCreationOptionNone;	
	
	// Get tags from User Defaults and set them for Tag Field
	
	TagAutoCompleteController *tagAutoCompleteController = [tagField delegate];
	
	NSArray *tagNames = [userDefaultsController valueForKeyPath:@"values.ManageFiles.DropBox.Tags"];
	NSMutableArray *tags = [NSMutableArray array];
	
	for (NSString *tagName in tagNames)
	{
		NNTag *tag = [[NNTags sharedTags] tagForName:tagName creationOptions:creationOptions];
		
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

- (void)cleanTagsFolder
{
	// Removes all subdirs of tags folder
	
	BusyWindowController *busyWindowController = [[core busyWindow] delegate];
	
	NSString *tagsFolderDir = [userDefaultsController valueForKeyPath:TAGS_FOLDER_LOCATION_KEYPATH];
	tagsFolderDir = [tagsFolderDir stringByStandardizingPath];
	
	[busyWindowController setMessage:NSLocalizedStringFromTable(@"BUSY_WINDOW_MESSAGE_REMOVING_TAGS_FOLDER", @"FileManager", nil)];
	[busyWindowController performBusySelector:@selector(cleanTagsFolder)
									 onObject:[NNTagging tagging]];
	
	[[core busyWindow] center];
	[NSApp runModalForWindow:[core busyWindow]];
}

- (void)attachDropBoxFolderAction
{
	NSString *dropBoxDir = [userDefaultsController valueForKeyPath:DROP_BOX_LOCATION_KEYPATH];
	dropBoxDir = [dropBoxDir stringByStandardizingPath];
	
	// Attach Folder Action
	
	NSString *s = @"tell application \"System Events\"\n";
	
	s = [s stringByAppendingString:@"set folder actions enabled to true\n"];
	
	s = [s stringByAppendingString:@"set scriptPath to (path to Folder Action scripts as Unicode text) & \""];
	s = [s stringByAppendingString:DROP_BOX_SCRIPTNAME];
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
		[[NNTags sharedTags] tagForName:tagName creationOptions:NNTagsCreationOptionFull];
	}
}

- (void)removeDropBoxFolderAction
{
	NSString *dropBoxDir = [userDefaultsController valueForKeyPath:DROP_BOX_LOCATION_KEYPATH];
	dropBoxDir = [dropBoxDir stringByStandardizingPath];
	
	// Remove Folder Action
	
	NSString *s = @"tell application \"System Events\"\n";
	
	s = [s stringByAppendingString:@"remove action from \""];
	s = [s stringByAppendingString:dropBoxDir];
	s = [s stringByAppendingString:@"\" using action name \""];
	s = [s stringByAppendingString:DROP_BOX_SCRIPTNAME];
	s = [s stringByAppendingString:@"\""];
	s = [s stringByAppendingString:@"\n"];
	
	s = [s stringByAppendingString:@"end tell"];
	
	NSAppleScript *folderActionScript = [[NSAppleScript alloc] initWithSource:s];
	[folderActionScript executeAndReturnError:nil];
}

@end
