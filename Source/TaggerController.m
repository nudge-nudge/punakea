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
/* not in use at the moment
- (void)addTagToField:(PASimpleTag*)tag
{
	// when the user started typing some stuff, and a new tag is added,
	// the temporary typing is discarded, and the new tag added instead.
	// is this good behaviour?
	NSMutableArray *newContent = [[[tagField objectValue] mutableCopy] autorelease];
	
	// add tag to the last position
	[newContent insertObject:tag atIndex:[currentCompleteTagsInField count]];
	[tagField setObjectValue:newContent];
	
	// set first responder to tagField
	[[tagField window] makeFirstResponder:tagField];
}
*/

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
	NSMutableArray *tagsOnSomeFiles = [NSMutableArray array];
	NSMutableArray *tagsOnAllFiles = [NSMutableArray array];

	NSArray *allTags = [tagger tagsOnFiles:[fileController selectedObjects]];
	
	NSEnumerator *fileEnumerator = [[fileController selectedObjects] objectEnumerator];
	NSString *file;
	
	// all files are checked for their tags,
	// if a tag is not on a single file, it is not on all files, thus not shown in the tokenField
	while (file = [fileEnumerator nextObject])
	{
		NSArray *tagsOnFile = [tagger tagsOnFiles:[NSArray arrayWithObject:file]];
		
		NSEnumerator *tagEnumerator = [allTags objectEnumerator];
		PATag *tag;
		
		while (tag = [tagEnumerator nextObject])
		{
			if (![tagsOnFile containsObject:tag] && ![tagsOnSomeFiles containsObject:tag])
			{
				[tagsOnSomeFiles addObject:tag];
			}
		}
	}
	
	NSEnumerator *allTagsEnumerator = [allTags objectEnumerator];
	PATag *tag;
	
	// now all tags not in tagsOnSomeFiles but on allTags are on all files
	while (tag = [allTagsEnumerator nextObject])
	{
		if (![tagsOnSomeFiles containsObject:tag] && ![tagsOnAllFiles containsObject:tag])
		{
			[tagsOnAllFiles addObject:tag];
		}
	}
	
	[tagField setObjectValue:tagsOnAllFiles];
	[currentCompleteTagsInField removeAllTags];
	[currentCompleteTagsInField addObjectsFromArray:tagsOnAllFiles];
	
	[self displayRestTags:tagsOnSomeFiles];
}

- (void)displayRestTags:(NSArray*)restTags
{
	NSMutableString *displayString = [NSMutableString stringWithFormat:@"%i tags not shown:",[restTags count]];
	
	NSEnumerator *e = [restTags objectEnumerator];
	PASimpleTag *tag;
	
	while (tag = [e nextObject])
	{
		[displayString appendFormat:@" %@",[tag name]];
	}
	
	[self setRestDisplayString:displayString];
}

- (void)setRestDisplayString:(NSString*)aString
{
	[restDisplayString release];
	[aString retain];
	restDisplayString = aString;
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