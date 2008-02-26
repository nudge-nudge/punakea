#import "TaggerController.h"


@interface TaggerController (PrivateAPI)

- (void)setupStatusBar;

- (void)writeTags:(NSArray*)currentTags 
  withInitialTags:(NSArray*)someInitialTags
toTaggableObjects:(NSArray*)someTaggableObjects;

- (NSArray *)initialTags;
- (void)setInitialTags:(NSArray *)someTags;

- (NNSelectedTags*)currentCompleteTagsInField;

- (void)updateTags;
- (void)updateManageFilesFlagOnTaggableObjects;
- (void)updateTokenFieldEditable;

- (NSTokenField*)tagField;
- (float)discreteTokenFieldHeight:(float)theHeight;

- (void)itemsHaveChanged;							/**< called when items have changed */
- (void)resetTaggerContent;							/**< resets the tagger window (called when window is closed) */
- (void)displayRestTags:(NSArray*)restTags;

@end



@implementation TaggerController

#pragma mark init + dealloc
- (id)init
{
	if (self = [super initWithWindowNibName:@"Tagger"])
	{
		taggableObjects = [[NSMutableArray alloc] init];
		
		[self setInitialTags:[NSArray array]];
		
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
	
	// add observer for TagAutoCompleteController
	[nc addObserver:self 
		   selector:@selector(tagsHaveChanged:)
			   name:NNSelectedTagsHaveChangedNotification
			 object:[tagAutoCompleteController currentCompleteTagsInField]];
	
	[nc addObserver:self
		   selector:@selector(editingDidEnd:)
			   name:NSControlTextDidEndEditingNotification
			 object:[self tagField]];
	
	// call editingDidEnd on app termination to make sure tags are written
	[nc addObserver:self
		   selector:@selector(editingDidEnd:)
			   name:NSApplicationWillTerminateNotification
			 object:[NSApplication sharedApplication]];
	
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
	// make sure the tags are written
	[self writeTags:[[self currentCompleteTagsInField] selectedTags]
	withInitialTags:[self initialTags]
  toTaggableObjects:taggableObjects];
	
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	[taggableObjects release];
	[headerCell release];
	[tableView unregisterDraggedTypes];
	[fileCell release];
	[super dealloc];
}


#pragma mark Actions
- (void)writeTags:(NSArray*)currentTags 
  withInitialTags:(NSArray*)someInitialTags
toTaggableObjects:(NSArray*)someTaggableObjects
{
	// Tag sets
	NSSet *initialTagSet = [NSSet setWithArray:someInitialTags];
	NSSet *tagSet = [NSSet setWithArray:[[tagAutoCompleteController currentCompleteTagsInField] selectedTags]];
	
	// Get diff set (tags that have been added or removed)
	NSMutableSet *unchangedSet = [NSMutableSet setWithSet:tagSet];
	[unchangedSet intersectSet:initialTagSet];
	
	NSMutableSet *diffSetToAdd = [NSMutableSet setWithSet:tagSet];
	[diffSetToAdd minusSet:unchangedSet];
	
	NSMutableSet *diffSetToRemove = [NSMutableSet setWithSet:initialTagSet];
	[diffSetToRemove minusSet:unchangedSet];
	
	// Write tags to files
	if ([diffSetToRemove count] > 0)
	{
		for (NNTaggableObject* taggableObject in taggableObjects)
			[taggableObject removeTags:[diffSetToRemove allObjects]];
	}
	
	if([diffSetToAdd count] > 0)
	{
		for(NNTaggableObject *taggableObject in taggableObjects)
			[taggableObject addTags:[diffSetToAdd allObjects]];
	}
	
}

- (void)addTaggableObject:(NNTaggableObject *)anObject
{
	[taggableObjects addObject:anObject];
	
	[self updateTokenFieldEditable];
	[self updateManageFilesFlagOnTaggableObjects];
	[self updateTags];
	[tableView reloadData];
}

- (void)addTaggableObjects:(NSArray *)theObjects
{
	[taggableObjects addObjectsFromArray:theObjects];

	[self updateTokenFieldEditable];
	[self updateManageFilesFlagOnTaggableObjects];
	[self updateTags];
	[tableView reloadData];
}

- (void)setTaggableObjects:(NSArray *)theObjects
{
	[taggableObjects release];
	taggableObjects = [theObjects mutableCopy];
	
	[self updateTokenFieldEditable];
	[self updateManageFilesFlagOnTaggableObjects];
	[self updateTags];
	[tableView reloadData];
}

- (void)updateTags
{
	// only tags present on every object are shown
	NSMutableSet *tagsOnAllObjects = [NSMutableSet set];
	
	NSEnumerator *itemsEnumerator = [taggableObjects objectEnumerator];
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
	
	[self setInitialTags:[tagsOnAllObjects allObjects]];
		
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
	
	NSEnumerator *e = [taggableObjects objectEnumerator];
	NNTaggableObject *object;
	
	while(object = [e nextObject])
	{
		[object setShouldManageFiles:manageFiles];
	}
	
	// Disable manage files button if there are any files present
	if([taggableObjects count] > 0 && manageFiles && [[self currentCompleteTagsInField] count] > 0 )
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
		
		if (![taggableObjects containsObject:file])
		{
			[results addObject:file];
		}
	}
	
	[self addTaggableObjects:results];
}

- (void)removeFiles:(id)sender
{
	[taggableObjects removeObjectsAtIndexes:[tableView selectedRowIndexes]];
	
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
	
	// Update manage files flag on taggable objects
	[self updateManageFilesFlagOnTaggableObjects];
}

- (void)updateTokenFieldEditable
{
	if ([taggableObjects count] > 0)
	{
		[[self tagField] setEditable:YES];
		[[self window] makeFirstResponder:[self tagField]];
	}
	else
	{
		[[self tagField] setEditable:NO];
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

- (void)tagsHaveChanged:(NSNotification *)notification
{
	// Update manage files flag if first tag was entered
	[self updateManageFilesFlagOnTaggableObjects];
		
	// resize field if neccessary
	[self performSelector:@selector(resizeTokenField) 
			   withObject:nil 
			   afterDelay:0.05];
}

- (void)editingDidEnd:(NSNotification *)aNotification
{
	// DO THE ACTUAL WRITING OF TAGS TO FILES AFTER LOSING FOCUS
	// this will help decrease the load on spotlight (which is currently very unstable)
	[self writeTags:[[self currentCompleteTagsInField] selectedTags]
	withInitialTags:[self initialTags]
  toTaggableObjects:taggableObjects];
	
	// update inital tags to current tags - other changes have been written
	NSArray *currentTags = [[[[self currentCompleteTagsInField] selectedTags] copy] autorelease];
	[self setInitialTags:currentTags];
}

- (void)windowDidResignKey:(NSNotification *)notification
{
	[self editingDidEnd:notification];
}

- (void)windowDidMiniaturize:(NSNotification *)notification
{
	[self editingDidEnd:notification];
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
	return [taggableObjects count];
}

-      	      (id)tableView:(NSTableView *)aTableView 
  objectValueForTableColumn:(NSTableColumn *)aTableColumn
						row:(int)rowIndex
{
	return [taggableObjects objectAtIndex:rowIndex];
}


#pragma mark ResultsOutlineView Set Object Value
- (void)tableView:(NSTableView *)aTableView
   setObjectValue:(id)anObject
   forTableColumn:(NSTableColumn *)aTableColumn 
			  row:(int)rowIndex
{
	NNTaggableObject *taggableObject = [taggableObjects objectAtIndex:rowIndex];
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
	
	int fileCount = [taggableObjects count];

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
		if (![taggableObjects containsObject:file])
		{
			[results addObject:file];
		}
	}
	
	[self addTaggableObjects:results];
	
	[[self window] makeKeyAndOrderFront:self];
	
	return YES;
}


#pragma mark Accessors
- (NSTokenField*)tagField
{
	return [tagAutoCompleteController tagField];
}

- (NNSelectedTags*)currentCompleteTagsInField
{
	return [tagAutoCompleteController currentCompleteTagsInField];
}

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
				 
- (NSArray *)initialTags
{
	return initialTags;
}

- (void)setInitialTags:(NSArray *)someTags
{
	[initialTags release];
	initialTags = [someTags retain];
}

@end