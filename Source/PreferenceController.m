//
//  PreferenceController.m
//  punakea
//
//  Created by Johannes Hoffart on 29.08.06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "PreferenceController.h"

@interface PreferenceController (PrivateAPI)

- (void)startOnLoginHasChanged;
- (void)updateButtonToCurrentLocation;

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

- (IBAction)locateDirectory:(id)sender
{
	NSString *currentPath = [[userDefaultsController valueForKeyPath:@"values.General.ManagedFilesLocation"] retain];
	
	// create open panel with the needed settings
	NSOpenPanel *openPanel = [NSOpenPanel openPanel];
	
	[openPanel setAllowsMultipleSelection:NO];
	[openPanel setCanChooseFiles:NO];
	[openPanel setCanChooseDirectories:YES];
	[openPanel setCanCreateDirectories:YES];
	
	[openPanel beginSheetForDirectory:currentPath
								   file:nil
								  types:[NSArray arrayWithObject:NSFileTypeDirectory]
						 modalForWindow:[self window]
						  modalDelegate:self
						 didEndSelector:@selector(openPanelDidEnd:returnCode:contextInfo:) 
							contextInfo:NULL];
}

- (void)openPanelDidEnd:(NSOpenPanel *)panel returnCode:(int)returnCode  contextInfo:(void  *)contextInfo
{
	if (returnCode == NSOKButton)
	{
		NSString *oldPath = [userDefaultsController valueForKeyPath:@"values.General.ManagedFilesLocation"];
		NSString *newPath = [[panel filenames] objectAtIndex:0];
		
		// move old files if there are any - 
		// only copy the numbered folders!
		NSFileManager *fileManager = [NSFileManager defaultManager];
		int i = 1;
		
		while (true)
		{
			NSString *currentNumberedDir = [NSString stringWithFormat:@"/%i/",i];
			NSString *oldDirectory = [oldPath stringByAppendingPathComponent:currentNumberedDir];
			
			if ([fileManager fileExistsAtPath:oldDirectory])
			{
				NSString *newDirectory = [newPath stringByAppendingPathComponent:currentNumberedDir];
				[fileManager movePath:oldDirectory toPath:newDirectory handler:self];
				i++;
			}
			else
			{
				break;
			}
		}
			
		[userDefaultsController setValue:newPath forKeyPath:@"values.General.ManagedFilesLocation"];
		[self updateButtonToCurrentLocation];
		[folderButton selectItemAtIndex:0];
	}
	else if (returnCode == NSCancelButton)
	{
		[folderButton selectItemAtIndex:0];
	}
}

- (void)fileManager:(NSFileManager *)manager willProcessPath:(NSString *)path
{
	// TODO
}

- (BOOL)fileManager:(NSFileManager *)manager shouldProceedAfterError:(NSDictionary *)errorInfo
{
	// TODO
}

@end
