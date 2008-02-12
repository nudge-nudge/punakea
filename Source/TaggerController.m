#import "TaggerController.h"


@interface TaggerController (PrivateAPI)

- (void)setupStatusBar;

- (void)updateTags;
- (void)updateManageFilesFlagOnTaggableObjects;
- (void)updateTokenFieldEditable;

- (float)discreteTokenFieldHeight:(float)theHeight;

/**
adds tag to tagField (use from "outside")
 @param tag tag to add 
 */
- (void)addTagToField:(NNSimpleTag*)tag;

- (void)itemsHaveChanged;							/**< called when items have changed */
- (void)resetTaggerContent;							/**< resets the tagger window (called when window is closed) */
- (void)displayRestTags:(NSArray*)restTags;

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
		
		manageFilesAutomatically = YES;
		showsManageFiles = YES;
	}
	return self;
}

- (void)awakeFromNib
{	
	// this keeps the windowcontroller from auto-placing the window
	// - window is always opened where it was closed
	[self setShouldCascadeWindows:NO];
	
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
	
	// Fix column width
	[[columns objectAtIndex:0] setWidth:[tableView frame].size.width];
	
	// token field wrapping
	[[[self tagField] cell] setWraps:YES];
		
	[self updateTokenFieldEditable];
		
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	// add observer for updating the threaded icons
	[nc addObserver:self 
		   selector:@selector(iconWasGenerated:)
			   name:@"PAThumbnailManagerDidFinishGeneratingItemNotification"
			 object:nil];
	
	// Check manage files
	if(manageFilesAutomatically)
		manageFiles = [[NSUserDefaults standardUserDefaults] boolForKey:@"ManageFiles.ManagedFolder.Enabled"];	
		
	if(manageFiles)
		[manageFilesButton setState:NSOnState];
	else
		[manageFilesButton setState:NSOffState];
	
	if(showsManageFiles)
	{
		[manageFilesButton setHidden:NO];
	} else {
		[manageFilesButton setHidden:YES];
	}
	
	// Drop manager should reflect the current manage files state
	BOOL generalManageFilesFlag = [[NSUserDefaults standardUserDefaults] boolForKey:@"ManageFiles.ManagedFolder.Enabled"];
	
	if(generalManageFilesFlag != manageFiles)
		[dropManager setAlternateState:YES];
	else
		[dropManager setAlternateState:NO];
	
	// Setup status bar
	[self setupStatusBar];
	
	[self resizeTokenField];
}

- (void)setupStatusBar
{
	if(![self isEditingTagsOnFiles])
	{
		PAStatusBarButton *sbitem = [PAStatusBarButton statusBarButton];
		[sbitem setToolTip:@"Add files to tag"];
		[sbitem setImage:[NSImage imageNamed:@"statusbar-button-plus"]];
		[sbitem setAction:@selector(addFiles:)];
		[statusBar addItem:sbitem];
		
		sbitem = [PAStatusBarButton statusBarButton];
		[sbitem setToolTip:@"Remove files from Tagger"];
		[sbitem setImage:[NSImage imageNamed:@"statusbar-button-minus"]];
		[sbitem setAction:@selector(removeFiles:)];	
		[statusBar addItem:sbitem];
	}
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
	
	[self updateTokenFieldEditable];
	[self updateManageFilesFlagOnTaggableObjects];
	[self updateTags];
	[tableView reloadData];
}

- (void)addTaggableObjects:(NSArray *)theObjects
{
	[items addObjectsFromArray:theObjects];

	[self updateTokenFieldEditable];
	[self updateManageFilesFlagOnTaggableObjects];
	[self updateTags];
	[tableView reloadData];
}

- (void)setTaggableObjects:(NSArray *)theObjects
{
	[items release];
	items = [theObjects mutableCopy];
	
	[self updateTokenFieldEditable];
	[self updateManageFilesFlagOnTaggableObjects];
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
	
	// Update manage files flag if at least one tag was added
	if([[tagsOnAllObjects allObjects] count] > 0)
		[self updateManageFilesFlagOnTaggableObjects];
	
	// update to new value
	[[self tagField] setObjectValue:[tagsOnAllObjects allObjects]];
	
	[[self currentCompleteTagsInField] removeAllTags];
	[[self currentCompleteTagsInField] addObjectsFromArray:[tagsOnAllObjects allObjects]];
	
	[[self window] makeFirstResponder:tagField];
	
	[self resizeTokenField];
}

- (void)updateManageFilesFlagOnTaggableObjects
{
	// Break if files manage themselves
	if(manageFilesAutomatically)
		return;

	manageFiles = NO;
	
	if([manageFilesButton state] == NSOnState)
		manageFiles = YES;		
	
	NSEnumerator *e = [items objectEnumerator];
	NNTaggableObject *object;
	
	while(object = [e nextObject])
	{
		[object setShouldManageFiles:manageFiles];
	}
	
	// Disable manage files button if there are any files present
	if([items count] > 0 && manageFiles && [[self currentCompleteTagsInField] count] > 0 )
		[manageFilesButton setEnabled:NO];
		
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

- (void)addFiles:(id)sender
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

- (void)removeFiles:(id)sender
{
	[items removeObjectsAtIndexes:[tableView selectedRowIndexes]];
	
	[self updateTokenFieldEditable];
	
	[tableView deselectAll:tableView];
		
	[self updateManageFilesFlagOnTaggableObjects];
	[self updateTags];
	[tableView reloadData];
}

- (IBAction)changeManageFilesFlag:(id)sender
{
	manageFilesAutomatically = NO;
	
	[self updateManageFilesFlagOnTaggableObjects];
	
	// Update Drop Manager to reflect current manage files state
	BOOL generalManageFilesFlag = [[NSUserDefaults standardUserDefaults] boolForKey:@"ManageFiles.ManagedFolder.Enabled"];	

	if(generalManageFilesFlag != manageFiles)
		[dropManager setAlternateState:YES];
	else
		[dropManager setAlternateState:NO];
	
	// Make all objects perform an update so that they are moved
	[self updateTags];
}

- (void)updateTokenFieldEditable
{
	if ([items count] > 0)
	{
		[tagField setEditable:YES];
		[[self window] makeFirstResponder:tagField];
	}
	else
	{
		[tagField setEditable:NO];
	}
}

- (void)validateConfirmButton
{
	if(!confirmButton)
		return;
	
	[confirmButton setEnabled:([currentCompleteTagsInField count] > 0)];
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
	// forward call to super - this adds the tags to currentCompleteTagsInField
	NSArray *returnedTokens = [super tokenField:tokenField shouldAddObjects:tokens atIndex:idx];
	
	// Update manage files flag if first tag was entered
	[self updateManageFilesFlagOnTaggableObjects];
	
	// Add tags to items
	[items makeObjectsPerformSelector:@selector(addTags:) withObject:tokens];
		
	// resize field if neccessary
	[self performSelector:@selector(resizeTokenField) 
			   withObject:nil 
			   afterDelay:0.05];
	
	// Forward to super
	return returnedTokens;
}


- (void)controlTextDidChange:(NSNotification *)aNotification
{
	// adding tags is handled by tokenField:shouldAddObjects:atIndex,
	// this method handles the deletion of tags
	
	// [fieldEditor string] contains \uFFFC (OBJECT REPLACEMENT CHARACTER) for every token
	NSDictionary *userInfo = [aNotification userInfo];
	NSText *fieldEditor = [userInfo objectForKey:@"NSFieldEditor"];
	NSString *editorString = [fieldEditor string];
	
	// get a count of the tags by replacing the \ufffc occurrences
	NSString *objectReplacementCharacter = [NSString stringWithUTF8String:"\ufffc"];
	NSMutableString *mutableEditorString = [editorString mutableCopy];
	unsigned int numberOfTokens = [mutableEditorString replaceOccurrencesOfString:objectReplacementCharacter
																	   withString:@""
																		  options:0
																			range:NSMakeRange(0, [mutableEditorString length])];
		
	if (numberOfTokens < [currentCompleteTagsInField count])
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
	cellSize.height = [self discreteTokenFieldHeight:cellSize.height];
	
	float sizeDifference = cellSize.height - oldTokenFieldFrame.size.height;
	
	// Resize tag field
	[[self tagField] setFrame:NSMakeRect(oldTokenFieldFrame.origin.x,
										 oldTokenFieldFrame.origin.y - sizeDifference,
										 oldTokenFieldFrame.size.width,
										 cellSize.height)];
	
	// Resize table view
	NSRect oldTableViewFrame = [[tableView enclosingScrollView] frame];
	
	NSRect tvFrame = NSMakeRect(oldTableViewFrame.origin.x,
								oldTableViewFrame.origin.y,
								oldTableViewFrame.size.width,
								[[self tagField] frame].origin.y - oldTableViewFrame.origin.y - 42.0);
	
	if(!showsManageFiles)
		tvFrame.size.height += [manageFilesButton frame].size.height;
	
	[[tableView enclosingScrollView] setFrame:tvFrame];
	
	// Move manage files button	
	NSRect manageFilesFrame = [manageFilesButton frame];
	manageFilesFrame.origin.y = tvFrame.origin.y + tvFrame.size.height + 13.0;
	
	[manageFilesButton setFrame:manageFilesFrame];
	
	// Set needs display
	[[[self window] contentView] setNeedsDisplay:YES];
}

- (float)discreteTokenFieldHeight:(float)height
{
	height -= 23.0;
	
	// Minimum height is 23px
	if (height <= 0.0)
		return 23.0;
	
	// Determine how many lines are necessary
	int steps = 1;
	
	while(height > 17.0)
	{
		height -= 17.0;
		steps++;
	}
	
	return 23.0 + steps * 17.0;
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
	// If we're just editing tags on files, don't allow drop
	if([self isEditingTagsOnFiles])
		return NSDragOperationNone;
	
	// check if sender should be ignored
	if(![dropManager acceptsSender:[info draggingSource]])
		return NSDragOperationNone;
	
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
	
	[[self window] makeKeyAndOrderFront:self];
	
	return YES;
}


#pragma mark Accessors
- (void)setManageFiles:(BOOL)flag
{
	manageFilesAutomatically = NO;
	manageFiles = flag;
}

- (void)setShowsManageFiles:(BOOL)flag
{
	showsManageFiles = flag;
	
	if(flag)
		[manageFilesButton setHidden:NO];
	else
		[manageFilesButton setHidden:YES];
}

- (BOOL)isEditingTagsOnFiles
{
	return [manageFilesButton isHidden];
}

@end