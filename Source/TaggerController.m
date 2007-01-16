#import "TaggerController.h"

@interface TaggerController (PrivateAPI)

/**
adds tag to tagField (use from "outside")
 @param tag tag to add 
 */
- (void)addTagToField:(PASimpleTag*)tag;

/**
called when taggableObjects have changed
 */
- (void)taggableObjectsHaveChanged;

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

		currentCompleteTagsInField = [[PASelectedTags alloc] init];
		dropManager = [PADropManager sharedInstance];
		
		// custom data cell
		fileCell = [[PAFileCell alloc] init];
		
		globalTags = [PATags sharedTags];
	}
	return self;
}

- (void)awakeFromNib
{	
	// autosave name
	[[self window] setFrameAutosaveName:@"punakea.tagger"];
	
	// table view drop support
	[tableView registerForDraggedTypes:[dropManager handledPboardTypes]];
	
	// set custom data + header cell
	NSArray *columns = [tableView tableColumns];
	[[columns objectAtIndex:0] setDataCell:fileCell];
	
	NSString *title = [[[columns objectAtIndex:0] headerCell] stringValue];
	headerCell = [[PATaggerHeaderCell alloc] initTextCell:title];

	[[columns objectAtIndex:0] setHeaderCell:headerCell];
	
	// token field wrapping
	[[tagField cell] setWraps:YES];
	
	[taggableObjectController addObserver:self
							   forKeyPath:@"arrangedObjects"
								  options:nil
								  context:NULL];
	
	// add observer for updating the threaded icons
	[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(iconWasGenerated:)
												 name:@"PAThumbnailManagerDidFinishGeneratingItemNotification"
											   object:nil];
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];

	[headerCell release];
	[tableView unregisterDraggedTypes];
	[fileCell release];
	[currentCompleteTagsInField release];
	[typeAheadFind release];
	[super dealloc];
}

#pragma mark observing
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	if ([keyPath isEqualToString:@"arrangedObjects"])
	{
		[self taggableObjectsHaveChanged];
	}
}


#pragma mark Notifications
-(void)iconWasGenerated:(NSNotification *)notification
{
	PAThumbnailItem *thumbItem = (PAThumbnailItem *)[notification object];
	
	if([thumbItem view] == tableView)
	{
		[tableView displayRect:[thumbItem frame]];
	}
}


#pragma mark accessors
- (void)addTaggableObjects:(NSArray*)objects
{
	[taggableObjectController addObjects:objects];
}

- (NSArray*)taggableObjects
{
	return [taggableObjectController arrangedObjects];
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
	
	[[self taggableObjects] makeObjectsPerformSelector:@selector(addTags:) withObject:tokens];
		
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
		return [globalTags createTagForName:editingString];
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
		[[self taggableObjects] makeObjectsPerformSelector:@selector(removeTags:)
												withObject:deletedTags];

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
- (void)taggableObjectsHaveChanged
{
	// only tags present on every object are shown
	NSMutableSet *tagsOnAllObjects = [NSMutableSet set];
	
	NSEnumerator *taggableObjectEnumerator = [[self taggableObjects] objectEnumerator];
	PATaggableObject *taggableObject;
	
	// set all tags to tags on first object
	if (taggableObject = [taggableObjectEnumerator nextObject])
	{
		[tagsOnAllObjects unionSet:[taggableObject tags]];
	}
	
	// now intersect with all tags on other objects	
	while (taggableObject = [taggableObjectEnumerator nextObject])
	{
		[tagsOnAllObjects intersectSet:[taggableObject tags]];
	}
	
	// update to new value
	[tagField setObjectValue:[tagsOnAllObjects allObjects]];
	
	[currentCompleteTagsInField removeAllTags];
	[currentCompleteTagsInField addObjectsFromArray:[tagsOnAllObjects allObjects]];

	[[self window] makeFirstResponder:tagField];
}

#pragma mark window delegate
- (void)windowWillClose:(NSNotification *)aNotification
{	
	// unbind stuff
	[tagField unbind:@"editable"];
	
	[taggableObjectController removeObserver:self forKeyPath:@"arrangedObjects"];	
	[self autorelease];
}

- (void)windowDidResize:(NSNotification *)aNotification
{
	[self resizeTokenField];
}

#pragma mark tableview drop support
- (NSDragOperation)tableView:(NSTableView*)tv 
				validateDrop:(id <NSDraggingInfo>)info 
				 proposedRow:(int)row 
	   proposedDropOperation:(NSTableViewDropOperation)op
{
	int fileCount = [[self taggableObjects] count];

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
		if (![[taggableObjectController arrangedObjects] containsObject:file])
		{
			[result addObject:file];
		}
	}
	
	[self addTaggableObjects:result];
	
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
	
		if (![[taggableObjectController arrangedObjects] containsObject:file])
		{
			[results addObject:file];
		}
	}
	
	[self addTaggableObjects:results];
}

- (void)removeButtonClicked:(id)sender
{
	[taggableObjectController removeObjectsAtArrangedObjectIndexes:[tableView selectedRowIndexes]];
}

@end