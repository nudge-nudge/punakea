//
//  PAResultsViewController.m
//  punakea
//
//  Created by Johannes Hoffart on 26.09.06.
//  Copyright 2006 nudge:nudge. All rights reserved.
//

#import "PAResultsViewController.h"

@interface PAResultsViewController (PrivateAPI)

- (void)setDisplayMessage:(NSString*)message;
- (NSArray*)createContentTypeQueryFilters;

@end

@implementation PAResultsViewController

#pragma mark init
- (id)init
{
	if (self = [super init])
	{
		tags = [NNTags sharedTags];
		
		selectedTags = [[NNSelectedTags alloc] init];
		
		query = [[NNQuery alloc] init];
		[query setBundlingAttributes:[NSArray arrayWithObjects:@"kMDItemContentTypeTree", nil]];
		//[query setSortDescriptors:[NSArray arrayWithObject:[[[NSSortDescriptor alloc] initWithKey:(id)kMDItemFSName ascending:YES] autorelease]]];
		
		dropManager = [PADropManager sharedInstance];
		
		relatedTags = [[NNRelatedTags alloc] initWithQuery:query];
		
		draggedItems = nil;
		
		NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
		
		[nc addObserver:self 
			   selector:@selector(selectedTagsHaveChanged:) 
				   name:@"NNSelectedTagsHaveChanged" 
				 object:selectedTags];
		
		[nc addObserver:self 
			   selector:@selector(relatedTagsHaveChanged:) 
				   name:@"NNRelatedTagsHaveChanged" 
				 object:relatedTags];
				 
		[nc addObserver:self 
			   selector:@selector(thumbnailWasGenerated:)
				   name:@"PAThumbnailManagerDidFinishGeneratingItemNotification"
				 object:nil];
		
		[nc addObserver:self
			   selector:@selector(queryNote:)
				   name:nil
				 object:query];
		
		[nc addObserver:self
			 selector:@selector(contentTypeFilterUpdate:)
				 name:PAContentTypeFilterUpdate
			   object:nil];

		[self setDisplayMessage:@""];
		
		[NSBundle loadNibNamed:@"ResultsView" owner:self];
	}
	return self;
}

- (void)awakeFromNib
{
	// if we are managing files, copy on drag
	// else move
	BOOL managingFiles = [[NSUserDefaults standardUserDefaults] boolForKey:@"ManageFiles.ManagedFolder.Enabled"];
	NSDragOperation dragOperation = managingFiles ? NSDragOperationCopy : NSDragOperationMove;
	
	[outlineView setQuery:query];
	[outlineView registerForDraggedTypes:[dropManager handledPboardTypes]];
	[outlineView setDraggingSourceOperationMask:NSDragOperationNone forLocal:YES];
	[outlineView setDraggingSourceOperationMask:(dragOperation | NSDragOperationCopy | NSDragOperationDelete) forLocal:NO];
	
	// Add view to popup menu
	FVColorMenuView *menuView = [FVColorMenuView menuView];
	[menuView setTarget:self];
	[menuView setAction:@selector(changeFinderLabel:)];
	[colorLabelMenuItem setView:menuView];
}

- (void)dealloc
{	
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	[outlineView unregisterDraggedTypes];
	[draggedItems release];

	[relatedTags release];
    [query release];
	[selectedTags release];
	[super dealloc];
}


#pragma mark accessors
- (NNQuery*)query
{
	return query;
}

- (NNRelatedTags*)relatedTags;
{
	return relatedTags;
}

- (void)setRelatedTags:(NNRelatedTags*)otherRelatedTags
{
	[otherRelatedTags retain];
	[relatedTags release];
	relatedTags = otherRelatedTags;
}

- (NNSelectedTags*)selectedTags;
{
	return selectedTags;
}

- (void)setSelectedTags:(NNSelectedTags*)otherSelectedTags
{
	[otherSelectedTags retain];
	[selectedTags release];
	selectedTags = otherSelectedTags;
}

- (IBAction)emptySelectedTags:(id)senders
{
	[selectedTags removeAllTags];
}

- (NSString*)displayMessage
{
	return displayMessage;
}

- (void)setDisplayMessage:(NSString*)message
{
	[displayMessage release];
	[message retain];
	displayMessage = message;
}

- (NSArray*)draggedItems
{
	return draggedItems;
}

- (void)setDraggedItems:(NSArray*)someItems
{
	[someItems retain];
	[draggedItems release];
	draggedItems = someItems;
}

- (BOOL)isWorking
{
	return [query isGathering];
}

- (NSResponder*)dedicatedFirstResponder
{
	return outlineView;
}

#pragma mark actions
- (void)handleTagActivation:(NNTag*)tag
{
	NSEvent *currentEvent = [NSApp currentEvent];
	BOOL alternateKeyDown = ([currentEvent modifierFlags] & NSAlternateKeyMask) != 0;
		
	[selectedTags addTag:tag negated:alternateKeyDown];
	
	[tag incrementClickCount];
}

- (void)handleTagNegation:(NNTag*)tag
{
	[selectedTags addTag:tag negated:YES];
	
	[tag incrementClickCount];
}

// this behaves differently than handleTagActivation:
// sets selected tags to new tags instead of adding
// also removes filters
- (void)handleTagActivations:(NSMutableArray*)someTags
{
	[query removeAllFilters];
	[someTags makeObjectsPerformSelector:@selector(incrementClickCount)];
	[selectedTags setSelectedTags:someTags];
}

- (void)reset
{
	[selectedTags removeAllTags];
	[query removeAllFilters];
}

- (void)removeLastTag
{
	if ([selectedTags count] > 0)
		[selectedTags removeLastTag];
}

- (IBAction)doubleAction:(id)sender
{
	NSIndexSet *selectedRowIndexes = [outlineView selectedRowIndexes];	
	NSUInteger row = [selectedRowIndexes firstIndex];
	while(row != NSNotFound) 
	{
		id item = [outlineView itemAtRow:row];
		
		if([[item class] isEqualTo:[NNFile class]])
			[[NSWorkspace sharedWorkspace] openFile:[item valueForAttribute:(id)kMDItemPath]];
		
		row = [selectedRowIndexes indexGreaterThanIndex:row];
	}
}

- (void)hideAllSubviews
{
	NSEnumerator *enumerator = [[outlineView subviews] objectEnumerator];
	id anObject;
	while(anObject = [enumerator nextObject])
	{
		[anObject setHidden:YES];
	}
}

- (void)triangleClicked:(id)sender
{
	NSDictionary *tag = (NSDictionary *)[sender tag];
	NNQueryBundle *item = [tag objectForKey:@"bundle"];
	
	if([outlineView isItemExpanded:item])
	{
		// Just toggle the item's state
		[outlineView collapseItem:item];
	} else {
		// If we expand an item, we need to redraw all previously visible rows so that they
		// can correctly (re-)move their subviews
		
		NSRange previousVisibleRowsRange = [outlineView rowsInRect:[outlineView visibleRect]];
		
		[outlineView expandItem:item];
		
		NSInteger numberOfChildrenOfItem = [[outlineView delegate] outlineView:outlineView numberOfChildrenOfItem:item];
		for(NSUInteger i = 0; i < previousVisibleRowsRange.length; i++)
		{
			[outlineView drawRow:(numberOfChildrenOfItem + previousVisibleRowsRange.location + i) clipRect:[outlineView bounds]];
		}
	}
	
	// Save userDefaults
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSMutableDictionary *results = [NSMutableDictionary dictionaryWithDictionary:[defaults objectForKey:@"Results"]];
	NSMutableArray *collapsedGroups = [NSMutableArray arrayWithArray:[results objectForKey:@"CollapsedGroups"]];
	
	if([outlineView isItemExpanded:item])
		[collapsedGroups removeObject:[item value]];
	else
		[collapsedGroups addObject:[item value]];
	
	[results setObject:collapsedGroups forKey:@"CollapsedGroups"];		
	[defaults setObject:results forKey:@"Results"];
}


#pragma mark Popup Menu
- (BOOL)validateMenuItem:(NSMenuItem *)menuItem
{
	// Set default selection to the currently selected item's color label
	// (to the first one, if multiple, like the Finder does)
	NNFile *file = [[outlineView selectedItems] objectAtIndex:0];
	[(FVColorMenuView *)[colorLabelMenuItem view] selectLabel:[FVFinderLabel finderLabelForURL:[file url]]];
	
	if ([menuItem action] == @selector(revealInFinder:))
	{
		// "Reveal in Finder" only works for single selection
		if ([[outlineView selectedItems] count] > 1)
			return NO;
	}
	
	return YES;
}

- (IBAction)changeFinderLabel:(id)sender
{
	for (NNFile *file in [outlineView selectedItems])
	{	
		[FVFinderLabel setFinderLabel:[sender tag] forURL:[file url]];
	}
	
	[[colorLabelMenuItem menu] cancelTracking];
}


#pragma mark Notifications
- (void)selectedTagsHaveChanged:(NSNotification*)notification
{
	// reset displayMessage
	[self setDisplayMessage:@""];
	
	// stop an active query
	if ([query isStarted])
	{
		[query stopQuery];
	}
	
	// the query is only started if there are any tags to look for
	if ([selectedTags count] > 0)
	{
		// update query to conform to active content type filters
		NSArray *queryFilters = [self createContentTypeQueryFilters];
		[query addFilters:queryFilters];
		
		// set tags to search for
		[query setTags:selectedTags];
		[query startQuery];
				
		// empty display tags until new related tags are found
		if ([delegate respondsToSelector:@selector(clearVisibleTags)])
		{
			[delegate clearVisibleTags];
		}
		else
		{
			[NSException raise:NSInternalInconsistencyException
						format:@"delegate does not implement clearVisibleTags"];
		}
	}
	else 
	{
		// empty all filters on query
		[query removeAllFilters];
		
		// set tags to search for
		[query setTags:selectedTags];
		[query startQuery];
			
		// there are no selected tags, reset all tags
		if ([delegate respondsToSelector:@selector(resetDisplayTags)])
		{
			[delegate resetDisplayTags];
		}
		else
		{
			[NSException raise:NSInternalInconsistencyException
						format:@"delegate does not implement resetDisplayTags"];
		}
	}
}

- (void)relatedTagsHaveChanged:(NSNotification *)notification
{	
	if (![relatedTags isUpdating] && ([relatedTags count] == 0))
	{
		// only applies if there has been a search (selected tags)
		if ([selectedTags count] == 0)
		{
			return;
		}
		
		[self setDisplayMessage:NSLocalizedStringFromTable(@"NO_RELATED_TAGS",@"Tags",@"")];
		
		// empty display tags until new related tags are found
		if ([delegate respondsToSelector:@selector(clearVisibleTags)])
		{
			[delegate clearVisibleTags];
		}
		else
		{
			[NSException raise:NSInternalInconsistencyException
						format:@"delegate does not implement clearVisibleTags"];
		}		
	}
	else
	{
		[self setDisplayMessage:@""];
	}
	
	if ([delegate respondsToSelector:@selector(setDisplayTags:)])
	{
		[delegate setDisplayTags:[relatedTags relatedTags]];
	}
	else
	{
		[NSException raise:NSInternalInconsistencyException
					format:@"delegate does not implement setDisplayTags:"];
	}
}

- (void)thumbnailWasGenerated:(NSNotification *)notification
{
	PAThumbnailItem *thumbItem = (PAThumbnailItem *)[notification object];
	
	if([thumbItem view] == outlineView)
	{	
		[self performSelectorOnMainThread:@selector(drawThumbItem:)
							   withObject:thumbItem
							waitUntilDone:NO];
		
		//NSRect rectToDisplay = [thumbItem frame];
//		[outlineView displayRect:rectToDisplay];
	}
}

- (void)drawThumbItem:(PAThumbnailItem*)thumbItem
{
	NSRect rectToDisplay = [thumbItem frame];
	[outlineView displayRect:rectToDisplay];
}

- (void)queryNote:(NSNotification *)notification
{
	// Start or stop progress animation	
	if([[notification name] isEqualTo:NNQueryDidStartGatheringNotification])
	{
		[outlineView reloadData];
		
		//NSString *desc = NSLocalizedStringFromTable(@"PROGRESS_SEARCHING", @"Global", nil);
		//[[[[NSApplication sharedApplication] delegate] browserController] startProgressAnimationWithDescription:desc];
	}
	else if([[notification name] isEqualTo:NNQueryDidFinishGatheringNotification])
	{
		[outlineView reloadData];
		
		//[[[[NSApplication sharedApplication] delegate] browserController] stopProgressAnimation];
		if ([delegate respondsToSelector:@selector(updateTagCloudDisplayMessage)])
		{
			[delegate updateTagCloudDisplayMessage];
		}
		else
		{
			[NSException raise:NSInternalInconsistencyException
						format:@"delegate does not implement updateTagCloudDisplayMessage"];
		}
	}
	else if ([[notification name] isEqualTo:NNQueryDidResetNotification])
	{
		[outlineView reloadData];
	}
}

- (void)contentTypeFilterUpdate:(NSNotification*)notification
{
	[query removeAllFilters];
	NSString *contentType = [[notification userInfo] objectForKey:@"contentType"];
	NNContentTypeTreeQueryFilter *filter = 
		[NNContentTypeTreeQueryFilter contentTypeTreeQueryFilterForType:contentType];
	[query addFilter:filter];
}


#pragma mark Temp
- (void)setGroupingAttributes:(id)sender;
{
	NSSegmentedControl *sc = sender;
	if([sc selectedSegment] == 0) {
		[query setBundlingAttributes:[NSArray arrayWithObjects:@"kMDItemContentTypeTree", nil]];
	}
	if([sc selectedSegment] == 1) {
		[query setBundlingAttributes:[NSArray arrayWithObjects:nil]];
	}
}

#pragma mark ResultsOutlineView Data Source
- (id)          outlineView:(NSOutlineView *)ov 
  objectValueForTableColumn:(NSTableColumn *)tableColumn
					 byItem:(id)item
{
	return item;
	
	/*if([item isKindOfClass:[NNQueryBundle class]])
	return item;
	else 
	return [item valueForAttribute:@"value"];*/
}

- (id)outlineView:(NSOutlineView *)ov child:(NSInteger)idx ofItem:(id)item
{		
	if(item == nil)
	{
		// Children depend on display mode		
		if([outlineView displayMode] == PAThumbnailMode)
		{
			return [query results];
		}
		
		return [query resultAtIndex:idx];
	}
	
	if([item isKindOfClass:[NNQueryBundle class]])
	{
		NNQueryBundle *bundle = item;
		
		// Children depend on display mode		
		if([outlineView displayMode] == PAThumbnailMode)
		{
			return [bundle results];
		}
		
		//NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		//NSDictionary *currentDisplayModes = [[defaults objectForKey:@"Results"] objectForKey:@"CurrentDisplayModes"];
		
		/*if([[currentDisplayModes objectForKey:[group value]] isEqualToString:@"IconMode"]) */
		
		return [bundle resultAtIndex:idx];
	}
	
	return nil;
}

- (BOOL)outlineView:(NSOutlineView *)ov isItemExpandable:(id)item
{
	if(item == nil) return YES;
	
	return ([self outlineView:ov numberOfChildrenOfItem:item] != 0);
}

- (NSInteger)outlineView:(NSOutlineView *)ov numberOfChildrenOfItem:(id)item
{
	if(item == nil)
	{
		// Number of children depends on display mode
		if([outlineView displayMode] == PAThumbnailMode) return 1;
		
		return [query resultCount];
	}
	
	if([item isKindOfClass:[NNQueryBundle class]])
	{
		NNQueryBundle *bundle = item;
		
		// Number of children depends on display mode
		if([outlineView displayMode] == PAThumbnailMode) return 1;
		
		/*NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		NSDictionary *currentDisplayModes = [[defaults objectForKey:@"Results"] objectForKey:@"CurrentDisplayModes"];
		
		if([[currentDisplayModes objectForKey:[bundle value]] isEqualToString:@"IconMode"])
			return 1;*/
		
		return [bundle resultCount];
	}
	
	return 0;
}


#pragma mark ResultsOutlineView Set Object Value
- (void)outlineView:(NSOutlineView *)ov
     setObjectValue:(id)object
	 forTableColumn:(NSTableColumn *)tableColumn
	         byItem:(id)item
{
	NNTaggableObject *taggableObject = item;
	NSString *value = object;
	
	[taggableObject renameTo:value errorWindow:[ov window]];
	
	// TODO waterjoe
	[ov reloadData];
}

#pragma mark ResultsOutlineView Delegate
- (CGFloat)outlineView:(NSOutlineView *)ov heightOfRowByItem:(id)item
{		
	// Bundles have a fix height
	if([item isKindOfClass:[NNQueryBundle class]]) return 20.0;
	
	// Height of list items is determined by its content type
	if([item isKindOfClass:[NNFile class]])
	{
		NSString *contentType = [item valueForAttribute:@"kMDItemContentTypeTree"];		
		if([contentType isEqualToString:@"BOOKMARKS"] &&
		   [[outlineView query] hasFilter])
			return [PAResultsBookmarkCell heightOfRow];
		else
			return [PAResultsItemCell heightOfRow];
	}
	
	
	
	// Get height of multi item dynamically	from outlineview

	Class cellClass = [PAResultsMultiItemPlaceholderCell class];
	switch([outlineView displayMode])
	{
		case PAThumbnailMode:
			cellClass = [PAResultsMultiItemThumbnailCell class]; break;
	}
	
	NSSize cellSize = [cellClass cellSize];
	NSSize intercellSpacing = [cellClass intercellSpacing];
	CGFloat indentationPerLevel = [outlineView indentationPerLevel];
	CGFloat offsetToRightBorder = 20.0;
	NSRect frame = [outlineView frame];
	
	NSInteger numberOfItemsPerRow = (frame.size.width - indentationPerLevel - offsetToRightBorder) /
		(cellSize.width + intercellSpacing.width);
	
	NSInteger numberOfRows = [item count] / numberOfItemsPerRow;
	if([item count] % numberOfItemsPerRow > 0) numberOfRows++;
	
	NSInteger result = numberOfRows * (cellSize.height + intercellSpacing.height);
	if(result == 0) result = 1;
	
	return result;
}

- (id)tableColumn:(NSTableColumn *)column
	  inTableView:(NSTableView *)tableView
   dataCellForRow:(NSInteger)row
{
	NSOutlineView *ov = (NSOutlineView *)tableView;
	id item = [ov itemAtRow:row];
	
	NSCell *cell;	
	if([item isKindOfClass:[NNQueryBundle class]])
	{
		cell = [[[PAResultsGroupCell alloc] initTextCell:@""] autorelease];
	}
	else if([item isKindOfClass:[NNFile class]])
	{
		NSString *contentType = [item valueForAttribute:@"kMDItemContentTypeTree"];
		if([contentType isEqualToString:@"BOOKMARKS"] &&
		   [[outlineView query] hasFilter])
		{
			cell = [[[PAResultsBookmarkCell alloc] initTextCell:@""] autorelease];
			[cell setEditable:YES];
		} else {
			cell = [[[PAResultsItemCell alloc] initTextCell:@""] autorelease];
			[cell setEditable:YES];
		}
	}
	else 
	{
		cell = [[[PAResultsMultiItemCell alloc] initTextCell:@""] autorelease];
	}		
	
	return cell;
}

- (void)     outlineView:(NSOutlineView *)ov
  willDisplayOutlineCell:(id)cell
	      forTableColumn:(NSTableColumn *)tableColumn
                    item:(id)item
{
	// Hide default triangle
	[cell setImage:[NSImage imageNamed:@"transparent"]];
	[cell setAlternateImage:[NSImage imageNamed:@"transparent"]];
}

- (void)outlineView:(NSOutlineView *)outlineView
	willDisplayCell:(id)cell
	 forTableColumn:(NSTableColumn *)tableColumn
	           item:(id)item
{
	// nothing yet
}

- (void)outlineViewItemDidCollapse:(NSNotification *)notification
{
	// nothing yet
}

- (BOOL)outlineView:(NSOutlineView *)ov shouldSelectItem:(id)item
{
	// Resign any matrix from being responder
	if(![item isKindOfClass:[NSArray class]])
	{
		[outlineView setResponder:nil];
	}
	
	return [item isKindOfClass:[NNQueryBundle class]] ? NO : YES;
}


#pragma mark Misc
- (void)arrangeBy:(NSString *)type 
{
	NSSortDescriptor *desc = nil;
	
	if ([type isEqualToString:@"Name"]) {
		desc = [[NSSortDescriptor alloc] initWithKey:@"displayName" ascending:YES];
	} else if ([type isEqualToString:@"Date Modified"]) {
		desc = [[NSSortDescriptor alloc] initWithKey:@"modificationDate" ascending:NO];
	} else if ([type isEqualToString:@"Date Created"]) {
		desc = [[NSSortDescriptor alloc] initWithKey:@"creationDate" ascending:NO];
	} else if ([type isEqualToString:@"Size"]) {
		desc = [[NSSortDescriptor alloc] initWithKey:@"size" ascending:NO];
	} else if ([type isEqualToString:@"Kind"]) {
		desc = [[NSSortDescriptor alloc] initWithKey:@"kind" ascending:NO];
	}
	
	if (desc != nil) {
		NSArray *sortDescriptors = [NSArray arrayWithObject:desc];
		[query setSortDescriptors:sortDescriptors];		
	} else {
		lcl_log(lcl_cglobal, lcl_vError, @"sortDescriptors unset, this must not happen");
	}
}

- (void)toggleResultsGrouping
{
	[query toggleResultsGrouping];
}

- (void)deleteDraggedItems
{
	if (draggedItems)
	{
		NSEnumerator *enumerator = [draggedItems objectEnumerator];
		NNTaggableObject *item;
		
		while(item = [enumerator nextObject])
		{
			[item moveToTrash:YES errorWindow:[view window]];
		}
		
		[self setDraggedItems:nil];
		
		[outlineView reloadData];
	}
}

- (void)deleteFilesForSelectedItems:(id)sender
{
	for (NNTaggableObject *item in [outlineView selectedItems])
	{
		[item moveToTrash:YES errorWindow:[outlineView window]];
	}
}

- (IBAction)openFiles:(id)sender
{
	[[NSApp delegate] openFiles:sender];
}

- (IBAction)revealInFinder:(id)sender
{
	[[NSApp delegate] revealInFinder:sender];
}

- (IBAction)getInfo:(id)sender
{
	[[NSApp delegate] getInfo:sender];
}

- (NSArray*)createContentTypeQueryFilters
{
	NSArray *identifiers = [NSArray array];
	NSMutableArray *queryFilters = [NSMutableArray array];
	
	if ([delegate respondsToSelector:@selector(contentTypeFilterIdentifiers)])
	{
		identifiers = [delegate contentTypeFilterIdentifiers];
	}
	else
	{
		[NSException raise:NSInternalInconsistencyException
					format:@"delegate does not implement contentTypeFilterIdentifiers"];
	}
	
	NSEnumerator *e = [identifiers objectEnumerator];
	NSString *identifier;
	
	while (identifier = [e nextObject])
	{
		NNContentTypeTreeQueryFilter *filter = 
			[NNContentTypeTreeQueryFilter contentTypeTreeQueryFilterForType:identifier];

		[queryFilters addObject:filter];
	}
	
	return queryFilters;
}

/*- (NSArray *)selectedItems
{
	return [self selectedItems:self];
}*/

/**
	Returns all currently selected items of the OutlineView, works fine even if a responder is active
*/
/*- (NSArray *)selectedItems:(id)sender
{
	[outlineView saveSelection];

	NSMutableArray *selectedItems = [NSMutableArray array];
	
	for(unsigned row = 0; row < [outlineView numberOfRows]; row++)
	{
		id item = [outlineView itemAtRow:row];
		
		if([[outlineView selectedRowIndexes] containsIndex:row])
		{
			if([item isKindOfClass:[NSArray class]] && [outlineView responder])
			{
				NSArray *responderItems = [[outlineView responder] selectedItems];
				[selectedItems addObjectsFromArray:responderItems];
				
				for(unsigned i = 0; i < [responderItems count]; i++)
				{
					id responderItem = [responderItems objectAtIndex:i];
					if([[outlineView selectedQueryItems] containsObject:responderItem]) [[outlineView selectedQueryItems] removeObject:responderItem];
				}
			}
			else
			{
				[selectedItems addObject:item];			
				if([[outlineView selectedQueryItems] containsObject:item]) [[outlineView selectedQueryItems] removeObject:item];
			}
		}
	}
	
	return selectedItems;
}*/


#pragma mark Accessors
- (PAResultsOutlineView *)outlineView
{
	return outlineView;
}

#pragma mark table drag & drop support
- (BOOL)outlineView:(NSOutlineView *)outlineView
		 writeItems:(NSArray *)items 
	   toPasteboard:(NSPasteboard *)pboard
{
	NSMutableArray *fileList = [NSMutableArray array];
	
	NSEnumerator *e = [items objectEnumerator];
	NNFile *queryItem;
	
	while (queryItem = [e nextObject])
	{
		[fileList addObject:[queryItem valueForAttribute:(id)kMDItemPath]];
	}
	
	[self setDraggedItems:items];
	
	[pboard declareTypes:[NSArray arrayWithObject:NSFilenamesPboardType] owner:nil];
	[pboard setPropertyList:fileList forType:NSFilenamesPboardType];
	
	return YES;
}

- (NSDragOperation)outlineView:(NSOutlineView *)ov 
				  validateDrop:(id <NSDraggingInfo>)info 
				  proposedItem:(id)item 
			proposedChildIndex:(NSInteger)idx
{
	// check if sender should be ignored
	if(![dropManager acceptsSender:[info draggingSource]])
		return NSDragOperationNone;
		
	// Discard dragging on self
	if([info draggingSource] == ov ||
	   ([outlineView responder] && [info draggingSource] == [outlineView responder]))
		return NSDragOperationNone;
		
	// Discard if no selected tags are present
	if(!selectedTags || [selectedTags count] == 0)
		return NSDragOperationNone;

	// retarget to whole outlineview
	[outlineView setDropItem:nil dropChildIndex:NSOutlineViewDropOnItemIndex];
	
	return [dropManager performedDragOperation:[info draggingPasteboard]];
}

- (BOOL)outlineView:(NSOutlineView *)outlineView 
		 acceptDrop:(id <NSDraggingInfo>)info 
			   item:(id)item 
		 childIndex:(NSInteger)idx
{
	NSArray *objects = [dropManager handleDrop:[info draggingPasteboard]];
	NSArray *tagArray = [selectedTags selectedTags];
	
	// If dropManager is in alternateState, set manageFiles flag on each object
	
	BOOL alternateState = [dropManager alternateState];
	
	if(alternateState)
	{		
		NSEnumerator *e = [objects objectEnumerator];
		NNTaggableObject *object;
		
		while(object = [e nextObject])
		{
			BOOL theDefault = [[NSUserDefaults standardUserDefaults] boolForKey:@"ManageFiles.ManagedFolder.Enabled"];
			
			if([[object tags] count] > 0)
			{
				BOOL newFlag = !theDefault;
				[object setShouldManageFiles:newFlag];
			}
		}
	}
	
	// Perform action addTags:
	[objects makeObjectsPerformSelector:@selector(addTags:) withObject:tagArray];
	
	// Now switch back to automatic management 
	if(alternateState)
	{		
		NSEnumerator *e = [objects objectEnumerator];
		NNTaggableObject *object;
		
		while(object = [e nextObject])
		{	
			[object setShouldManageFilesAutomatically:YES];
		}
	}
	
    return YES;    
}

@end
