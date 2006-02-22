#import "Controller.h"
#import "SubViewController.h"
#import "PATaggerInterface.h"
#import "FileGroup.h"

@implementation Controller

- (void)awakeFromNib
{
	[self setupToolbar];
	
	sidebarNibView = [[self viewFromNibWithName:@"Sidebar"] retain];
	[drawer setContentView:sidebarNibView];
	[drawer toggle:self];

	query = [[NSMetadataQuery alloc] init];
	[query setNotificationBatchingInterval:0.3]; 

	relatedTags = [[PARelatedTags alloc] initWithQuery:query];
	selectedTags = [[PASelectedTags alloc] init];
	
	//hoffart test code
	ti = [PATaggerInterface new];
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
	PATag *tag = [[PATag alloc] initWithName:@"test_tag" query:[NSString stringWithFormat:@"kMDItemKeywords = '%@'",[textfieldJohannes stringValue]]];
	[selectedTags addTagToTags:tag];
	[tag release];
	[self selectedTagsHaveChanged];
}

// For OutlineView Bindings
- (id) init
{
    if (self = [super init])
    {
        fileGroups = [[NSMutableArray alloc] init];
		myString = @"My String";
    }
    return self;
}

- (void) dealloc
{
    [fileGroups release];
    [relatedTags release];
	[selectedTags release];
	
    [super dealloc];
}

/*- (void) setFileGroups: (NSArray *)newFileGroups
{
    if (fileGroups != newFileGroups)
    {
        [fileGroups autorelease];
        fileGroups = [[NSMutableArray alloc] initWithArray: newFileGroups];
    }
}*/

//---- BEGIN tag stuff ----
//needs to be called whenever the active tags have been changed
- (void)selectedTagsHaveChanged {
	NSLog(@"%i",[query resultCount]);

	//stop an active query
	if ([query isStarted]) {
		[query stopQuery];
	}

	NSMutableString *queryString = [NSMutableString stringWithString:@""];
	
	//append all the tags queries to the string
	NSEnumerator *e = [selectedTags objectEnumerator];
	PATag *tag;
	
	//TODO hack, only looks for the first tag
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
	[query setPredicate:predicate];
	
	//only start if query isn't empty
	if (![queryString isEqualToString:@""]) {
		[query startQuery];
	}
}
//---- END tag stuff ----
@end
