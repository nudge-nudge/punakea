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
	[[self window] setActivatesLastFrontApp:NO];
	
	// create new tagger window
	taggerController = [[TaggerController alloc] init];
	
	// Check whether to manage files or not
	BOOL manageFiles = [[NSUserDefaults standardUserDefaults] boolForKey:@"ManageFiles.ManagedFolder.Enabled"];
	[taggerController setManageFiles:manageFiles];
	
	NSEvent *currentEvent = [NSApp currentEvent];
    unsigned flags = [currentEvent modifierFlags];
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
	[[self window] setActivatesLastFrontApp:NO];
	
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
	[[self window] setActivatesLastFrontApp:NO];
}

- (BOOL)mouseInSidebarWindow
{
	NSPoint mouseLocation = [[self window] mouseLocationOutsideOfEventStream];
	NSPoint mouseLocationRelativeToWindow = [[self window] convertBaseToScreen:mouseLocation];
		
	return (NSPointInRect(mouseLocationRelativeToWindow,[[self window] frame]) || (mouseLocationRelativeToWindow.x == 0));
}	

@end
