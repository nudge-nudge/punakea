#import "TaggerController.h"

@interface TaggerController (PrivateAPI)

/**
adds tag to tagField (use from "outside")
 @param tag tag to add 
 */
- (void)addTagToField:(PASimpleTag*)tag;

/**
called when tags have changed, updates query
 */
- (void)tagsHaveChanged;

/**
called when file selection has changed
 */
- (void)selectionHasChanged;

/**
resets the tagger window (called when window is closed)
 */
- (void)resetTaggerContent;

- (void)displayRestTags:(NSArray*)restTags;

@end

@implementation TaggerController

#pragma mark init + dealloc
- (id)initWithWindowNibName:(NSString*)windowNibName tags:(PATags*)newTags
{
	if (self = [super initWithWindowNibName:windowNibName])
	{
		typeAheadFind = [[PATypeAheadFind alloc] initWithTags:newTags];
		tags = newTags;
		currentCompleteTagsInField = [[PASelectedTags alloc] init];
		
		// create sort descriptor
		NSSortDescriptor *popularDescriptor = [[NSSortDescriptor alloc] initWithKey:@"absoluteRating" ascending:NO];
		popularTagsSortDescriptors = [[NSArray alloc] initWithObjects:popularDescriptor,nil];
		[popularDescriptor release];
		
		// related tags with no current selection
		relatedTags = [[PARelatedTags alloc] initWithTags:tags selectedTags:[NSMutableArray array]];
	}
	return self;
}

- (void)awakeFromNib
{
	// observe file selection
	[fileController addObserver:self forKeyPath:@"selectionIndexes" options:0 context:NULL];
}

- (void)dealloc
{
	[relatedTags release];
	[popularTagsSortDescriptors release];
	[currentCompleteTagsInField release];
	[tags release];
	[typeAheadFind release];
	[super dealloc];
}

#pragma mark observing
- (void)observeValueForKeyPath:(NSString *)keyPath
					  ofObject:(id)object 
                        change:(NSDictionary *)change
                       context:(void *)context
{
	// only the file selection is observed
	[self selectionHasChanged];
}

#pragma mark accessors
- (void)addFiles:(NSMutableArray*)newFiles
{
	[fileController addObjects:newFiles];
}

- (PASelectedTags*)currentCompleteTagsInField
{
	return currentCompleteTagsInField;
}

- (void)setCurrentCompleteTagsInField:(PASelectedTags*)newTags
{
	[newTags retain];
	[currentCompleteTagsInField release];
	currentCompleteTagsInField = newTags;
	[self tagsHaveChanged];
}

#pragma mark functionality
- (void)addTagToField:(PASimpleTag*)tag
{
	// when the user started typing some stuff, and a new tag is added,
	// the temporary typing is discarded, and the new tag added instead.
	// is this good behaviour? TODO
	NSMutableArray *newContent = [[[tagField objectValue] mutableCopy] autorelease];
	
	// add tag to the last position
	[newContent insertObject:tag atIndex:[currentCompleteTagsInField count]];
	[tagField setObjectValue:newContent];
	
	// set first responder to tagField
	[[tagField window] makeFirstResponder:tagField];
}

- (void)tagsHaveChanged
{
	[relatedTags setSelectedTags:currentCompleteTagsInField];
}


#pragma mark tokenField delegate
- (NSArray *)tokenField:(NSTokenField *)tokenField 
completionsForSubstring:(NSString *)substring 
		   indexOfToken:(int)tokenIndex 
	indexOfSelectedItem:(int *)selectedIndex
{
	[typeAheadFind setPrefix:substring];
	
	NSMutableArray *results = [NSMutableArray array];
	
	NSEnumerator *e = [[typeAheadFind matchingTags] objectEnumerator];
	PASimpleTag *tag;
	
	while (tag = [e nextObject])
	{
		[results addObject:[tag name]];
	}
	
	return results;
}

- (NSArray *)tokenField:(NSTokenField *)tokenField 
	   shouldAddObjects:(NSArray *)tokens 
				atIndex:(unsigned)index
{
	[[PATagger sharedInstance] addTags:tokens ToFiles:[fileController selectedObjects]];
	[currentCompleteTagsInField addObjectsFromArray:tokens];
	
	// needs to be called manually because setter of currentCompleteTagsInField is not called
	[self tagsHaveChanged];
	
	// everything will be added
	return tokens;
}

// the following methods are for 'translation' from tag to string and back (NSTokenField)
- (NSString *)tokenField:(NSTokenField *)tokenField displayStringForRepresentedObject:(id)representedObject
{
	return [representedObject name];
}

- (NSString *)tokenField:(NSTokenField *)tokenField editingStringForRepresentedObject:(id)representedObject
{
	return [representedObject name];
}

- (id)tokenField:(NSTokenField *)tokenField representedObjectForEditingString:(NSString *)editingString
{
	return [tags simpleTagForName:editingString];
}

- (void)controlTextDidChange:(NSNotification *)aNotification
{
	// only do something if a tag has been completely deleted
	// adding tags is handled by ... shouldAddObjects: ...
	if ([[tagField objectValue] count] < [currentCompleteTagsInField count])
	{
		// look for deleted tags
		NSMutableArray *deletedTags = [NSMutableArray array];
		
		NSEnumerator *e = [currentCompleteTagsInField objectEnumerator];
		PASimpleTag *tag;
		
		while (tag = [e nextObject])
		{
			if (![[tagField objectValue] containsObject:tag])
			{
				[deletedTags addObject:tag];
			}
		}
		
		// now remove the tags to be deleted from currentCompleteTagsInField - to keep in sync with tagField
		[currentCompleteTagsInField removeObjectsInArray:deletedTags];
		
		// remove the deleted tags from all files
		[[PATagger sharedInstance] removeTags:deletedTags fromFiles:[fileController selectedObjects]];
	}
}

#pragma mark gui change actions
- (IBAction)addPopularTag
{
	NSArray *selection = [popularTagsController selectedObjects];
	
	if ([selection count] == 1)
	{
		[self addTagToField:[selection objectAtIndex:0]];
	}
}

- (IBAction)selectionHasChanged
{
	NSDictionary *tagDictionary = [tags simpleTagNamesWithCountForFilesAtPaths:[fileController selectedObjects]];
	int selectionCount = [[fileController selectedObjects] count];
	
	NSMutableArray *tagsOnAllFiles = [NSMutableArray array];
	NSMutableArray *tagsOnSomeFiles = [NSMutableArray array];
	
	NSEnumerator *e = [[tagDictionary allKeys] objectEnumerator];
	NSString *tagName;
	
	while (tagName = [e nextObject])
	{
		int count = [[tagDictionary objectForKey:tagName] intValue];
		
		if (count == selectionCount)
		{
			[tagsOnAllFiles addObject:[tags simpleTagForName:tagName]];
		}
		else
		{
			[tagsOnSomeFiles addObject:[tags simpleTagForName:tagName]];
		}
	}	
	
	[tagField setObjectValue:tagsOnAllFiles];
	[self setCurrentCompleteTagsInField:tagsOnAllFiles];
	
	[self displayRestTags:tagsOnSomeFiles];
}

- (void)displayRestTags:(NSArray*)restTags
{
	NSMutableString *displayString = [NSMutableString stringWithFormat:@"%i tags are not on all selected files:",[restTags count]];
	
	NSEnumerator *e = [restTags objectEnumerator];
	PASimpleTag *tag;
	
	while (tag = [e nextObject])
	{
		[displayString appendFormat:@" %@",[tag name]];
	}
	
	[restTagField setObjectValue:displayString];
}

#pragma mark window delegate
- (BOOL)windowShouldClose:(id)sender
{
	// reset content before closing
	[self resetTaggerContent];
	return YES;
}

- (void)resetTaggerContent
{
	// files
	[fileController removeObjects:[fileController arrangedObjects]];
	
	// tagField - cascades to currentCompleteTagsInField
	[self setCurrentCompleteTagsInField:[[PASelectedTags alloc] init]];
	
	// relatedTags
	[relatedTags removeAllObjectsFromRelatedTags];
}
@end