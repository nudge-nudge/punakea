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
		PASourceItem *sourceItem = [sourceItems objectAtIndex:idx];
		 
		return [sourceItem displayName];
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
	// todo
}

@end
