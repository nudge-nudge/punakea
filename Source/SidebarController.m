#import "SidebarController.h"

@interface SidebarController (PrivateAPI)

- (void)addTagToFileTags:(PATag*)tag;
- (void)updateTagsOnFile;

@end

@implementation SidebarController

#pragma mark init+dealloc
- (id)initWithWindowNibName:(NSString*)nibName
{
	if (self = [super initWithWindowNibName:nibName])
	{
		tagger = [PATagger sharedInstance];
		tags = [tagger tags];
		dropManager = [PADropManager sharedInstance];
		
		recentTagGroup = [[PARecentTagGroup alloc] init];
		popularTagGroup = [[PAPopularTagGroup alloc] init];
	}
	return self;
}

- (void)awakeFromNib 
{	
	//observe files on fileBox
	[fileBox addObserver:self forKeyPath:@"files" options:0 context:NULL];
	
	//drag & drop
	[popularTagsTable registerForDraggedTypes:[dropManager handledPboardTypes]];
	popularTagTableController = [[PASidebarTableViewDropController alloc] initWithTags:popularTags];
	[popularTagsTable setDataSource:popularTagTableController];
	
	[recentTagsTable registerForDraggedTypes:[dropManager handledPboardTypes]];
	recentTagTableController = [[PASidebarTableViewDropController alloc] initWithTags:recentTags];
	[recentTagsTable setDataSource:recentTagTableController];
}

- (void)dealloc
{
	[recentTagsTable unregisterDraggedTypes];
	[popularTagsTable unregisterDraggedTypes];
	
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
	if ([keyPath isEqual:@"files"]) 
		[self newFilesHaveBeenDropped];
}

#pragma mark tag field delegates
/**
action called on dropping files to FileBox
 */
- (void)newFilesHaveBeenDropped
{	
	// create new tagger window
	taggerController = [[TaggerController alloc] init];
	[[NSApplication sharedApplication] activateIgnoringOtherApps:YES];
	NSWindow *taggerWindow = [taggerController window];
	[taggerWindow makeKeyAndOrderFront:nil];
	[taggerController addFiles:[fileBox files]];
}

#pragma mark window delegate
- (void)windowDidChangeScreen:(NSNotification *)aNotification
{
	NSLog(@"sidebar did change screen");
	[[self window] mouseEvent];
}

- (void)windowDidChangeScreenProfile:(NSNotification *)aNotification
{
	NSLog(@"sidebar did change screen profile");
	[[self window] mouseEvent];
}

@end
