#import "Controller.h"

@interface Controller (PrivateAPI)

- (void)selectedTagsHaveChanged;
- (void)relatedTagsHaveChanged;
- (void)allTagsHaveChanged;
- (PATag*)tagWithBestAbsoluteRating:(NSArray*)tagSet;
- (void)setupToolbar;

@end

@implementation Controller

#pragma mark init + dealloc
+ (void)initialize
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

	NSString *path = [[NSBundle mainBundle] pathForResource:@"UserDefaults" ofType:@"plist"];
	NSDictionary *appDefaults = [NSDictionary dictionaryWithContentsOfFile:path];
	[defaults registerDefaults:appDefaults];
}

- (id) init
{
    if (self = [super init])
    {
		tags = [[PATags alloc] init];
		selectedTags = [[PASelectedTags alloc] init];
		
		simpleTagFactory = [[PASimpleTagFactory alloc] init];

		[self loadDataFromDisk];
	
		_query = [[PAQuery alloc] init];
		[_query setGroupingAttributes:[NSArray arrayWithObjects:(id)kMDItemContentType, nil]];
		[_query setSortDescriptors:[NSArray arrayWithObject:[[[NSSortDescriptor alloc] initWithKey:(id)kMDItemFSName ascending:YES] autorelease]]];
		
		relatedTags = [[PARelatedTags alloc] initWithTags:tags selectedTags:[NSMutableArray array]];
		
		typeAheadFind = [[PATypeAheadFind alloc] initWithTags:tags];
	}
    return self;
}

- (void)dealloc
{
	[typeAheadFind release];
	[relatedTags release];
    [_query release];
	[simpleTagFactory release];
	[selectedTags release];
	[tags release];
    [super dealloc];
}

- (void)awakeFromNib
{
	[NSApp setDelegate: self]; 
	[self setupToolbar];
	
	/* // Drawer
	sidebarNibView = [[self viewFromNibWithName:@"Sidebar"] retain];
	[drawer setContentView:sidebarNibView];
	[drawer toggle:self];
	*/
	
	[outlineView setQuery:_query];
	
	//register as an observer to changes in selectedTags and more
	[selectedTags addObserver:self
				   forKeyPath:@"selectedTags"
					  options:0
					  context:NULL];
	
	[relatedTags addObserver:self
				  forKeyPath:@"relatedTags"
					 options:0
					 context:NULL];

	[tags addObserver:self
		   forKeyPath:@"tags"
			  options:0
			  context:NULL];
	
	[self setVisibleTags:[tags tags]];
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

#pragma mark accessors
- (PAQuery*)query 
{
	return _query;
}

- (PATags*)tags 
{
	return tags;
}

- (void)setTags:(PATags*)otherTags 
{
	[otherTags retain];
	[tags release];
	tags = otherTags;
}

- (PARelatedTags*)relatedTags;
{
	return relatedTags;
}

- (void)setRelatedTags:(PARelatedTags*)otherRelatedTags
{
	[otherRelatedTags retain];
	[relatedTags release];
	relatedTags = otherRelatedTags;
}

- (PASelectedTags*)selectedTags;
{
	return selectedTags;
}

- (void)setSelectedTags:(PASelectedTags*)otherSelectedTags
{
	[otherSelectedTags retain];
	[selectedTags release];
	selectedTags = otherSelectedTags;
}


- (NSMutableArray*)visibleTags;
{
	return visibleTags;
}

- (void)setVisibleTags:(NSMutableArray*)otherTags
{
	if (visibleTags != otherTags)
	{
		[visibleTags release];
		visibleTags = [otherTags retain];
	}
	
	//TODO fix me!!
	if ([visibleTags count] > 0)
		[self setCurrentBestTag:[self tagWithBestAbsoluteRating:visibleTags]];
}

- (PATag*)currentBestTag
{
	return currentBestTag;
}

- (void)setCurrentBestTag:(PATag*)otherTag
{
	[otherTag retain];
	[currentBestTag release];
	currentBestTag = otherTag;
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
	[rootObject setValue:[tags tags] forKey:@"tags"];
	
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
		[tags setTags:[[NSMutableArray alloc] init]];
	}
	else 
	{
		[tags setTags:loadedTags];
	}
}	

#pragma mark tag stuff
- (PATag*)tagWithBestAbsoluteRating:(NSArray*)tagSet
{
	NSEnumerator *e = [tagSet objectEnumerator];
	PATag *tag;
	PATag *maxTag;
	
	if (tag = [e nextObject])
		maxTag = tag;
	
	while (tag = [e nextObject])
	{
		if ([tag absoluteRating] > [maxTag absoluteRating])
			maxTag = tag;
	}	
	
	return maxTag;
}

//TODO
- (IBAction)clearSelectedTags:(id)sender
{
	[selectedTags removeAllObjects];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
					  ofObject:(id)object 
                        change:(NSDictionary *)change
                       context:(void *)context
{
	if ([keyPath isEqual:@"selectedTags"]) 
	{
		[self selectedTagsHaveChanged];
	}
		
	if ([keyPath isEqual:@"relatedTags"])
	{
		[self relatedTagsHaveChanged];
	}
	
	if ([keyPath isEqual:@"tags"]) 
	{
		[self allTagsHaveChanged];
	}
}

//needs to be called whenever the active tags have been changed
- (void)selectedTagsHaveChanged 
{
	//stop an active query
	if ([_query isStarted]) 
		[_query stopQuery];
	
	//the query is only started, if there are any tags to look for
	if ([selectedTags count] > 0)
	{
		[_query setTags:[selectedTags selectedTags]];
		[_query startQuery];
	}
	else 
	{
		//there are no selected tags, reset all tags
		[self setVisibleTags:[tags tags]];
	}
}

- (void)relatedTagsHaveChanged
{
	[self setVisibleTags:[relatedTags relatedTags]];
}

- (void)allTagsHaveChanged
{
	/*only do something if there are no selected tags,
	because then the relatedTags are shown */
	if ([selectedTags count] == 0)
	{
		[self setVisibleTags:[tags tags]];
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
		
#pragma mark Temp
- (void)setGroupingAttributes:(id)sender;
{
	NSSegmentedControl *sc = sender;
	if([sc selectedSegment] == 0) {
		[_query setGroupingAttributes:[NSArray arrayWithObjects:(id)kMDItemContentType, nil]];
	}
	if([sc selectedSegment] == 1) {
		[_query setGroupingAttributes:[NSArray arrayWithObjects:nil]];
	}
}

- (NSView*)viewFromNibWithName:(NSString*)nibName
{
    NSView * 		newView;
    SubViewController *	subViewController;
    
    subViewController = [SubViewController alloc];
    // Creates an instance of SubViewController which loads the specified nib.
    [subViewController initWithNibName:nibName andOwner:self];
    newView = [subViewController view];
    return newView;
}

@end
