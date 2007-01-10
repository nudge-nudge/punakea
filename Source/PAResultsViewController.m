//
//  PAResultsViewController.m
//  punakea
//
//  Created by Johannes Hoffart on 26.09.06.
//  Copyright 2006 nudge:nudge. All rights reserved.
//

#import "PAResultsViewController.h"


@implementation PAResultsViewController

#pragma mark init
- (id)init
{
	if (self = [super init])
	{
		tags = [PATags sharedTags];
		
		selectedTags = [[PASelectedTags alloc] init];
		
		query = [[PAQuery alloc] init];
		[query setBundlingAttributes:[NSArray arrayWithObjects:@"kMDItemContentTypeTree", nil]];
		[query setSortDescriptors:[NSArray arrayWithObject:[[[NSSortDescriptor alloc] initWithKey:(id)kMDItemFSName ascending:YES] autorelease]]];
		
		dropManager = [PADropManager sharedInstance];
		
		relatedTags = [[PARelatedTags alloc] initWithSelectedTags:selectedTags query:query];
		
		draggedItems = nil;
		
		nc = [NSNotificationCenter defaultCenter];
		
		[nc addObserver:self 
			   selector:@selector(selectedTagsHaveChanged:) 
				   name:@"PASelectedTagsHaveChanged" 
				 object:selectedTags];
		
		[nc addObserver:self 
			   selector:@selector(relatedTagsHaveChanged:) 
				   name:@"PARelatedTagsHaveChanged" 
				 object:relatedTags];
				 
		[nc addObserver:self 
			   selector:@selector(thumbnailWasGenerated:)
				   name:@"PAThumbnailManagerDidFinishGeneratingItemNotification"
				 object:nil];
				
		[NSBundle loadNibNamed:@"ResultsView" owner:self];
	}
	return self;
}

- (void)awakeFromNib
{
	// if we are managing files, copy on drag
	// else move
	BOOL managingFiles = [[NSUserDefaults standardUserDefaults] boolForKey:@"General.ManageFiles"];
	NSDragOperation dragOperation = managingFiles ? NSDragOperationCopy : NSDragOperationMove;
	
	[outlineView setQuery:query];
	[outlineView registerForDraggedTypes:[dropManager handledPboardTypes]];
	[outlineView setDraggingSourceOperationMask:NSDragOperationNone forLocal:YES];
	[outlineView setDraggingSourceOperationMask:(dragOperation | NSDragOperationCopy | NSDragOperationDelete) forLocal:NO];
	
	[relatedTags addObserver:self
				  forKeyPath:@"updating"
					 options:0
					 context:NULL];
}

- (void)dealloc
{
	[relatedTags removeObserver:self forKeyPath:@"updating"];
	
	[nc removeObserver:self];
	
	[outlineView unregisterDraggedTypes];
	[draggedItems release];

	[relatedTags release];
    [query release];
	[selectedTags release];
	[super dealloc];
}

#pragma mark observing
- (void)observeValueForKeyPath:(NSString *)keyPath 
					  ofObject:(id)object 
						change:(NSDictionary *)change
					   context:(void *)context
{
	if ([keyPath isEqualToString:@"updating"])
	{
		if ([relatedTags isUpdating])
			[progressIndicator startAnimation:self];
		else
			[progressIndicator stopAnimation:self];
	}
}


#pragma mark accessors
- (PAQuery*)query
{
	return query;
}

- (PARelatedTags*)relatedTags;
{
	return relatedTags;
}

- (void)setRelatedTags:(PARelatedTags*)otherRelatedTags
{
	[otherRelatedTags retain];
	[relatedTags release];
	relatedTags = otherRelatedTags;
}

- (PASelectedTags*)selectedTags;
{
	return selectedTags;
}

- (void)setSelectedTags:(PASelectedTags*)otherSelectedTags
{
	[otherSelectedTags retain];
	[selectedTags release];
	selectedTags = otherSelectedTags;
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
- (void)handleTagActivation:(PATag*)tag
{
	[tag incrementClickCount];
	[selectedTags addTag:tag];
}

- (void)reset
{
	[self clearSelectedTags:self];
}

- (void)clearSelectedTags:(id)sender
{
	[selectedTags removeAllTags];
}

- (void)removeLastTag
{
	if ([selectedTags count] > 0)
		[selectedTags removeLastTag];
}

- (IBAction)doubleAction:(id)sender
{
	NSIndexSet *selectedRowIndexes = [outlineView selectedRowIndexes];	
	unsigned row = [selectedRowIndexes firstIndex];
	while(row != NSNotFound) 
	{
		id item = [outlineView itemAtRow:row];
		
		if([[item class] isEqualTo:[PAFile class]])
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
	PAQueryBundle *item = [tag objectForKey:@"bundle"];
	
	if([outlineView isItemExpanded:item])
	{
		// Just toggle the item's state
		[outlineView collapseItem:item];
	} else {
		// If we expand an item, we need to redraw all previously visible rows so that they
		// can correctly (re-)move their subviews
		
		NSRange previousVisibleRowsRange = [outlineView rowsInRect:[outlineView visibleRect]];
		
		[outlineView expandItem:item];
		
		int numberOfChildrenOfItem = [[outlineView delegate] outlineView:outlineView numberOfChildrenOfItem:item];
		for(unsigned i = 0; i < previousVisibleRowsRange.length; i++)
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


#pragma mark Notifications
- (void)selectedTagsHaveChanged:(NSNotification*)notification
{
	// stop an active query
	if ([query isStarted])
	{
		[query stopQuery];
	}
	
	[query setTags:selectedTags];
	
	// the query is only started if there are any tags to look for
	if ([selectedTags count] > 0)
	{
		[query startQuery];
		
		// empty display tags until new related tags are found
		if ([delegate respondsToSelector:@selector(setDisplayTags:)])
		{
			[delegate setDisplayTags:[NSMutableArray array]];
		}
		else
		{
			[NSException raise:NSInternalInconsistencyException
						format:@"delegate does not implement setDisplayTags:"];
		}
	}
	else 
	{
		// there are no selected tags, reset all tags
		if ([delegate respondsToSelector:@selector(resetDisplayTags)])
		{
			[delegate resetDisplayTags];
		}
		else
		{
			[NSException raise:NSInternalInconsistencyException
						format:@"delegate does not implement setDisplayTags:"];
		}
	}
}

- (void)relatedTagsHaveChanged:(NSNotification *)notification
{
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

-(void)thumbnailWasGenerated:(NSNotification *)notification
{
	PAThumbnailItem *thumbItem = (PAThumbnailItem *)[notification object];
	
	if([thumbItem view] == outlineView)
	{	
		[outlineView displayRect:[thumbItem frame]];
	}
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
	
	/*if([item isKindOfClass:[PAQueryBundle class]])
	return item;
	else 
	return [item valueForAttribute:@"value"];*/
}

- (id)outlineView:(NSOutlineView *)ov child:(int)idx ofItem:(id)item
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
	
	if([item isKindOfClass:[PAQueryBundle class]])
	{
		PAQueryBundle *bundle = item;
		
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

- (int)outlineView:(NSOutlineView *)ov numberOfChildrenOfItem:(id)item
{
	if(item == nil)
	{
		// Number of children depends on display mode
		if([outlineView displayMode] == PAThumbnailMode) return 1;
		
		return [query resultCount];
	}
	
	if([item isKindOfClass:[PAQueryBundle class]])
	{
		PAQueryBundle *bundle = item;
		
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
	PATaggableObject *taggableObject = item;
	NSString *value = object;
	
	BOOL wasMoved = [taggableObject renameTo:value errorWindow:[ov window]];
	
	if(wasMoved) [ov reloadData];
}

#pragma mark ResultsOutlineView Delegate
- (float)outlineView:(NSOutlineView *)ov heightOfRowByItem:(id)item
{		
	// Bundles have a fix height
	if([item isKindOfClass:[PAQueryBundle class]]) return 20.0;
	
	// Height of list items is determined by its content type
	if([item isKindOfClass:[PAFile class]])
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
	float indentationPerLevel = [outlineView indentationPerLevel];
	float offsetToRightBorder = 20.0;
	NSRect frame = [outlineView frame];
	
	int numberOfItemsPerRow = (frame.size.width - indentationPerLevel - offsetToRightBorder) /
		(cellSize.width + intercellSpacing.width);
	
	int numberOfRows = [item count] / numberOfItemsPerRow;
	if([item count] % numberOfItemsPerRow > 0) numberOfRows++;
	
	int result = numberOfRows * (cellSize.height + intercellSpacing.height);
	if(result == 0) result = 1;
	
	return result;
}

- (id)tableColumn:(NSTableColumn *)column
	  inTableView:(NSTableView *)tableView
   dataCellForRow:(int)row
{
	NSOutlineView *ov = (NSOutlineView *)tableView;
	id item = [ov itemAtRow:row];
	
	NSCell *cell;	
	if([item isKindOfClass:[PAQueryBundle class]])
	{
		cell = [[[PAResultsGroupCell alloc] initTextCell:@""] autorelease];
	}
	else if([item isKindOfClass:[PAFile class]])
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
	
	return [item isKindOfClass:[PAQueryBundle class]] ? NO : YES;
}


#pragma mark Misc
- (void)deleteDraggedItems
{
	if (draggedItems)
	{
		[outlineView saveSelection];
		
		[[outlineView query] trashItems:draggedItems errorWindow:[outlineView window]];
		
		[self setDraggedItems:nil];
		
		[outlineView reloadData];
	}
}

- (void)deleteFilesForVisibleSelectedItems:(id)sender
{
	[[outlineView query] trashItems:[outlineView visibleSelectedItems] errorWindow:[outlineView window]];
	
	[outlineView reloadData];
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
	PAFile *queryItem;
	
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
			proposedChildIndex:(int)idx
{
	// Discard dragging from tag button
	if([[info draggingSource] isMemberOfClass:[PATagButton class]])
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
		 childIndex:(int)idx
{
	NSArray *objects = [dropManager handleDrop:[info draggingPasteboard]];
	NSArray *tagArray = [selectedTags selectedTags];
	
	[objects makeObjectsPerformSelector:@selector(addTags:) withObject:tagArray];
    return YES;    
}

@end
