#import "TaggerController.h"

@interface TaggerController (PrivateAPI)

/**
adds tag to tagField (use from "outside")
 @param tag tag to add 
 */
- (void)addTagToField:(PASimpleTag*)tag;

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
- (id)initWithWindowNibName:(NSString*)windowNibName
{
	if (self = [super initWithWindowNibName:windowNibName])
	{
		typeAheadFind = [[PATypeAheadFind alloc] init];
		tagger = [PATagger sharedInstance];
		tags = [tagger tags];
		currentCompleteTagsInField = [[PASelectedTags alloc] init];
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
	[fileController removeObserver:self forKeyPath:@"selectionIndexes"];

	[currentCompleteTagsInField release];
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

#pragma mark tokenField delegate
- (NSArray *)tokenField:(NSTokenField *)tokenField 
completionsForSubstring:(NSString *)substring 
		   indexOfToken:(int)tokenIndex 
	indexOfSelectedItem:(int *)selectedIndex
{
	NSMutableArray *results = [NSMutableArray array];
	
	NSEnumerator *e = [[typeAheadFind tagsForPrefix:substring] objectEnumerator];
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
	[[PATagger sharedInstance] addTags:tokens toFiles:[fileController selectedObjects]];
	[currentCompleteTagsInField addObjectsFromArray:tokens];
	
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
	return [tagger createTagForName:editingString];
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
//TODO!
- (IBAction)selectionHasChanged
{
	NSDictionary *tagDictionary = [tagger tagNamesWithCountForFilesAtPaths:[fileController selectedObjects]];
	int selectionCount = [[fileController selectedObjects] count];
	
	NSMutableArray *tagsOnAllFiles = [NSMutableArray array];
	NSMutableArray *tagsOnSomeFiles = [NSMutableArray array];
	
	NSEnumerator *e = [[tagDictionary allKeys] objectEnumerator];
	NSString *tagName;
	
	while (tagName = [e nextObject])
	{
		int count = [[tagDictionary objectForKey:tagName] intValue];
		PATag *tag = [tagger tagForName:tagName includeTempTag:NO];
		
		if (count == selectionCount && tag)
		{
			[tagsOnAllFiles addObject:tag];
		}
		else if (tag)
		{
			[tagsOnSomeFiles addObject:tag];
		}
	}	
	
	[tagField setObjectValue:tagsOnAllFiles];
	[currentCompleteTagsInField removeAllTags];
	[currentCompleteTagsInField addObjectsFromArray:tagsOnAllFiles];
	
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
}
@end