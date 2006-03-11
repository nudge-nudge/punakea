#import "Controller.h"

@interface Controller (PrivateAPI)

- (void)selectedTagsHaveChanged;

@end

@implementation Controller

- (id) init
{
    if (self = [super init])
    {
		[self loadDataFromDisk];
		
		_query = [[NSMetadataQuery alloc] init];
		[_query setNotificationBatchingInterval:0.3];
		[_query setGroupingAttributes:[NSArray arrayWithObjects:(id)kMDItemKind, (id)kMDItemFSSize, nil]];
	}
    return self;
}

- (void)awakeFromNib
{
	[NSApp setDelegate: self]; 
	[self setupToolbar];
	
	sidebarNibView = [[self viewFromNibWithName:@"Sidebar"] retain];
	[drawer setContentView:sidebarNibView];
	//[drawer toggle:self];
	[fileMatrix initWithMetadataQuery:_query];
	
	//[outlineView setIntercellSpacing:NSMakeSize(0, 0)];
	
	//instantiate relatedTags and register as an observer to changes in selectedTags
	relatedTags = [[PARelatedTags alloc] initWithQuery:_query 
												  tags:tags 
								 relatedTagsController:relatedTagsController];
	
	[selectedTagsController addObserver:self
							 forKeyPath:@"arrangedObjects"
								options:0
								context:NULL];
	
	[selectedTagsController addObserver:relatedTags
							 forKeyPath:@"arrangedObjects"
								options:0
								context:NULL];
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

- (NSView*)viewFromNibWithName:(NSString*)nibName{
    NSView * 		newView;
    SubViewController *	subViewController;
    
    subViewController = [SubViewController alloc];
    // Creates an instance of SubViewController which loads the specified nib.
    [subViewController initWithNibName:nibName andOwner:self];
    newView = [subViewController view];
    return newView;
}

- (NSMetadataQuery*)query {
	return _query;
}

- (NSMutableArray*)tags {
	return tags;
}

- (void)setTags:(NSMutableArray*)otherTags {
	[otherTags retain];
	[tags release];
	tags = otherTags;
}

- (void)dealloc
{
    [_query release];	
    [super dealloc];
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
	[NSKeyedArchiver archiveRootObject:rootObject toFile:path]; 
}

- (void)loadDataFromDisk 
{
	NSString *path = [self pathForDataFile];
	NSDictionary *rootObject = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
	NSMutableArray *loadedTags = [rootObject valueForKey:@"tags"];
	
	if ([loadedTags count] == 0) 
		[self setTags:[[NSMutableArray alloc] init]];
	else 
		[self setTags:loadedTags];
}	

//---- BEGIN tag stuff ----
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
		[self selectedTagsHaveChanged];
}

//needs to be called whenever the active tags have been changed
- (void)selectedTagsHaveChanged 
{
	//stop an active query
	if ([_query isStarted]) 
	{
		[_query stopQuery];
	}
	
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
}
//---- END tag stuff ----
@end
