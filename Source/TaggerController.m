#import "TaggerController.h"


@interface TaggerController (PrivateAPI)

- (void)updateTags;

/**
adds tag to tagField (use from "outside")
 @param tag tag to add 
 */
- (void)addTagToField:(NNSimpleTag*)tag;

- (void)itemsHaveChanged;							/**< called when items have changed */
- (void)resetTaggerContent;							/**< resets the tagger window (called when window is closed) */
- (void)displayRestTags:(NSArray*)restTags;
- (void)resizeTokenField;

@end



@implementation TaggerController

#pragma mark init + dealloc
// TODO: Why are we using this non-designated initializer for a NSWindowController subclass?!
- (id)init
{
	if (self = [super initWithWindowNibName:@"Tagger"])
	{
		items = [[NSMutableArray alloc] init];
		
		dropManager = [PADropManager sharedInstance];
		
		// custom data cell
		fileCell = [[PATaggerItemCell alloc] initTextCell:@""];
		[fileCell setEditable:YES];
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
	[[[self tagField] cell] setWraps:YES];
	
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	// add observer for updating the threaded icons
	[nc addObserver:self 
		   selector:@selector(iconWasGenerated:)
			   name:@"PAThumbnailManagerDidFinishGeneratingItemNotification"
			 object:nil];
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	[items release];
	[headerCell release];
	[tableView unregisterDraggedTypes];
	[fileCell release];
	[super dealloc];
}


#pragma mark Actions
- (void)addTaggableObject:(NNTaggableObject *)anObject
{
	[items addObject:anObject];
	[self updateTags];
	[tableView reloadData];
}

- (void)addTaggableObjects:(NSArray *)theObjects
{
	[items addObjectsFromArray:theObjects];
	[self updateTags];
	[tableView reloadData];
}

- (void)updateTags
{
	// only tags present on every object are shown
	NSMutableSet *tagsOnAllObjects = [NSMutableSet set];
	
	NSEnumerator *itemsEnumerator = [items objectEnumerator];
	NNTaggableObject *taggableObject;
	
	// set all tags to tags on first object
	if (taggableObject = [itemsEnumerator nextObject])
	{
		[tagsOnAllObjects unionSet:[taggableObject tags]];
	}
	
	// now intersect with all tags on other objects	
	while (taggableObject = [itemsEnumerator nextObject])
	{
		[tagsOnAllObjects intersectSet:[taggableObject tags]];
	}
	
	// update to new value
	[[self tagField] setObjectValue:[tagsOnAllObjects allObjects]];
	
	[[self currentCompleteTagsInField] removeAllTags];
	[[self currentCompleteTagsInField] addObjectsFromArray:[tagsOnAllObjects allObjects]];
	
	[[self window] makeFirstResponder:tagField];
}

- (void)doubleAction:(id)sender
{
	NSIndexSet *selectedRowIndexes = [tableView selectedRowIndexes];	
	unsigned row = [selectedRowIndexes firstIndex];
	while(row != NSNotFound) 
	{
		id item = [tableView itemAtRow:row];
		
		if([[item class] isEqualTo:[NNFile class]])
			[[NSWorkspace sharedWorkspace] openFile:[item valueForAttribute:(id)kMDItemPath]];
		
		row = [selectedRowIndexes indexGreaterThanIndex:row];
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


#pragma mark tokenField delegate
- (NSArray *)tokenField:(NSTokenField *)tokenField 
	   shouldAddObjects:(NSArray *)tokens 
				atIndex:(unsigned)idx
{	
	// Add tags to items
	[items makeObjectsPerformSelector:@selector(addTags:) withObject:tokens];
		
	// resize field if neccessary
	[self performSelector:@selector(resizeTokenField) 
			   withObject:nil 
			   afterDelay:0.05];
	
	// Forward to super
	return [super tokenField:tokenField shouldAddObjects:tokens atIndex:idx];
}


- (void)controlTextDidChange:(NSNotification *)aNotification
{
	// only do something if a tag has been completely deleted
	// adding tags is handled by ... shouldAddObjects: ...
	if ([[tagField objectValue] count] < [currentCompleteTagsInField count])
	{
		// look for deleted tags
		NSMutableArray *deletedTags = [NSMutableArray array];
		
		NSEnumerator *e = [[self currentCompleteTagsInField] objectEnumerator];
		NNSimpleTag *tag;
		
		while (tag = [e nextObject])
		{
			if (![[[self tagField] objectValue] containsObject:tag])
			{
				[deletedTags addObject:tag];
			}
		}
		
		// now remove the tags to be deleted from currentCompleteTagsInField - to keep in sync with tagField
		[[self currentCompleteTagsInField] removeObjectsInArray:deletedTags];

		// remove the deleted tags from all files
		[items makeObjectsPerformSelector:@selector(removeTags:)
												withObject:deletedTags];

		// resize tokenfield if neccessary
		[self resizeTokenField];
	}
}

- (void)resizeTokenField
{
	NSRect oldTokenFieldFrame = [[self tagField] frame];
	NSSize cellSize = [[[self tagField] cell] cellSizeForBounds:[[self tagField] bounds]];
	cellSize.height = (cellSize.height > 22) ? cellSize.height : 22;
	float sizeDifference = cellSize.height - oldTokenFieldFrame.size.height;
	
	[[self tagField] setFrame:NSMakeRect(oldTokenFieldFrame.origin.x,
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


#pragma mark window delegate
- (void)windowWillClose:(NSNotification *)aNotification
{		
	// unbind stuff
	[[self tagField] unbind:@"editable"];
	
	[self autorelease];
}

- (void)windowDidResize:(NSNotification *)aNotification
{
	[self resizeTokenField];
}


#pragma mark TableView Data Source
- (int)numberOfRowsInTableView:(NSTableView *)aTableView
{
	return [items count];
}

-      	      (id)tableView:(NSTableView *)aTableView 
  objectValueForTableColumn:(NSTableColumn *)aTableColumn
						row:(int)rowIndex
{
	return [items objectAtIndex:rowIndex];
}


#pragma mark ResultsOutlineView Set Object Value
- (void)tableView:(NSTableView *)aTableView
   setObjectValue:(id)anObject
   forTableColumn:(NSTableColumn *)aTableColumn 
			  row:(int)rowIndex
{
	NNTaggableObject *taggableObject = [items objectAtIndex:rowIndex];
	NSString *value = anObject;
	
	[taggableObject renameTo:value errorWindow:[aTableView window]];
	
	[tableView reloadData];
}


#pragma mark TableView Delegate
- (float)tableView:(NSTableView *)tableView heightOfRow:(int)row
{
	return 19.0;
}

#pragma mark tableview drop support
- (NSDragOperation)tableView:(NSTableView*)tv 
				validateDrop:(id <NSDraggingInfo>)info 
				 proposedRow:(int)row 
	   proposedDropOperation:(NSTableViewDropOperation)op
{
	int fileCount = [items count];

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
	
	NSMutableArray *results = [NSMutableArray array];
	
	NSEnumerator *e = [files objectEnumerator];
	NNFile *file;
	
	while (file = [e nextObject])
	{
		if (![items containsObject:file])
		{
			[results addObject:file];
		}
	}
	
	[self addTaggableObjects:results];
	
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
		NNFile *file = [NNFile fileWithPath:filename];
	
		if (![items containsObject:file])
		{
			[results addObject:file];
		}
	}
	
	[self addTaggableObjects:results];
}

- (void)removeButtonClicked:(id)sender
{
	[items removeObjectsAtIndexes:[tableView selectedRowIndexes]];
	[self updateTags];
	[tableView reloadData];
}

@end