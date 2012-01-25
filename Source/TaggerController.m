// Copyright (c) 2006-2012 nudge:nudge (Johannes Hoffart & Daniel Bär). All rights reserved.
// 
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "TaggerController.h"


@interface TaggerController (PrivateAPI)

- (void)updateQuickLookPreview;

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

- (void)taggableObjectsHaveChanged;							/**< called when items have changed */
- (void)resetTaggerContent;									/**< resets the tagger window (called when window is closed) */
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
	
	// Set insertion pointer color for NSTokenField
	NSTextView *e = (NSTextView *)[[self window] fieldEditor:YES forObject:[tagAutoCompleteController tagField]];
	[e setInsertionPointColor:[NSColor whiteColor]];
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	[taggableObjects release];
	[tableView unregisterDraggedTypes];
	[fileCell release];
	[super dealloc];
}


#pragma mark Actions
- (void)   writeTags:(NSArray*)currentTags 
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
	
	// if the manage files checkbox is checked, make sure that
	// every file is at its correct place, even if no tags have
	// changed
	if (manageFiles)
	{
		for (NNTaggableObject *taggableObject in taggableObjects) 
		{
			[taggableObject handleFileManagement];
		}
	}
}

- (void)addTaggableObject:(NNTaggableObject *)anObject
{
	[taggableObjects addObject:anObject];
	
	[self taggableObjectsHaveChanged];
}

- (void)addTaggableObjects:(NSArray *)theObjects
{
	[taggableObjects addObjectsFromArray:theObjects];

	[self taggableObjectsHaveChanged];
}

- (void)setTaggableObjects:(NSArray *)theObjects
{
	[taggableObjects release];
	taggableObjects = [theObjects mutableCopy];
	
	[self taggableObjectsHaveChanged];
}

- (void)removeTaggableObjects:(id)sender
{
	[taggableObjects removeObjectsAtIndexes:[tableView selectedRowIndexes]];
		               
	[tableView deselectAll:self];
	[[tableView window] makeFirstResponder:[tagAutoCompleteController tagField]];

	[self taggableObjectsHaveChanged];
}

- (void)taggableObjectsHaveChanged
{
	[self updateTokenFieldEditable];
	[self updateManageFilesFlagOnTaggableObjects];
	[self updateTags];
	[tableView reloadData];
	[self updateQuickLookPreview];
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
	
	// Deselect tags
	NSText* fieldEditor = [[tagAutoCompleteController tagField] currentEditor]; 
	if (fieldEditor) 
		[fieldEditor setSelectedRange:NSMakeRange([[fieldEditor string] length], 0)]; 
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

- (void)updateQuickLookPreview
{
	if ([taggableObjects count] == 0)
	{
		[quickLookPreviewImage setImage:nil];
	} else {
		NSInteger row = [tableView selectedRow];
		if (row == -1) { row = 0; }
		
		NNFile *file = [tableView itemAtRow:row];
		
		NSImage *img = [NSImage imageWithPreviewOfFileAtPath:[file path]
													  ofSize:[quickLookPreviewImage frame].size
													  asIcon:YES];
		
		[quickLookPreviewImage setImage:img];
	}
}


#pragma mark Events

- (void)doubleAction:(id)sender
{
	NSIndexSet *selectedRowIndexes = [tableView selectedRowIndexes];	
	NSUInteger row = [selectedRowIndexes firstIndex];
	while(row != NSNotFound) 
	{
		id item = [tableView itemAtRow:row];
		
		if([[item class] isEqualTo:[NNFile class]])
			[[NSWorkspace sharedWorkspace] openFile:[item valueForAttribute:(id)kMDItemPath]];
		
		row = [selectedRowIndexes indexGreaterThanIndex:row];
	}
}


#pragma mark Misc

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

- (void)openPanelDidEnd:(NSOpenPanel *)panel returnCode:(NSInteger)returnCode contextInfo:(void  *)contextInfo
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

/**
 This method is called when the 'Return' key is pressed in the tag field.
 A EditingDidEnd notification is also send, which takes care of writing the tags.
 The only thing that needs to be done here is to close the tagger window.
 */
- (IBAction)confirmTags:(id)sender
{
	[self writeTags:[[self currentCompleteTagsInField] selectedTags]
	withInitialTags:[self initialTags]
  toTaggableObjects:taggableObjects];
	
	// update inital tags to current tags - other changes have been written
	NSArray *currentTags = [[[[self currentCompleteTagsInField] selectedTags] copy] autorelease];
	[self setInitialTags:currentTags];
	
	[self close];
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
	
	// get associated tags
	NSArray *currentTags = [[[[self currentCompleteTagsInField] selectedTags] copy] autorelease];
	NSArray *associatedTags = [[NNTagging tagging] associatedTagsForTags:currentTags];
	NSArray *associatedTagnames = [[NNTagging tagging] tagNamesForTags:associatedTags];
	NSString *suggestion = [associatedTagnames componentsJoinedByString:@", "];
	[suggestionField setStringValue:suggestion];
}

- (void)tableViewSelectionDidChange:(NSNotification *)aNotification
{
	[self updateQuickLookPreview];
}


#pragma mark window delegate
- (void)windowWillClose:(NSNotification *)aNotification
{		
	[self autorelease];
}


#pragma mark TableView Data Source
- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView
{
	return [taggableObjects count];
}

-      	      (id)tableView:(NSTableView *)aTableView 
  objectValueForTableColumn:(NSTableColumn *)aTableColumn
						row:(NSInteger)rowIndex
{
	return [taggableObjects objectAtIndex:rowIndex];
}


#pragma mark ResultsOutlineView Set Object Value
- (void)tableView:(NSTableView *)aTableView
   setObjectValue:(id)anObject
   forTableColumn:(NSTableColumn *)aTableColumn 
			  row:(NSInteger)rowIndex
{
	NNTaggableObject *taggableObject = [taggableObjects objectAtIndex:rowIndex];
	NSString *value = anObject;
	
	[taggableObject renameTo:value errorWindow:[aTableView window]];
	
	[tableView reloadData];
}


#pragma mark TableView Delegate
- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row
{
	return 19.0;
}

#pragma mark tableview drop support
- (NSDragOperation)tableView:(NSTableView*)tv 
				validateDrop:(id <NSDraggingInfo>)info 
				 proposedRow:(NSInteger)row 
	   proposedDropOperation:(NSTableViewDropOperation)op
{
	// If we're just editing tags on files, don't allow drop
	if([self isEditingTagsOnFiles])
		return NSDragOperationNone;
	
	// check if sender should be ignored
	if(![dropManager acceptsSender:[info draggingSource]])
		return NSDragOperationNone;
	
	NSInteger fileCount = [taggableObjects count];

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
			  row:(NSInteger)row 
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