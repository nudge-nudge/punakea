#import "TaggerController.h"

@interface TaggerController (PrivateAPI)

/**
adds tag to tagField (use from "outside")
 @param tag tag to add 
 */
- (void)addTagToField:(PASimpleTag*)tag;

/**
called when files have changed
 */
- (void)filesHaveChanged;

/**
resets the tagger window (called when window is closed)
 */
- (void)resetTaggerContent;

- (void)displayRestTags:(NSArray*)restTags;

- (void)resizeTokenField;

@end

@implementation TaggerController

#pragma mark init + dealloc
- (id)init
{
	if (self = [super initWithWindowNibName:@"Tagger"])
	{
		typeAheadFind = [[PATypeAheadFind alloc] init];
		tagger = [PATagger sharedInstance];
		tags = [tagger tags];
		currentCompleteTagsInField = [[PASelectedTags alloc] init];
		dropManager = [PADropManager sharedInstance];
		
		// custom data cell
		fileCell = [[PAFileCell alloc] init];
	}
	return self;
}

- (void)awakeFromNib
{
	// autosave name
	[[self window] setFrameAutosaveName:@"punakea.tagger"];
	
	// table view drop support
	[tableView registerForDraggedTypes:[NSArray arrayWithObject:NSFilenamesPboardType]];
	
	// set custom data + header cell
	NSArray *columns = [tableView tableColumns];
	[[columns objectAtIndex:0] setDataCell:fileCell];
	
	if(!headerCell)
	{
		NSString *title = [[[columns objectAtIndex:0] headerCell] stringValue];
		headerCell = [[PATaggerHeaderCell alloc] initTextCell:title];
	}	
	[[columns objectAtIndex:0] setHeaderCell:headerCell];
	
	// token field wrapping
	[[tagField cell] setWraps:YES];
	
	[fileController addObserver:self
					 forKeyPath:@"arrangedObjects"
						options:nil
						context:NULL];
}

- (void)dealloc
{
	[headerCell release];
	[fileCell release];
	[fileController removeObserver:self forKeyPath:@"arrangedObjects"];
	[tableView unregisterDraggedTypes];
	[currentCompleteTagsInField release];
	[typeAheadFind release];
	[super dealloc];
}

#pragma mark observing
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	if ([keyPath isEqualToString:@"arrangedObjects"])
	{
		[self filesHaveChanged];
	}
}

#pragma mark accessors
- (void)addFiles:(NSArray*)newFiles
{
	[fileController addObjects:newFiles];
}

- (NSArray*)files
{
	return [fileController arrangedObjects];
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
				atIndex:(unsigned)idx
{
	[currentCompleteTagsInField addObjectsFromArray:tokens];
	
	[[PATagger sharedInstance] addTags:tokens toFiles:[fileController arrangedObjects]];
	
	// resize field if neccessary
	[self performSelector:@selector(resizeTokenField) 
			   withObject:nil 
			   afterDelay:0.05];
	
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
	if (editingString && [editingString isNotEqualTo:@""])
		return [tagger createTagForName:editingString];
	else
		return nil;
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
		[[PATagger sharedInstance] removeTags:deletedTags fromFiles:[fileController arrangedObjects]];

		// resize tokenfield if neccessary
		[self resizeTokenField];
	}
}

- (void)resizeTokenField
{
	NSRect oldTokenFieldFrame = [tagField frame];
	NSSize cellSize = [[tagField cell] cellSizeForBounds:[tagField bounds]];
	cellSize.height = (cellSize.height > 22) ? cellSize.height : 22;
	float sizeDifference = cellSize.height - oldTokenFieldFrame.size.height;
	
	[tagField setFrame:NSMakeRect(oldTokenFieldFrame.origin.x,
								  oldTokenFieldFrame.origin.y - sizeDifference,
								  oldTokenFieldFrame.size.width,
								  cellSize.height)];
	
	NSRect oldTableViewFrame = [[tableView enclosingScrollView] frame];
	[[tableView enclosingScrollView] setFrame:NSMakeRect(oldTableViewFrame.origin.x,
														 oldTableViewFrame.origin.y,
														 oldTableViewFrame.size.width,
														 oldTableViewFrame.size.height - sizeDifference)];
	
	[[[self window] contentView] setNeedsDisplay:YES];
}

#pragma mark gui change actions
- (void)filesHaveChanged
{
	NSMutableArray *tagsOnSomeFiles = [NSMutableArray array];
	NSMutableArray *tagsOnAllFiles = [NSMutableArray array];

	NSArray *allTags = [tagger tagsOnFiles:[fileController arrangedObjects]];
	
	NSEnumerator *fileEnumerator = [[fileController arrangedObjects] objectEnumerator];
	PAFile *file;
	
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
	[[self window] makeFirstResponder:tagField];
}

#pragma mark window delegate
- (void)windowWillClose:(NSNotification *)aNotification
{
	[self autorelease];
}

- (void)windowDidResize:(NSNotification *)aNotification
{
	[self resizeTokenField];
}

- (void)resetTaggerContent
{
	// files
	[fileController removeObjects:[fileController arrangedObjects]];
	
	// tagField - cascades to currentCompleteTagsInField
	[self setCurrentCompleteTagsInField:[[PASelectedTags alloc] init]];
}

#pragma mark tableview drop support
- (NSDragOperation)tableView:(NSTableView*)tv 
				validateDrop:(id <NSDraggingInfo>)info 
				 proposedRow:(int)row 
	   proposedDropOperation:(NSTableViewDropOperation)op
{
	int fileCount = [[self files] count];

	if (fileCount == 0)
	{
		[tableView setDropRow:-1 dropOperation:NSTableViewDropOn];
	} 
	else if (fileCount > 0 && row < fileCount)
	{
		[tableView setDropRow:fileCount dropOperation:NSTableViewDropAbove];
	}
	
	return [dropManager performedDragOperation:[info draggingPasteboard]];
}
	
- (BOOL)tableView:(NSTableView*)tv 
	   acceptDrop:(id <NSDraggingInfo>)info 
			  row:(int)row 
	dropOperation:(NSTableViewDropOperation)op
{
	NSArray *files = [dropManager handleDrop:[info draggingPasteboard]];
	
	NSMutableArray *result = [NSMutableArray array];
	
	NSEnumerator *e = [files objectEnumerator];
	PAFile *file;
	
	while (file = [e nextObject])
	{
		if (![[fileController arrangedObjects] containsObject:file])
		{
			[result addObject:file];
		}
	}
	
	[self addFiles:result];
	
	return YES;
}


#pragma mark Background View delegate
- (void)addButtonClicked:(id)sender
{
	// create open panel with the needed settings
	NSOpenPanel *openPanel = [NSOpenPanel openPanel];
	
	[openPanel setAllowsMultipleSelection:YES];
	[openPanel setCanChooseFiles:YES];
	[openPanel setCanChooseDirectories:NO];
	[openPanel setCanCreateDirectories:NO];
	
	NSString *path = @"~/Desktop";
	
	[openPanel beginSheetForDirectory:[path stringByExpandingTildeInPath]
								   file:nil
								  types:nil
						 modalForWindow:[self window]
						  modalDelegate:self
						 didEndSelector:@selector(openPanelDidEnd:returnCode:contextInfo:) 
							contextInfo:NULL];
}

- (void)openPanelDidEnd:(NSOpenPanel *)panel returnCode:(int)returnCode contextInfo:(void  *)contextInfo
{
	if(returnCode != NSOKButton) return;
	
	NSMutableArray *results = [NSMutableArray array];
	
	NSEnumerator *e = [[panel filenames] objectEnumerator];
	NSString *filename;
	
	while(filename = [e nextObject])
	{
		PAFile *file = [PAFile fileWithPath:filename];
	
		if (![[fileController arrangedObjects] containsObject:file])
		{
			[results addObject:file];
		}
	}
	
	[self addFiles:results];
}

- (void)removeButtonClicked:(id)sender
{
	[fileController removeObjectsAtArrangedObjectIndexes:[tableView selectedRowIndexes]];
}

@end