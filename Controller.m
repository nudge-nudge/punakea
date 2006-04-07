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
- (id) init
{
    if (self = [super init])
    {
		[self loadDataFromDisk];
		
		_query = [[NSMetadataQuery alloc] init];
		[_query setDelegate:self];
		[_query setNotificationBatchingInterval:0.3];
		[_query setGroupingAttributes:[NSArray arrayWithObjects:(id)kMDItemContentType, nil]];
		[_query setSortDescriptors:[NSArray arrayWithObject:[[[NSSortDescriptor alloc] initWithKey:(id)kMDItemFSName ascending:YES] autorelease]]];
	}
    return self;
}

- (void)awakeFromNib
{
	[NSApp setDelegate: self]; 
	[self setupToolbar];
	
	/* drawer code!!
	sidebarNibView = [[self viewFromNibWithName:@"Sidebar"] retain];
	[drawer setContentView:sidebarNibView];
	[drawer toggle:self];
	*/
	
	[outlineView setQuery:_query];
	
	//instantiate relatedTags and register as an observer to changes in selectedTags
	relatedTags = [[PARelatedTags alloc] initWithQuery:_query 
								 relatedTagsController:relatedTagsController];
	
	[selectedTagsController addObserver:self
							 forKeyPath:@"arrangedObjects"
								options:0
								context:NULL];
	
	[relatedTagsController addObserver:self
							 forKeyPath:@"arrangedObjects"
								options:0
								context:NULL];

	[self addObserver:self
		   forKeyPath:@"tags"
			  options:0
			  context:NULL];
	
	[self setVisibleTags:tags];
}

- (void)dealloc
{
    [_query release];	
    [super dealloc];
}

- (void) applicationWillTerminate:(NSNotification *)note 
{ 
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
- (NSMetadataQuery*)query 
{
	return _query;
}

- (NSMutableArray*)tags 
{
	return tags;
}

- (void)setTags:(NSMutableArray*)otherTags 
{
	[otherTags retain];
	[tags release];
	tags = otherTags;
}

- (NSMutableArray*)visibleTags;
{
	return visibleTags;
}

- (void)setVisibleTags:(NSMutableArray*)otherTags
{
	[otherTags retain];
	[visibleTags release];
	visibleTags = otherTags;
	
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

- (NSString *)pathForDataFile 
{ 
	NSFileManager *fileManager = [NSFileManager defaultManager]; 
	NSString *folder = @"~/Library/Application Support/Punakea/"; 
	folder = [folder stringByExpandingTildeInPath]; 
	
	if ([fileManager fileExistsAtPath: folder] == NO) 
		[fileManager createDirectoryAtPath: folder attributes: nil];
	
	NSString *fileName = @"tags.papk"; 
	return [folder stringByAppendingPathComponent: fileName]; 
}

- (void)saveDataToDisk 
{
	NSString *path  = [self pathForDataFile];
	NSMutableDictionary *rootObject = [NSMutableDictionary dictionary];
	[rootObject setValue:[self tags] forKey:@"tags"];
	
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
		[self setTags:[[NSMutableArray alloc] init]];
	else 
		[self setTags:loadedTags];
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

- (void)addToSelectedTags
{
	NSArray *selection = [relatedTagsController selectedObjects];
	if ([selection count] > 0)
	{
		[selectedTagsController addObject:[selection objectAtIndex:0]];
	}
}

//TODO
- (IBAction)clearSelectedTags:(id)sender
{
	[selectedTagsController removeObjects:[selectedTagsController arrangedObjects]];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
					  ofObject:(id)object 
                        change:(NSDictionary *)change
                       context:(void *)context
{
	if ([keyPath isEqual:@"arrangedObjects"]) 
	{
		//related or selected tags have changed
		if ([object isEqual:selectedTagsController])
		{
			[self selectedTagsHaveChanged];
		}
		else
		{
			[self relatedTagsHaveChanged];
		}
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
	
	//append all the tags queries to the string - if there are any
	//this way the query is only started, if there are any tags to look for
	if ([[selectedTagsController arrangedObjects] count] > 0)
	{
		NSMutableString *queryString = [NSMutableString stringWithString:@""];
		
		NSEnumerator *e = [[selectedTagsController arrangedObjects] objectEnumerator];
		PATag *tag;
		
		if (tag = [e nextObject]) 
		{
			NSString *anotherTagQuery = [NSString stringWithFormat:@"(%@)",[tag query]];
			[queryString appendString:anotherTagQuery];
		}
		
		while (tag = [e nextObject]) 
		{
			NSString *anotherTagQuery = [NSString stringWithFormat:@" && (%@)",[tag query]];
			[queryString appendString:anotherTagQuery];
		}
		
		NSPredicate *predicate = [NSPredicate predicateWithFormat:queryString];
		NSLog(@"predicate: %@",predicate);
		[_query setPredicate:predicate];
		[_query startQuery];
	}
	else 
	{
		//there are no selected tags, reset all tags
		[self setVisibleTags:tags];
	}
}

- (void)relatedTagsHaveChanged
{
	[self setVisibleTags:[NSArray arrayWithArray:[relatedTagsController arrangedObjects]]];
}

- (void)allTagsHaveChanged
{
	/*only do something if there are no selected tags,
	because then the relatedTags are shown */
	if ([[selectedTagsController arrangedObjects] count] == 0)
	{
		[self setVisibleTags:tags];
	}
}

#pragma mark working with tags
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
		[_query setGroupingAttributes:[NSArray arrayWithObjects:(id)kMDItemFSSize, nil]];
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
