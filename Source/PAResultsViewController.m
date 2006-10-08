//
//  PAResultsViewController.m
//  punakea
//
//  Created by Johannes Hoffart on 26.09.06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "PAResultsViewController.h"


@implementation PAResultsViewController

- (id)init
{
	if (self = [super init])
	{
		tagger = [PATagger sharedInstance];
		tags = [tagger tags];
		
		selectedTags = [[PASelectedTags alloc] init];
		
		query = [[PAQuery alloc] init];
		[query setBundlingAttributes:[NSArray arrayWithObjects:@"kMDItemContentTypeTree", nil]];
		[query setSortDescriptors:[NSArray arrayWithObject:[[[NSSortDescriptor alloc] initWithKey:(id)kMDItemFSName ascending:YES] autorelease]]];
		
		dropManager = [PADropManager sharedInstance];
		
		relatedTags = [[PARelatedTags alloc] initWithSelectedTags:selectedTags query:query];
		
		nc = [NSNotificationCenter defaultCenter];
		
		draggedItems = nil;
		
		[nc addObserver:self 
			   selector:@selector(selectedTagsHaveChanged:) 
				   name:@"PASelectedTagsHaveChanged" 
				 object:selectedTags];
		
		[nc addObserver:self 
			   selector:@selector(relatedTagsHaveChanged:) 
				   name:@"PARelatedTagsHaveChanged" 
				 object:relatedTags];
		
		[NSBundle loadNibNamed:@"ResultsView" owner:self];
	}
	return self;
}

- (void)awakeFromNib
{
	[outlineView setQuery:query];
	[outlineView registerForDraggedTypes:[dropManager handledPboardTypes]];
	[outlineView setDraggingSourceOperationMask:NSDragOperationNone forLocal:YES];
	[outlineView setDraggingSourceOperationMask:(NSDragOperationCopy | NSDragOperationDelete) forLocal:NO];
}

- (void)dealloc
{
	[draggedItems release];
	[outlineView unregisterDraggedTypes];
	[nc removeObserver:self];
	[relatedTags release];
    [query release];
	[selectedTags release];
	[super dealloc];
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

- (IBAction)clearSelectedTags:(id)sender
{
	[selectedTags removeAllTags];
}

- (void)removeLastTag
{
	if ([selectedTags count] > 0)
		[selectedTags removeLastTag];
}

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
		[delegate setDisplayTags:[NSMutableArray array]];
	}
	else 
	{
		// there are no selected tags, reset all tags
		[delegate resetDisplayTags];
	}
}

- (void)relatedTagsHaveChanged:(NSNotification*)notification
{
	[delegate setDisplayTags:[relatedTags relatedTagArray]];
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
	PAQueryItem *queryItem = item;
	NSString *value = object;
	
	PAFile *file = [PAFile fileWithPath:[queryItem valueForAttribute:(id)kMDItemPath]];
	
	BOOL wasMoved = [query renameItem:queryItem to:value errorWindow:[ov window]];
	
	if(wasMoved) [ov reloadData];
}


#pragma mark ResultsOutlineView Delegate
- (float)outlineView:(NSOutlineView *)ov heightOfRowByItem:(id)item
{		
	if([item isKindOfClass:[PAQueryBundle class]]) return 20.0;
	if([item isKindOfClass:[PAQueryItem class]]) return 19.0;
	
	// TEMP
	//return 200.0;
	
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
	else if([item isKindOfClass:[PAQueryItem class]])
	{
		cell = [[[PAResultsItemCell alloc] initTextCell:@""] autorelease];
		[cell setEditable:YES];
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
	/*if([item isKindOfClass:[NSMetadataQueryResultGroup class]])
	{
		[cell setObjectValue:item];
		NSLog([item value]);
	}*/
	//if([[item class] isEqualTo:[NSMetadataItem class]])
	//	[(PAResultsItemCell *)cell setItem:(NSMetadataItem *)item];
	
	// TODO Replace this by setObjectValue
	/*if([[item class] isEqualTo:[PAResultsMultiItem class]])
	[(PAResultsMultiItemCell *)cell setItem:(PAResultsMultiItem *)item];*/
}

- (void)outlineViewItemDidCollapse:(NSNotification *)notification
{
	//NSMetadataQueryResultGroup *item = (NSMetadataQueryResultGroup *)[[notification userInfo] objectForKey:@"NSObject"];
	//[self removeAllMultiItemSubviewsWithIdentifier:[item value]];
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

- (void)deleteFilesForSelectedQueryItems:(id)sender
{
	[outlineView saveSelection];

	NSMutableArray *selectedQueryItems = [outlineView selectedQueryItems];

	[[outlineView query] trashItems:selectedQueryItems errorWindow:[outlineView window]];
	
	[selectedQueryItems removeAllObjects];
	
	[outlineView reloadData];
}


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
	PAQueryItem *queryItem;
	
	while (queryItem = [e nextObject])
	{
		[fileList addObject:[queryItem valueForAttribute:(id)kMDItemPath]];
	}
	
	[self setDraggedItems:items];
	
	[pboard declareTypes:[NSArray arrayWithObject:NSFilenamesPboardType] owner:nil];
	[pboard setPropertyList:fileList forType:NSFilenamesPboardType];
	
	return YES;
}

- (NSDragOperation)outlineView:(NSOutlineView *)outlineView 
				  validateDrop:(id <NSDraggingInfo>)info 
				  proposedItem:(id)item 
			proposedChildIndex:(int)index
{
	// retarget to whole outlineview
	[outlineView setDropItem:nil dropChildIndex:NSOutlineViewDropOnItemIndex];
	
	return [dropManager performedDragOperation:[info draggingPasteboard]];
}

- (BOOL)outlineView:(NSOutlineView *)outlineView 
		 acceptDrop:(id <NSDraggingInfo>)info 
			   item:(id)item 
		 childIndex:(int)index
{
	NSArray *files = [dropManager handleDrop:[info draggingPasteboard]];
	NSArray *tagArray = [selectedTags selectedTags];
	
	[tagger addTags:tagArray toFiles:files];
    return YES;    
}


@end
