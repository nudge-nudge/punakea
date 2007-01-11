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
		tags = [PATags sharedTags];
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

#pragma mark tag field delegates
/**
action called on dropping files to FileBox
 */
- (void)newTaggableObjectsHaveBeenDropped
{	
	// create new tagger window
	taggerController = [[TaggerController alloc] init];
	[[NSApplication sharedApplication] activateIgnoringOtherApps:YES];
	NSWindow *taggerWindow = [taggerController window];
	[taggerWindow makeKeyAndOrderFront:nil];
	[taggerController addTaggableObjects:[fileBox objects]];
}

#pragma mark notifications
- (void)screenDidChange:(NSNotification*)notification
{
	[[self window] reset];
}

@end
