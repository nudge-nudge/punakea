//
//  ResultsOutlineViewController.m
//  punakea
//
//  Created by Daniel on 04.04.06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "ResultsOutlineViewController.h"


@implementation ResultsOutlineViewController

#pragma mark Data Source
- (id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item
{
	if([[item class] isEqualTo:[NSMetadataQueryResultGroup class]]) 
	{
		NSMetadataQueryResultGroup *group = item;
		return [group value];
	} else if([[item class] isEqualTo:[NSMetadataItem class]]) {
		NSMetadataItem *mditem = item;
		return [mditem valueForKey:@"kMDItemDisplayName"];
	}
	
	return nil;
}

- (id)outlineView:(NSOutlineView *)outlineView child:(int)index ofItem:(id)item
{
	// TODO: When do I have to release them?

	if(item == nil) return [[[query groupedResults] objectAtIndex:index] retain];
	
	if([[item class] isEqualTo:[NSMetadataQueryResultGroup class]])
	{
		NSMetadataQueryResultGroup *group = item;
		return [[group resultAtIndex:index] retain];
	}
	
	return nil;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item
{
	return (item == nil) ? YES : ([self outlineView:outlineView numberOfChildrenOfItem:item] != 0);
}

- (int)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item
{
	if(item == nil) return [[query groupedResults] count];

	if([[item class] isEqualTo:[NSMetadataQueryResultGroup class]])
	{
		NSMetadataQueryResultGroup *group = item;
		return [group resultCount];
	}
	
	return 0;
}


#pragma mark Delegate
- (float)outlineView:(NSOutlineView *)outlineView heightOfRowByItem:(id)item
{
	return ([[item class] isEqualTo:[NSMetadataQueryResultGroup class]]) ? 30 : 20;
	
}

- (id)tableColumn:(NSTableColumn *)column inTableView:(NSTableView *)tableView dataCellForRow:(int)row
{
	NSOutlineView *outlineView = tableView;
	id item = [outlineView itemAtRow:row];
	
	NSTextFieldCell *cell = [[[NSTextFieldCell alloc] initTextCell:@"hallo"] autorelease];
	[cell setDrawsBackground:YES];
	
	if([[item class] isEqualTo:[NSMetadataQueryResultGroup class]])
	{
		[cell setBackgroundColor:[NSColor yellowColor]];
	} else {
		[cell setBackgroundColor:[NSColor grayColor]];
	}
	
	return cell;
}

- (void)outlineView:(NSOutlineView *)outlineView
  willDisplayOutlineCell:(id)cell
  forTableColumn:(NSTableColumn *)tableColumn
  item:(id)item
{
	// TODO
}


#pragma mark Accessors
- (NSMetadataQuery *)query
{
	return query;
}

- (void)setQuery:(NSMetadataQuery *)aQuery
{
	query = aQuery;
}

@end
