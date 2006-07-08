#import "Core.h"

@interface Core (PrivateAPI)

- (void)selectedTagsHaveChanged;
- (void)relatedTagsHaveChanged;
- (void)allTagsHaveChanged;
- (PATag*)tagWithBestAbsoluteRating:(NSArray*)tagSet;
- (void)setupToolbar;

@end

@implementation Core

#pragma mark init + dealloc
+ (void)initialize
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

	NSString *path = [[NSBundle mainBundle] pathForResource:@"UserDefaults" ofType:@"plist"];
	NSDictionary *appDefaults = [NSDictionary dictionaryWithContentsOfFile:path];
	[defaults registerDefaults:appDefaults];
}

- (id)init
{
    if (self = [super init])
    {
		tagger = [PATagger sharedInstance];
		[self loadDataFromDisk];
	}
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

- (void)awakeFromNib
{
	[NSApp setDelegate:self]; 
	[self setupToolbar];
	
	BrowserController *browserController = [[BrowserController alloc] initWithWindowNibName:@"Browser"];
	NSWindow *browserWindow = [browserController window];
	[browserWindow makeKeyAndOrderFront:nil];
	
	SidebarController *sidebarController = [[SidebarController alloc] initWithWindowNibName:@"Sidebar"];
	[sidebarController window];
}

- (void)applicationWillTerminate:(NSNotification *)note 
{ 
	[[NSUserDefaults standardUserDefaults] synchronize];
	[self saveDataToDisk]; 
} 

- (void)setupToolbar
{
    NSToolbar *toolbar = [[NSToolbar alloc] initWithIdentifier:@"mainToolbar"];
    [toolbar setDelegate:self];
    [toolbar setAllowsUserCustomization:YES];
    [toolbar setAutosavesConfiguration:YES];
    [[self window] setToolbar:[toolbar autorelease]];
}

#pragma mark loading and saving tags
/* TODO deprecated
- (void)openFile
{
	NSArray *selection = [resultController selectedObjects];
	
	if ([selection count] > 0)
	{
		NSString *path = [[selection objectAtIndex:0] valueForKey:@"kMDItemPath"];
		NSURL *fileURL = [NSURL fileURLWithPath: path];
		
		NSWorkspace * ws = [NSWorkspace sharedWorkspace];
		[ws openURL: fileURL];
	}
}
*/

- (NSString *)pathForDataFile 
{ 
	NSFileManager *fileManager = [NSFileManager defaultManager]; 
	NSString *folder = @"~/Library/Application Support/Punakea/"; 
	folder = [folder stringByExpandingTildeInPath]; 
	
	if ([fileManager fileExistsAtPath: folder] == NO) 
		[fileManager createDirectoryAtPath: folder attributes: nil];
	
	NSString *fileName = @"tags.plist"; 
	return [folder stringByAppendingPathComponent: fileName]; 
}

- (void)saveDataToDisk 
{
	NSString *path  = [self pathForDataFile];
	NSMutableDictionary *rootObject = [NSMutableDictionary dictionary];
	[rootObject setValue:[[tagger tags] tags] forKey:@"tags"];
	
	NSMutableData *data = [NSMutableData data];
	NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
	[archiver setOutputFormat:NSPropertyListXMLFormat_v1_0];
	[archiver encodeObject:rootObject];
	[archiver finishEncoding];
	[data writeToFile:path atomically:YES];
}

- (void)loadDataFromDisk 
{
	NSString *path = [self pathForDataFile];
	
	NSMutableData *data = [NSData dataWithContentsOfFile:path];
	NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
	NSMutableDictionary *rootObject = [unarchiver decodeObject];
	[unarchiver finishDecoding];
	[unarchiver release];
	
	NSMutableArray *loadedTags = [rootObject valueForKey:@"tags"];
	
	if ([loadedTags count] == 0) 
	{
		[[tagger tags] setTags:[[NSMutableArray alloc] init]];
	}
	else 
	{
		[[tagger tags] setTags:loadedTags];
	}
}	

#pragma mark working with tags (renaming and deleting)
- (void)removeTag:(PASimpleTag*)tag
{
	NSArray *files;
	//TODO get all files into files
	
	[tagger removeTag:tag fromFiles:files];
}

- (void)renameFromTag:(PASimpleTag*)fromTag to:(PASimpleTag*)toTag
{
	NSArray *files;
	//TODO get all files into files
	
	[tagger renameTag:fromTag toTag:toTag onFiles:files];
}

@end
