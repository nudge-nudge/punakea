#import "Controller.h"
#import "SubViewController.h"
#import "PATagger.h"

@implementation Controller

- (id) init
{
    if (self = [super init])
    {
		_query = [[NSMetadataQuery alloc] init];
		[_query setNotificationBatchingInterval:0.3];
		[_query setGroupingAttributes:[NSArray arrayWithObjects:(id)kMDItemKind, (id)kMDItemFSSize, nil]];
		
		tags = [[NSMutableArray alloc] init];
		[self loadDataFromDisk];
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
	[relatedTagsController setupWithQuery:_query tags:tags];
	[fileMatrix initWithMetadataQuery:_query];
	
	//[outlineView setIntercellSpacing:NSMakeSize(0, 0)];
}

- (void) applicationWillTerminate: (NSNotification *)note 
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

-(IBAction)hoffartTest:(id)sender {
	[self selectedTagsHaveChanged];
}

- (NSMetadataQuery *) query {
	return _query;
}

- (NSMutableArray *) tags {
	return tags;
}

- (void) setTags:(NSMutableArray*)otherTags {
	[otherTags retain];
	[tags release];
	tags = otherTags;
}

- (void) dealloc
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
	{ 
		[fileManager createDirectoryAtPath: folder attributes: nil]; 
	} 
	
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
	{
		[self setTags:[[NSMutableArray alloc] init]];
	} 	
	else 
	{
		[self setTags:loadedTags];
	}
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

- (IBAction)clearSelectedTags:(id)sender
{
	[selectedTagsController removeObjects:[selectedTagsController arrangedObjects]];
}

//needs to be called whenever the active tags have been changed
- (void)selectedTagsHaveChanged 
{
	NSLog(@"%i",[_query resultCount]);

	//stop an active query
	if ([_query isStarted]) 
	{
		[_query stopQuery];
	}

	NSMutableString *queryString = [NSMutableString stringWithString:@""];
	
	//append all the tags queries to the string
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
	
	//only start if query isn't empty
	if (![queryString isEqualToString:@""]) 
	{
		[_query startQuery];
	}
}
//---- END tag stuff ----
@end
