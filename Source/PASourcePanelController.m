//
//  PASourcePanelController.m
//  punakea
//
//  Created by Daniel on 28.03.07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "PASourcePanelController.h"

NSString * const PAContentTypeFilterUpdate = @"PAContentTypeFilterUpdate";

@implementation PASourcePanelController

#pragma mark Init + Dealloc
- (id)init
{
	if (self = [super init])
	{
		dropManager = [PADropManager sharedInstance];
		
		// Define Source Items
		items = [[NSMutableArray alloc] init];
		
		// Group: Library
		PASourceItem *sourceGroup = [PASourceItem itemWithValue:@"LIBRARY" displayName:@"LIBRARY"];
		[sourceGroup setSelectable:NO];
		[sourceGroup setHeading:YES];
		
		PASourceItem *sourceItem = [PASourceItem itemWithValue:@"ALL_ITEMS" displayName:@"All Items"];
		[sourceItem setImage:[NSImage imageNamed:@"source-panel-shelf"]];
		[sourceItem setEditable:NO];
		[sourceGroup addChild:sourceItem];
		
		PASourceItem *fileKindItem;
		
		fileKindItem = [PASourceItem itemWithValue:@"BOOKMARKS" displayName:
						NSLocalizedStringFromTableInBundle(@"BOOKMARKS", @"MDSimpleGrouping", [NSBundle bundleWithIdentifier:@"eu.nudgenudge.nntagging"], nil)];
		[fileKindItem setImage:[NSImage imageNamed:@"source-panel-bookmarks"]];
		[fileKindItem setEditable:NO];
		[sourceItem addChild:fileKindItem];
		
		fileKindItem = [PASourceItem itemWithValue:@"IMAGES" displayName:
						NSLocalizedStringFromTableInBundle(@"IMAGES", @"MDSimpleGrouping", [NSBundle bundleWithIdentifier:@"eu.nudgenudge.nntagging"], nil)];
		[fileKindItem setImage:[NSImage imageNamed:@"source-panel-images"]];
		[fileKindItem setEditable:NO];
		[sourceItem addChild:fileKindItem];		
		
		fileKindItem = [PASourceItem itemWithValue:@"MOVIES" displayName:
						NSLocalizedStringFromTableInBundle(@"MOVIES", @"MDSimpleGrouping", [NSBundle bundleWithIdentifier:@"eu.nudgenudge.nntagging"], nil)];
		[fileKindItem setImage:[NSImage imageNamed:@"source-panel-movies"]];
		[fileKindItem setEditable:NO];
		[sourceItem addChild:fileKindItem];
		
		fileKindItem = [PASourceItem itemWithValue:@"MUSIC" displayName:
						NSLocalizedStringFromTableInBundle(@"MUSIC", @"MDSimpleGrouping", [NSBundle bundleWithIdentifier:@"eu.nudgenudge.nntagging"], nil)];
		[fileKindItem setImage:[NSImage imageNamed:@"source-panel-music"]];
		[fileKindItem setEditable:NO];
		[sourceItem addChild:fileKindItem];
		
		fileKindItem = [PASourceItem itemWithValue:@"PDF" displayName:
						NSLocalizedStringFromTableInBundle(@"PDF", @"MDSimpleGrouping", [NSBundle bundleWithIdentifier:@"eu.nudgenudge.nntagging"], nil)];
		NSImage *image = [[NSWorkspace sharedWorkspace] iconForFileType:@"PDF"];
		[image setSize:NSMakeSize(16,16)];
		[fileKindItem setImage:image];
		[fileKindItem setEditable:NO];
		[sourceItem addChild:fileKindItem];
		
		sourceItem = [PASourceItem itemWithValue:@"MANAGE_TAGS" displayName:@"Manage Tags"];
		[sourceItem setImage:[NSImage imageNamed:@"source-panel-manage-tags"]];
		[sourceItem setEditable:NO];
		[sourceGroup addChild:sourceItem];
		
		[items addObject:sourceGroup];
		
		// Group Favorites
		sourceItem = [PASourceItem itemWithValue:@"FAVORITES" displayName:@"Favorites"];
		[sourceItem setSelectable:NO];
		[sourceItem setHeading:YES];
		[items addObject:sourceItem];
	}
	return self;
}

- (void)dealloc
{
	[items release];
	[super dealloc];
}


#pragma mark Data Source
- (id)          outlineView:(NSOutlineView *)ov 
  objectValueForTableColumn:(NSTableColumn *)tableColumn
					 byItem:(id)item
{
	return item;
}

- (id)outlineView:(NSOutlineView *)ov child:(NSInteger)idx ofItem:(id)item
{		
	if(item == nil)
	{
		return [items objectAtIndex:idx];
	} else if([item isKindOfClass:[PASourceItem class]]) {
		return [[(PASourceItem *)item children] objectAtIndex:idx];
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
		return [items count];
	} else if([item isKindOfClass:[PASourceItem class]]) {
		return [[item children] count];
	}
	
	return 0;
}

- (void)outlineView:(NSOutlineView *)ov
     setObjectValue:(id)object
	 forTableColumn:(NSTableColumn *)tableColumn
	         byItem:(id)item
{
	PASourceItem *sourceItem = (PASourceItem *)item;
	
	NSString *newName = object;
	
	[sourceItem setDisplayName:newName];
	[sourceItem setValue:newName];
	
	if([[sourceItem containedObject] isMemberOfClass:[NNTagSet class]])
		[(NNTagSet *)[sourceItem containedObject] setName:newName];
	
	[[[[NSApplication sharedApplication] delegate] browserController] saveFavorites];
}


#pragma mark Delegate
- (BOOL)outlineView:(NSOutlineView *)ov shouldSelectItem:(id)item
{
	if([item isKindOfClass:[PASourceItem class]]) {
		return [(PASourceItem *)item isSelectable];
	}
	
	return YES;
}

- (void)outlineViewSelectionDidChange:(NSNotification *)notification
{	
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	
	NSOutlineView *ov = (NSOutlineView *)[notification object];
	
	PASourceItem *sourceItem = (PASourceItem *)[ov itemAtRow:[ov selectedRow]];
	
	// Perform actions
	if([[sourceItem value] isEqualTo:@"ALL_ITEMS"])
	{
		[[[NSApplication sharedApplication] delegate] resetBrowser:self];
		[[[NSApplication sharedApplication] delegate] showBrowserResults:self];
	}
	else if([[sourceItem value] isEqualTo:@"MANAGE_TAGS"])
	{
		[[[NSApplication sharedApplication] delegate] resetBrowser:self];
		[[[NSApplication sharedApplication] delegate] showBrowserManageTags:self];
	}
	else if([[sourceItem containedObject] isKindOfClass:[NNTag class]])
	{
		[[[NSApplication sharedApplication] delegate] searchForTags:[NSMutableArray arrayWithObject:[sourceItem containedObject]]];
	}
	else if([[sourceItem containedObject] isKindOfClass:[NNTagSet class]])
	{
		[[[NSApplication sharedApplication] delegate] searchForTags:[[sourceItem containedObject] tags]];
	}
	else
	{
		[[[NSApplication sharedApplication] delegate] resetBrowser:self];
		[[[NSApplication sharedApplication] delegate] showBrowserResults:self];
		
		// the sourceItem is a contenttypefilter
		NSString *contentType = [sourceItem value];
		
		[nc postNotificationName:PAContentTypeFilterUpdate
						  object:self
						userInfo:[NSDictionary dictionaryWithObject:contentType
															 forKey:@"contentType"]];
	}
}

- (id)tableColumn:(NSTableColumn *)column
	  inTableView:(NSTableView *)tableView
   dataCellForRow:(NSInteger)row
{
	PASourceItemCell *cell = [[[PASourceItemCell alloc] initTextCell:@""] autorelease];
	
	PASourceItem *sourceItem = (PASourceItem *)[(NSOutlineView *)tableView itemAtRow:row];
	if([sourceItem isEditable]) [cell setEditable:YES];
		
	return cell;
}

- (CGFloat)outlineView:(NSOutlineView *)ov heightOfRowByItem:(id)item
{
	if([item isKindOfClass:[PASourceItem class]])
	{
		PASourceItem *sourceItem = (PASourceItem *)item;
		if([sourceItem isHeading])
			return 25.0;
	}
	
	return 20.0;
}

- (void)     outlineView:(NSOutlineView *)ov
  willDisplayOutlineCell:(id)cell
	      forTableColumn:(NSTableColumn *)tableColumn
                    item:(id)item
{
	// Hide default triangle
	[cell setImagePosition:NSNoImage];
}

- (BOOL)outlineView:(NSOutlineView *)ov shouldCollapseItem:(id)item
{
	if([item isKindOfClass:[PASourceItem class]] &&
	   [(PASourceItem *)item isSelectable])
	{
		return YES;
	}
	
	return NO;
}


#pragma mark Drag & Drop
- (BOOL)outlineView:(NSOutlineView *)ov
		 writeItems:(NSArray *)someItems 
	   toPasteboard:(NSPasteboard *)pboard
{
	// Cancel any editing
	[NSObject cancelPreviousPerformRequestsWithTarget:sourcePanel
											 selector:@selector(beginEditing)
											   object:nil];
	
	// Weak temporary reference to draggedItems
	draggedItems = someItems;
	
	// Currently we only support single selection mode
	PASourceItem *sourceItem = [someItems objectAtIndex:0];
	
	if(![sourceItem containedObject])
		return NO;
	
	NSString *smartFolder;
	
	if([[sourceItem containedObject] isKindOfClass:[NNTag class]])
	{
		NNTag *tag = (NNTag *)[sourceItem containedObject];
		smartFolder = [PASmartFolder smartFolderFilenameForTag:tag];
	} else {
		NNTagSet *tagSet = (NNTagSet *)[sourceItem containedObject];
		smartFolder = [PASmartFolder smartFolderFilenameForTagSet:tagSet];	
	}
	
	NSArray *itemList = [NSArray arrayWithObject:smartFolder];
	
	[pboard declareTypes:[NSArray arrayWithObject:NSFilenamesPboardType] owner:nil];
	[pboard setPropertyList:itemList forType:NSFilenamesPboardType];
	
	return YES;
}

- (NSDragOperation)outlineView:(NSOutlineView *)ov 
				  validateDrop:(id <NSDraggingInfo>)info 
				  proposedItem:(id)item 
			proposedChildIndex:(NSInteger)idx
{
	BOOL isDroppedOnItem = idx==NSOutlineViewDropOnItemIndex;
	
	PASourceItem *sourceItem = (PASourceItem *)item;
	
	NNTag			*tag = nil;
	NNTagSet		*tagSet = nil;
	id				draggedObject = nil;
	
	// Allow dragging only to FAVORITES group, everything else is read-only	
	if(!([[sourceItem value] isEqualTo:@"FAVORITES"] ||
		 [sourceItem isDescendantOfValue:@"FAVORITES"]))
	{		
		return NSDragOperationNone;
	}
	
	// Deny dragging to group header except for tag buttons
	if ([[sourceItem value] isEqualToString:@"FAVORITES"] && isDroppedOnItem && idx == -1 &&
		![[info draggingSource] isMemberOfClass:[PATagButton class]])
		return NSDragOperationNone;
	
	// File Drop - Check if dragged object can be tagged and is to be dropped on a favorite
	NSDragOperation op = [dropManager performedDragOperation:[info draggingPasteboard]];
	if (op != NSDragOperationNone 
		&& isDroppedOnItem 
		&& ![[info draggingSource] isMemberOfClass:[PATagButton class]])
		return op;
	
	// Allow dragging only PATagButton or self as source
	if(!([[info draggingSource] isMemberOfClass:[PATagButton class]] ||
		 [info draggingSource] == ov))
		return NSDragOperationNone;
	
	if([[info draggingSource] isMemberOfClass:[PATagButton class]])
	{
		PATagButton *tagButton = [info draggingSource];
		tag = [tagButton genericTag];
		draggedObject = tag;
	} else {
		PASourceItem *draggedItem = [[[[info draggingSource] dataSource] draggedItems] objectAtIndex:0];
		draggedObject = [draggedItem containedObject];
		
		if([draggedObject isKindOfClass:[NNTag class]])
			tag = (NNTag *)draggedObject;
		else
			tagSet = (NNTagSet *)draggedObject;
	}	
	
	if([sourceItem isLeaf]) 
	{
		// Allow dropping on leafs to create/extend tag sets 
		if([[sourceItem containedObject] isKindOfClass:[NNTag class]])
		{
			NNTag *existingTag = (NNTag *)[sourceItem containedObject];
			
			if(tag)
			{
				if([existingTag isEqualTo:tag]) return NSDragOperationNone;
			} else {
				if([tagSet containsTag:existingTag]) return NSDragOperationNone;
			}
		
			return NSDragOperationCopy;
		} else {
			NNTagSet *existingSet = (NNTagSet *)[sourceItem containedObject];
			
			if(tag) 
			{
				if([existingSet containsTag:tag]) return NSDragOperationNone;
			} else {
				if([[existingSet tags] isEqualTo:[tagSet tags]]) return NSDragOperationNone;
			}
				
			return NSDragOperationCopy;
		}
		
		return NSDragOperationNone;
	}
	else
	{		
		// Deny adding duplicates
		// Set drag action to MOVE if source is self (reordering of items)		
		if([sourceItem hasChildContainingObject:draggedObject])
		{
		   if([info draggingSource] == ov && !isDroppedOnItem)
			   return NSDragOperationMove;
			else
				return NSDragOperationNone;
		}
	}

	return NSDragOperationCopy;
}

- (BOOL)outlineView:(NSOutlineView *)ov 
		 acceptDrop:(id <NSDraggingInfo>)info 
			   item:(id)item 
		 childIndex:(NSInteger)idx
{	
	BOOL isDroppedOnItem = idx==NSOutlineViewDropOnItemIndex;
	
	NNTag			*tag = nil;
	NNTagSet		*tagSet = nil;
	id				draggedObject = nil;
	
	PASourceItem	*sourceItem = (PASourceItem *)item;
	PASourceItem	*newItem = nil;
	
	// Check if Drop Manager can handle drop
	NSDragOperation op = [dropManager performedDragOperation:[info draggingPasteboard]];
	
	// Case 1: Files have been dropped on favorite
	if (op != NSDragOperationNone &&
		!([[info draggingSource] isMemberOfClass:[PATagButton class]] ||
		  [[info draggingSource] isKindOfClass:[PASourcePanel class]]))
	{
		// Get tags of this favorite item
		NSMutableArray *tags = [NSMutableArray array];
		
		if ([[sourceItem containedObject] isKindOfClass:[NNTag class]])
		{
			[tags addObject:[sourceItem containedObject]];
		}
		else
		{
			NNTagSet *set = [sourceItem containedObject];
			[tags addObjectsFromArray:[set tags]];
		}
		
		// Add tags to taggable object
		NSArray *objects = [dropManager handleDrop:[info draggingPasteboard]];
		
		// If dropManager is in alternateState, set manageFiles flag on each object
		BOOL alternateState = [dropManager alternateState];
		
		if(alternateState)
		{					
			for (NNTaggableObject *object in objects)
			{
				BOOL theDefault = [[NSUserDefaults standardUserDefaults] boolForKey:@"ManageFiles.ManagedFolder.Enabled"];
				
				if([[object tags] count] > 0)
				{
					BOOL newFlag = !theDefault;
					[object setShouldManageFiles:newFlag];
				}
			}
		}
		
		[objects makeObjectsPerformSelector:@selector(addTags:) withObject:tags];
	}	
	//-- Case 2: TagButton from Cloud has been dropped	
	else if([[info draggingSource] isMemberOfClass:[PATagButton class]])
	{
		PATagButton *tagButton = [info draggingSource];
		
		tag = [tagButton genericTag];
		draggedObject = tag;
	}
	//-- Case 3: Favorite has been dropped
	else
	{
		// We currently support only single selection mode in Source Panel, so there
		// may be at most one item that has been dropped

		PASourceItem *draggedItem = [[[[info draggingSource] dataSource] draggedItems] objectAtIndex:0];
		draggedObject = [draggedItem containedObject];
		
		if([draggedObject isKindOfClass:[NNTag class]])
			tag = (NNTag *)draggedObject;
		else
			tagSet = (NNTagSet *)draggedObject;
	}	
	
	if(isDroppedOnItem)
	{
		NNTag		*existingTag = nil;
		NNTagSet	*existingTagSet = nil;
		
		if([[sourceItem containedObject] isKindOfClass:[NNTag class]])
			existingTag = (NNTag *)[sourceItem containedObject];
		
		if([[sourceItem containedObject] isKindOfClass:[NNTagSet class]])
			existingTagSet = (NNTagSet *)[sourceItem containedObject];
		
		if(existingTag || existingTagSet)
		{
			NSString *setName = [sourceItem displayName];
			
			BOOL usesDefaultDisplayName = 
				[[sourceItem displayName] isEqualTo:[sourceItem defaultDisplayName]];
			
			// Update sourceItem's containedObject (may be a tag or tag set by now)
			NNTagSet *newTagSet;
			if(existingTagSet)
				newTagSet = [NNTagSet setWithTags:[existingTagSet tags] name:setName];
			
			if(tag)
			{
				if(existingTag)
					newTagSet = [NNTagSet setWithTags:[NSArray arrayWithObjects:existingTag, tag, nil] name:setName];
				else
					[newTagSet addTag:tag];
			} else {
				if(existingTag)
				{
					NSMutableArray *newTags = [NSMutableArray arrayWithObject:existingTag];
					[newTags addObjectsFromArray:[tagSet tags]];
					
					newTagSet = [NNTagSet setWithTags:newTags name:setName];
				} else {
					[newTagSet addTags:[tagSet tags]];
				}
			}
			
			[sourceItem setContainedObject:newTagSet];
			
			// Set the right image for a single tag or a tag  set
			[sourceItem setImage:[NSImage imageNamed:@"source-panel-tag-set"]];
			
			// If we were using the default display name before, we'll stick to this
			if(usesDefaultDisplayName)
				setName = [sourceItem defaultDisplayName];
			
			[sourceItem setDisplayName:setName];
			[sourceItem setValue:setName];
		}
		else 
		{
			// Just add the dropped tag as a new item
			
			newItem = [PASourceItem itemWithValue:[tag name] displayName:[tag name]];
			[newItem setContainedObject:tag];
			
			[newItem setImage:[NSImage imageNamed:@"source-panel-tag"]];
			
			[sourceItem addChild:newItem];
		}
	}
	else
	{
		// Insert the dropped tag or set at index idx
		
		NSString *name;
		
		if(tag)
			name = [tag name];
		else
			name = [tagSet name];
		
		newItem = [PASourceItem itemWithValue:name displayName:name];		
		[newItem setContainedObject:draggedObject];
		
		// Set the right image for a single tag or a tag  set
		if(tag || [[tagSet tags] count] == 1)
			[newItem setImage:[NSImage imageNamed:@"source-panel-tag"]];
		else
			[newItem setImage:[NSImage imageNamed:@"source-panel-tag-set"]];
		
		if(idx != -1 &&
		   idx < [[sourceItem children] count])
			[sourceItem insertChild:newItem atIndex:idx];
		else
			[sourceItem addChild:newItem];
		
		// If reordered item, delete the old one
		if([sourceItem hasChildContainingObject:draggedObject])
		{
			for(NSInteger i = 0; i < [[sourceItem children] count]; i++)
			{
				PASourceItem *thisItem = [[sourceItem children] objectAtIndex:i];
				if([[thisItem displayName] isEqualTo:[newItem displayName]] &&
				   thisItem != newItem)
					[sourceItem removeChildAtIndex:i];
			}
		}
	}
	
	// Validate the new name
	[sourceItem validateDisplayName];
	[newItem validateDisplayName];
	
	// Propagate model changes to ui
	id selectedItem = [ov itemAtRow:[ov selectedRow]];
	
	[ov reloadData];
	
	NSInteger newSelectedRow = [ov rowForItem:selectedItem];
	if(newSelectedRow == -1)
		newSelectedRow = [ov rowForItem:newItem];
	
	[ov selectRow:newSelectedRow byExtendingSelection:NO];
	
	// Save favorites
	[[[[NSApplication sharedApplication] delegate] browserController] saveFavorites];
	
	// Delete smart folder if necessary?
	
    return YES;    
}


#pragma mark Misc
- (void)addItem:(PASourceItem *)anItem
{
	[items addObject:anItem];
	
	[sourcePanel reloadData];
}

- (void)addChild:(PASourceItem *)anItem toItem:(PASourceItem *)aParent
{
	[aParent addChild:anItem];
	
	[sourcePanel reloadData];
}

- (void)removeItem:(PASourceItem *)anItem
{
	[items removeObject:anItem];
	
	[sourcePanel reloadData];	
}

- (void)doubleAction:(id)sender
{
	[[[[NSApplication sharedApplication] delegate] browserController] editTagSet:sourcePanel];
}

- (void)triangleClicked:(id)sender
{
	NSDictionary *tag = (NSDictionary *)[sender tag];
	NSString *value = [tag objectForKey:@"value"];
	
	PASourceItem *item = [sourcePanel itemWithValue:value];
	
	if([sourcePanel isItemExpanded:item])
	{
		// Just toggle the item's state
		[sourcePanel collapseItem:item];
		
		// Select ALL ITEMS if no selection
		if([[sourcePanel selectedRowIndexes] count] == 0)
			[sourcePanel selectItemWithValue:@"ALL_ITEMS"];
	} else {
		// If we expand an item, we need to redraw all previously visible rows so that they
		// can correctly (re-)move their subviews
		// NOTE: This is not necessary at the moment, as we have only one single triangle by now
		[sourcePanel expandItem:item];
	}
	
	// Save userDefaults
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSMutableDictionary *sourcePanelDict = [NSMutableDictionary dictionaryWithDictionary:[defaults objectForKey:@"SourcePanel"]];
	NSMutableArray *expandedItems = [NSMutableArray arrayWithArray:(NSArray *)[sourcePanelDict objectForKey:@"ExpandedItems"]];
	
	if([sourcePanel isItemExpanded:item])
		[expandedItems addObject:[item value]];
	else
		[expandedItems removeObject:[item value]];
	
	[sourcePanelDict setObject:expandedItems forKey:@"ExpandedItems"];		
	[defaults setObject:sourcePanelDict forKey:@"SourcePanel"];
	
	// Make source panel the first responder
	[[sourcePanel window] makeFirstResponder:sourcePanel];
}



#pragma mark Accessors
- (NSArray *)items
{
	return items;
}

- (NSArray *)draggedItems
{
	return draggedItems;
}

@end
