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
		
		PASourceItem *sourceItem = [PASourceItem itemWithValue:@"LIBRARY" displayName:@"Library"];
		[sourceItems addObject:sourceItem];
		sourceItem = [PASourceItem itemWithValue:@"MANAGETAGS" displayName:@"Manage Tags"];
		[sourceItems addObject:sourceItem];
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

@end
