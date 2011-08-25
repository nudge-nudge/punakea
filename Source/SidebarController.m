// Copyright (c) 2006-2011 nudge:nudge (Johannes Hoffart & Daniel Bär). All rights reserved.
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

#import "SidebarController.h"

@interface SidebarController (PrivateAPI)

- (void)addTagToFileTags:(NNTag*)tag;
- (void)updateTagsOnFile;

@end

@implementation SidebarController

#pragma mark init+dealloc
- (id)initWithWindowNibName:(NSString*)nibName
{
	if (self = [super initWithWindowNibName:nibName])
	{
		tags = [NNTags sharedTags];
		dropManager = [PADropManager sharedInstance];
		
		recentTagGroup = [[PARecentTagGroup alloc] init];
		popularTagGroup = [[PAPopularTagGroup alloc] init];
	}
	return self;
}

- (void)awakeFromNib 
{	
	//observe files on fileBox
	[fileBox addObserver:self forKeyPath:@"objects" options:0 context:NULL];
	
	//drag & drop
	[popularTagsTable registerForDraggedTypes:[dropManager handledPboardTypes]];
	popularTagTableController = [[PASidebarTableViewDropController alloc] initWithTags:popularTags];
	[popularTagsTable setDataSource:popularTagTableController];
	
	[recentTagsTable registerForDraggedTypes:[dropManager handledPboardTypes]];
	recentTagTableController = [[PASidebarTableViewDropController alloc] initWithTags:recentTags];
	[recentTagsTable setDataSource:recentTagTableController];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(screenDidChange:)
												 name:NSApplicationDidChangeScreenParametersNotification
											   object:[NSApplication sharedApplication]];
}

- (void)dealloc
{
	[fileBox removeObserver:self forKeyPath:@"objects"];
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[recentTagsTable unregisterDraggedTypes];
	[popularTagsTable unregisterDraggedTypes];
	
	[recentTagTableController release];
	[popularTagTableController release];
	
	[popularTagGroup release];
	[recentTagGroup release];
	[dropManager release];
	[super dealloc];
}

#pragma mark observing
- (void)observeValueForKeyPath:(NSString *)keyPath
					  ofObject:(id)object 
                        change:(NSDictionary *)change
                       context:(void *)context
{
	if ([keyPath isEqual:@"objects"]) 
		[self newTaggableObjectsHaveBeenDropped];
}

#pragma mark sidebar delegates
/**
action called on dropping files to FileBox
 */
- (void)newTaggableObjectsHaveBeenDropped
{	
	// set window not to activate last front app
	[(NNActiveAppSavingPanel *)[self window] setActivatesLastActiveApp:NO];
	
	// create new tagger window
	taggerController = [[TaggerController alloc] init];
	
	// Check whether to manage files or not
	BOOL manageFiles = [[NSUserDefaults standardUserDefaults] boolForKey:@"ManageFiles.ManagedFolder.Enabled"];
	[taggerController setManageFiles:manageFiles];
	
	NSEvent *currentEvent = [NSApp currentEvent];
    NSUInteger flags = [currentEvent modifierFlags];
    if (flags & NSAlternateKeyMask)
	{
		manageFiles = !manageFiles;
		[taggerController setManageFiles:manageFiles];
	}
	
	[[NSApplication sharedApplication] activateIgnoringOtherApps:YES];
	
	NSWindow *taggerWindow = [taggerController window];
	[taggerWindow makeKeyAndOrderFront:nil];
	
	[taggerController addTaggableObjects:[fileBox objects]];
}

- (IBAction)tagClicked:(id)sender
{
	// set window not to activate last front app
	[[self window] setActivatesLastActiveApp:NO];
	
	NNTag *tag;
	
	NSTableColumn *column = [[sender tableColumns] objectAtIndex:[sender clickedColumn]];
	
	if ([[column identifier] isEqualToString:@"popularTags"])
	{
		tag = [[popularTags arrangedObjects] objectAtIndex:[sender clickedRow]];
	}
	else if ([[column identifier] isEqualToString:@"recentTags"])
	{
		tag = [[recentTags arrangedObjects] objectAtIndex:[sender clickedRow]];
	}
	
	[[[NSApplication sharedApplication] delegate] searchForTags:[NSMutableArray arrayWithObject:tag]];
}

#pragma mark notifications
- (void)screenDidChange:(NSNotification*)notification
{
	[[self window] reset];
}

#pragma mark Accessors
- (id)taggerController
{
	return taggerController;
}

#pragma mark function
- (void)appShouldStayFront
{
	// set window not to activate last front app
	[[self window] setActivatesLastActiveApp:NO];
}

- (BOOL)mouseInSidebarWindow
{
	NSPoint mouseLocation = [[self window] mouseLocationOutsideOfEventStream];
	NSPoint mouseLocationRelativeToWindow = [[self window] convertBaseToScreen:mouseLocation];
		
	return (NSPointInRect(mouseLocationRelativeToWindow,[[self window] frame]) || (mouseLocationRelativeToWindow.x == 0));
}	

@end
