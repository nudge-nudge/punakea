//
//  PASourcePanelController.m
//  punakea
//
//  Created by Daniel on 28.03.07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "PASourcePanelController.h"


@implementation PASourcePanelController

#pragma mark Init + Dealloc
- (id)init
{
	if (self = [super init])
	{
		// Define Source Items
		sourceItems = [[NSMutableArray alloc] init];
		
		PASourceItem *sourceGroup = [PASourceItem itemWithValue:@"TEST" displayName:@"Test"];
		[sourceGroup setSelectable:NO];
		[sourceGroup setHeading:YES];
		
		PASourceItem *sourceItem = [PASourceItem itemWithValue:@"LIBRARY" displayName:@"Library"];
		[sourceGroup addChild:sourceItem];
		sourceItem = [PASourceItem itemWithValue:@"MANAGETAGS" displayName:@"Manage Tags"];
		[sourceGroup addChild:sourceItem];
		
		[sourceItems addObject:sourceGroup];
		
		sourceItem = [PASourceItem itemWithValue:@"FAVORITES" displayName:@"Favorites"];
		[sourceItem setSelectable:NO];
		[sourceItem setHeading:YES];
		[sourceItems addObject:sourceItem];
	}
	return self;
}

- (void)dealloc
{
	[sourceItems release];
	[super dealloc];
}


#pragma mark Data Source
- (id)          outlineView:(NSOutlineView *)ov 
  objectValueForTableColumn:(NSTableColumn *)tableColumn
					 byItem:(id)item
{
	return item;
}

- (id)outlineView:(NSOutlineView *)ov child:(int)idx ofItem:(id)item
{		
	if(item == nil)
	{
		return [sourceItems objectAtIndex:idx];
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

- (int)outlineView:(NSOutlineView *)ov numberOfChildrenOfItem:(id)item
{
	if(item == nil)
	{
		return [sourceItems count];
	} else if([item isKindOfClass:[PASourceItem class]]) {
		return [[item children] count];
	}
	
	return 0;
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
	NSOutlineView *ov = (NSOutlineView *)[notification object];
	
	id item = [ov itemAtRow:[ov selectedRow]];
	
	if([item isKindOfClass:[PASourceItem class]])
	{		
		PASourceItem *sourceItem = (PASourceItem *)item;
		
		//if([[sourceItem value] isEqualTo:@"LIBRARY"])
			// todo
		//else if([[sourceItem value] isEqualTo:@"MANAGETAGS"])
			// todo
	} else if([item isKindOfClass:[NNTag class]]){

		//[st setSelectedTags:[NSArray arrayWithObject:item]];
		
	}
}

- (id)tableColumn:(NSTableColumn *)column
	  inTableView:(NSTableView *)tableView
   dataCellForRow:(int)row
{
	PASourceItemCell *cell = [[[PASourceItemCell alloc] initTextCell:@""] autorelease];
		
	return cell;
}

- (float)outlineView:(NSOutlineView *)ov heightOfRowByItem:(id)item
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
	[cell setImage:[NSImage imageNamed:@"transparent"]];
	[cell setAlternateImage:[NSImage imageNamed:@"transparent"]];
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
		 writeItems:(NSArray *)items 
	   toPasteboard:(NSPasteboard *)pboard
{
	// Weak temporary reference to draggedItems
	draggedItems = items;
	
	// Currently we only support single selection mode
	PASourceItem *sourceItem = [items objectAtIndex:0];
	
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
			proposedChildIndex:(int)idx
{
	// Allow dragging only from PATagButton or an own item
	if(!([[info draggingSource] isMemberOfClass:[PATagButton class]] ||
		 [info draggingSource] == ov))
		return NSDragOperationNone;
	
	BOOL isDroppedOnItem = idx==NSOutlineViewDropOnItemIndex;
	
	PASourceItem *sourceItem = (PASourceItem *)item;
	
	if(!([[sourceItem value] isEqualTo:@"FAVORITES"] ||
		 [sourceItem isDescendantOfValue:@"FAVORITES"]))
	{
		// Allow dragging only to FAVORITES group
		return NSDragOperationNone;
	}
	
	NNTag			*tag = nil;
	NNTagSet		*tagSet = nil;
	id				draggedObject = nil;
	
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
			
			if([existingTag isEqualTo:tag]) 
			{
				return NSDragOperationNone;
			} else {
				return NSDragOperationCopy;
			}
		} else {
			NNTagSet *existingSet = (NNTagSet *)[sourceItem containedObject];
			
			if([existingSet containsTag:tag]) 
			{
				return NSDragOperationNone;
			} else {
				return NSDragOperationCopy;
			}
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
		 childIndex:(int)idx
{
	BOOL isDroppedOnItem = idx==NSOutlineViewDropOnItemIndex;
	
	NNTag		*tag = nil;
	NNTagSet	*tagSet = nil;
	id			draggedObject = nil;
	
	if([[info draggingSource] isMemberOfClass:[PATagButton class]])
	{
		PATagButton *tagButton = [info draggingSource];
		tag = [tagButton genericTag];
		draggedObject = tag;
	} else {
		// We currently support only single selection
		PASourceItem *draggedItem = [[[[info draggingSource] dataSource] draggedItems] objectAtIndex:0];
		draggedObject = [draggedItem containedObject];
		
		if([draggedObject isKindOfClass:[NNTag class]])
			tag = (NNTag *)draggedObject;
		else
			tagSet = (NNTagSet *)draggedObject;
	}	
	
	PASourceItem		*sourceItem = (PASourceItem *)item;
	PASourceItem		*newItem = nil;
	
	if(isDroppedOnItem)
	{
		if([[sourceItem containedObject] isKindOfClass:[NNTag class]])
		{
			// Convert existing tag to set and add the dropped tag
			
			NNTag *existingTag = (NNTag *)[sourceItem containedObject];
			
			NSString *setName = [existingTag name];
			setName = [setName stringByAppendingString:@", "];
			setName = [setName stringByAppendingString:[tag name]];
					
			NNTagSet *tagSet = [NNTagSet setWithTags:[NSArray arrayWithObjects:existingTag, tag, nil] name:setName];
			
			[sourceItem setContainedObject:tagSet];
			[sourceItem setDisplayName:setName];
			[sourceItem setValue:setName];
		}
		else if ([[sourceItem containedObject] isKindOfClass:[NNTagSet class]])
		{
			// Add the dropped tag to the existing set
			
			NNTagSet *existingTagSet = (NNTagSet *)[sourceItem containedObject];
			
			NSString *setName = [sourceItem displayName];
			setName = [setName stringByAppendingString:@", "];
			setName = [setName stringByAppendingString:[tag name]];
			
			NNTagSet *tagSet = [NNTagSet setWithTags:[existingTagSet tags] name:setName];
			[tagSet addTag:tag];
				
			[sourceItem setContainedObject:tagSet];
			[sourceItem setDisplayName:setName];
			[sourceItem setValue:setName];
		}
		else 
		{
			// Just add the dropped tag as a new item
			
			newItem = [PASourceItem itemWithValue:[tag name] displayName:[tag name]];
			[newItem setContainedObject:tag];
			
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
		
		if(idx != -1 &&
		   idx < [[sourceItem children] count])
			[sourceItem insertChild:newItem atIndex:idx];
		else
			[sourceItem addChild:newItem];
		
		// If reordered item, delete the old one
		if([sourceItem hasChildContainingObject:draggedObject])
		{
			for(int i = 0; i < [[sourceItem children] count]; i++)
			{
				PASourceItem *thisItem = [[sourceItem children] objectAtIndex:i];
				if([[thisItem value] isEqualTo:[newItem value]] &&
				   thisItem != newItem)
					[sourceItem removeChildAtIndex:i];
			}
		}
	}
	
	// Propagate model changes to ui
	id selectedItem = [ov itemAtRow:[ov selectedRow]];
	
	[ov reloadData];
	
	int newSelectedRow = [ov rowForItem:selectedItem];
	if(newSelectedRow == -1)
		newSelectedRow = [ov rowForItem:newItem];
	
	[ov selectRow:newSelectedRow byExtendingSelection:NO];
	
	// TODO: Delete smart folder if necessary
	
    return YES;    
}


#pragma mark Accessors
- (NSArray *)draggedItems
{
	return draggedItems;
}

@end
