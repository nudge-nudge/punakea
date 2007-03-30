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
	// Allow only dragging of NNTags
	/*if(![[items objectAtIndex:0] isKindOfClass:[NNTag class]])
		return NO;
	
	NNTag *tag = [items objectAtIndex:0];
	NSString *smartFolder = [PASmartFolder smartFolderFilenameForTag:tag];
	
	NSArray *itemList = [NSArray arrayWithObject:smartFolder];
	
	[pboard declareTypes:[NSArray arrayWithObject:NSFilenamesPboardType] owner:nil];
	[pboard setPropertyList:itemList forType:NSFilenamesPboardType];
	
	return YES;*/
	return NO;
}

- (NSDragOperation)outlineView:(NSOutlineView *)ov 
				  validateDrop:(id <NSDraggingInfo>)info 
				  proposedItem:(id)item 
			proposedChildIndex:(int)idx
{
	// Allow dragging only from PATagButton or an own item
	if(!([[info draggingSource] isMemberOfClass:[PATagButton class]] ||
		 [[info draggingSource] isMemberOfClass:[PASourceItem class]]))
		return NSDragOperationNone;
	
	// retarget to whole outlineview
	//[ov setDropItem:item dropChildIndex:NSOutlineViewDropOnItemIndex];
	
	BOOL isDroppedOnItem = idx==NSOutlineViewDropOnItemIndex;
	
	PASourceItem *sourceItem = (PASourceItem *)item;
	
	if(!([[sourceItem value] isEqualTo:@"FAVORITES"] ||
		 [sourceItem isDescendantOfValue:@"FAVORITES"]))
	{
		// Allow dragging only to FAVORITES group
		return NSDragOperationNone;
	}
	else if([sourceItem isLeaf]) 
	{
		// Deny dragging to leafs
		return NSDragOperationNone;
	}
	else
	{
		// Deny adding duplicates
		// Set drag action to MOVE if source is self (reordering of items)
		
		NNTag *tag = nil;
		if([[info draggingSource] isMemberOfClass:[PATagButton class]])
		{
			PATagButton *tagButton = [info draggingSource];
			tag = [tagButton genericTag];
		} else {
			tag = [info draggingSource];
		}		
		
		if([sourceItem hasChildContainingObject:tag])
		{
		   if([[info draggingSource] isEqualTo:self])
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
	PATagButton *tagButton = [info draggingSource];
	NNTag *tag = [tagButton genericTag];
	
	PASourceItem *sourceItem = (PASourceItem *)item;
	PASourceItem *newItem = [PASourceItem itemWithValue:[tag name] displayName:[tag name]];
	[newItem setContainedObject:tag];
	
	if(idx != -1)
		[sourceItem insertChild:newItem atIndex:idx];
	else
		[sourceItem addChild:newItem];
	
	[ov reloadData];
	
	// TODO: Delete smart folder if necessary
	
    return YES;    
}

@end
