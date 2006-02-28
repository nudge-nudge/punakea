#import "Controller.h"
#import "SubViewController.h"
#import "PATagger.h"
#import "FileGroup.h"

@implementation Controller

// For OutlineView Bindings
- (id) init
{
    if (self = [super init])
    {
		_query = [[NSMetadataQuery alloc] init];
		[_query setNotificationBatchingInterval:0.3];
		[_query setGroupingAttributes:[NSArray arrayWithObjects:(id)kMDItemKind, (id)kMDItemFSSize, nil]];
		
		NSNotificationCenter *nf = [NSNotificationCenter defaultCenter];
        [nf addObserver:self selector:@selector(queryNote:) name:nil object:_query];
		
		myString = @"My String";
    }
    return self;
}

- (void)awakeFromNib
{
	[self setupToolbar];
	
	sidebarNibView = [[self viewFromNibWithName:@"Sidebar"] retain];
	[drawer setContentView:sidebarNibView];
	//[drawer toggle:self];
	[relatedTagsController setupWithQuery:_query];
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
	//PATag *tag = [[PATag alloc] initWithName:@"test_tag" query:[NSString stringWithFormat:@"kMDItemKeywords = '%@'",[textfieldJohannes stringValue]]];
	//[selectedTags addTagToTags:tag];
	//[tag release];
	[self selectedTagsHaveChanged];
}

- (NSMetadataQuery *)query {
	return _query;
}

//returns the path to file instead of the NSMetadataItem ... important for binding
/*- (id)metadataQuery:(NSMetadataQuery *)query replacementObjectForResultObject:(NSMetadataItem *)result {
	return [result valueForKey:@"kMDItemPath"];
}*/

- (void)queryNote:(NSNotification *)note {
        NSLog([note name]);
}

- (void) dealloc
{
    [_query release];	
    [super dealloc];
}

//---- BEGIN tag stuff ----
//needs to be called whenever the active tags have been changed
- (void)selectedTagsHaveChanged {
	NSLog(@"%i",[_query resultCount]);

	//stop an active query
	if ([_query isStarted]) {
		[_query stopQuery];
	}

	NSMutableString *queryString = [NSMutableString stringWithString:@""];
	
	//append all the tags queries to the string
	NSEnumerator *e = [[selectedTagsController arrangedObjects] objectEnumerator];
	PATag *tag;
	
	if (tag = [e nextObject]) {
		NSString *anotherTagQuery = [NSString stringWithFormat:@"(%@)",[tag query]];
		[queryString appendString:anotherTagQuery];
	}
	
	while (tag = [e nextObject]) {
		NSString *anotherTagQuery = [NSString stringWithFormat:@" && (%@)",[tag query]];
		[queryString appendString:anotherTagQuery];
	}
	
	NSPredicate *predicate = [NSPredicate predicateWithFormat:queryString];
	NSLog(@"predicate: %@",predicate);
	[_query setPredicate:predicate];
	
	//only start if query isn't empty
	if (![queryString isEqualToString:@""]) {
		[_query startQuery];
	}
}
//---- END tag stuff ----
@end
