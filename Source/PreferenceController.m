//
//  PreferenceController.m
//  punakea
//
//  Created by Johannes Hoffart on 29.08.06.
//  Copyright 2006 nudge:nudge. All rights reserved.
//

#import "PreferenceController.h"

@interface PreferenceController (PrivateAPI)

- (void)startOnLoginHasChanged;
- (void)updateButtonToCurrentLocation;
- (void)switchManagedLocationFromPath:(NSString*)oldPath toPath:(NSString*)newPath;

@end

@implementation PreferenceController

#pragma mark init+dealloc
- (id)init
{
	if (self = [super initWithWindowNibName:@"Preferences"])
	{
		userDefaultsController = [NSUserDefaultsController sharedUserDefaultsController];
	}
	return self;
}

- (void)awakeFromNib
{
	[self bind:@"startOnLogin"
	  toObject:userDefaultsController
   withKeyPath:@"values.General.StartOnLogin"
	   options:nil];
	
	[userDefaultsController addObserver:self
							 forKeyPath:@"values.General.StartOnLogin"
								options:0
								context:NULL];
	
	[self updateButtonToCurrentLocation];
}

#pragma mark observing
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	if ([keyPath isEqualToString:@"values.General.StartOnLogin"])
	{
		[self startOnLoginHasChanged];
	}
}

#pragma mark event handling
- (void)startOnLoginHasChanged
{
	NSString *bundlePath = [[NSBundle mainBundle] bundlePath];
	
	// path leads to script calling punakea with -noBrowser YES
	NSString *path = [bundlePath stringByAppendingString:@"/Contents/Resources/Punakea"];
	
	OSStatus	status;
	CFIndex 	itemCount;
	CFIndex 	itemIndex;
	Boolean		found;
	
	CFArrayRef loginItems = NULL; 
	CFURLRef url = CFURLCreateWithFileSystemPath(kCFAllocatorDefault, (CFStringRef)path, kCFURLPOSIXPathStyle, false); 
	status = LIAECopyLoginItems(&loginItems); 
	
	if (status == noErr) {
		itemCount = CFArrayGetCount(loginItems);
		itemIndex = 0;
		found = false;
		NSDictionary *dic;
		
		while ((itemIndex < itemCount) && ! found) {
			dic = CFArrayGetValueAtIndex(loginItems,itemIndex);
			NSURL *dicUrl = [dic valueForKey:@"URL"];
			
			if ([dicUrl isEqualTo:url])
				found = true;
			else
				itemIndex++;
		}
		
		if (found && !startOnLogin) 
			LIAERemove(itemIndex); 
		CFRelease(loginItems); 
    }

	if (startOnLogin) 
		LIAEAddURLAtEnd(url, false); 
	CFRelease(url);
}

#pragma mark file location
- (IBAction)locateDirectory:(id)sender
{
	NSString *currentPath = [[userDefaultsController valueForKeyPath:@"values.General.ManagedFilesLocation"] retain];
	
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
	NSString *oldPath = [userDefaultsController valueForKeyPath:@"values.General.ManagedFilesLocation"];
	
	NSString *path = [[NSBundle mainBundle] pathForResource:@"UserDefaults" ofType:@"plist"];
	NSDictionary *appDefaults = [NSDictionary dictionaryWithContentsOfFile:path];
	
	// set path to default path
	NSString *defaultPath = [appDefaults objectForKey:@"General.ManagedFilesLocation"];
	
	NSFileManager *fileManager = [NSFileManager defaultManager];
	BOOL isDirectory;
	
	if ([fileManager fileExistsAtPath:[defaultPath stringByStandardizingPath] isDirectory:&isDirectory])
	{
		if (!isDirectory)
		{
			[self displayWarningWithMessage:NSLocalizedStringFromTable(@"MANAGED_FILES_DEFAULT_NOT_FOLDER_ERROR",@"FileManager",@"")];
			[folderButton selectItemAtIndex:0];
			return;
		}
	}
	else
	{
		[fileManager createDirectoryAtPath:[defaultPath stringByStandardizingPath] attributes:nil];
	}
	
	[self switchManagedLocationFromPath:oldPath toPath:defaultPath];
	[folderButton selectItemAtIndex:0];
}

- (void)openPanelDidEnd:(NSOpenPanel *)panel returnCode:(int)returnCode  contextInfo:(void  *)contextInfo
{
	if (returnCode == NSOKButton)
	{
		NSString *oldPath = [userDefaultsController valueForKeyPath:@"values.General.ManagedFilesLocation"];
		NSString *newPath = [[panel filenames] objectAtIndex:0];
		
		[self switchManagedLocationFromPath:oldPath toPath:newPath];
		
		[folderButton selectItemAtIndex:0];
	}
	else if (returnCode == NSCancelButton)
	{
		[folderButton selectItemAtIndex:0];
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
- (void)updateButtonToCurrentLocation
{
	id <NSMenuItem> location = [folderButton itemAtIndex:0];
	
	NSString *dir = [userDefaultsController valueForKeyPath:@"values.General.ManagedFilesLocation"];
	
	NSString *title = [dir lastPathComponent];
	NSImage *icon = [[NSWorkspace sharedWorkspace] iconForFile:dir];
	[icon setSize:NSMakeSize(16.0,16.0)];
	
	[location setTitle:title];
	[location setImage:icon];
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
	
	[userDefaultsController setValue:newPath forKeyPath:@"values.General.ManagedFilesLocation"];
	[self updateButtonToCurrentLocation];
}

@end
