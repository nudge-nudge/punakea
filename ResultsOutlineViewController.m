//
//  ResultsOutlineViewController.m
//  punakea
//
//  Created by Daniel on 04.04.06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "ResultsOutlineViewController.h"


@interface ResultsOutlineViewController (PrivateAPI)

- (void)triangleClicked:(id)sender;
- (void)segmentedControlClicked:(id)sender;

@end


@implementation ResultsOutlineViewController

#pragma mark Data Source
- (id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item
{
	return @"hi";
}

- (id)outlineView:(NSOutlineView *)outlineView child:(int)index ofItem:(id)item
{
	// TODO: When do I have to release them?

	if(item == nil) return [[[query groupedResults] objectAtIndex:index] retain];
	
	if([[item class] isEqualTo:[NSMetadataQueryResultGroup class]])
	{
		NSMetadataQueryResultGroup *group = item;
		
		// Child depends on display mode
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		NSDictionary *currentDisplayModes = [[defaults objectForKey:@"Results"] objectForKey:@"CurrentDisplayModes"];
		
		if([[currentDisplayModes objectForKey:[group value]] isEqualToString:@"IconMode"])
		{
			PAResultsMultiItem *multiItem = [[PAResultsMultiItem alloc] init];
			return multiItem;
		}
		
		return [[group resultAtIndex:index] retain];
	}
	
	return nil;
}

- (BOOL)outlineView:(NSOutlineView *)ov isItemExpandable:(id)item
{
	return (item == nil) ? YES : ([self outlineView:ov numberOfChildrenOfItem:item] != 0);
}

- (int)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item
{
	if(item == nil) return [[query groupedResults] count];

	if([[item class] isEqualTo:[NSMetadataQueryResultGroup class]])
	{
		NSMetadataQueryResultGroup *group = item;
		
		// Number of childs depends on display mode
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		NSDictionary *currentDisplayModes = [[defaults objectForKey:@"Results"] objectForKey:@"CurrentDisplayModes"];
		
		if([[currentDisplayModes objectForKey:[group value]] isEqualToString:@"IconMode"])
		{
			int numberOfColumns = 2;	// TODO: Calculate dynamically
			int numberOfItemsInGroup = [group resultCount];
			int numberOfRows = numberOfItemsInGroup / numberOfColumns;
			if(numberOfItemsInGroup % numberOfColumns != 0) numberOfRows++;
			
			return numberOfRows;
		}
		
		return [group resultCount];
	}
	
	return 0;
}


#pragma mark Delegate
- (float)outlineView:(NSOutlineView *)outlineView heightOfRowByItem:(id)item
{
	if([[item class] isEqualTo:[NSMetadataQueryResultGroup class]]) return 20;
	if([[item class] isEqualTo:[NSMetadataItem class]]) return 19;
	return 40;	
}

- (id)tableColumn:(NSTableColumn *)column
	  inTableView:(NSTableView *)tableView
   dataCellForRow:(int)row
{
	NSOutlineView *ov = (NSOutlineView *)tableView;
	id item = [ov itemAtRow:row];
	
	if([[item class] isEqualTo:[NSMetadataQueryResultGroup class]])
		return [[[PAResultsGroupCell alloc] initTextCell:@"hallo"] autorelease];
	if([[item class] isEqualTo:[NSMetadataItem class]])
		return [[[PAResultsItemCell alloc] initTextCell:@"hallo"] autorelease];
	
	return [[[PAResultsMultiItemCell alloc] initTextCell:@"hallo"] autorelease];
}

- (void)outlineView:(NSOutlineView *)outlineView
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
	if([[item class] isEqualTo:[NSMetadataQueryResultGroup class]])
		[(PAResultsGroupCell *)cell setGroup:(NSMetadataQueryResultGroup *)item];
	if([[item class] isEqualTo:[NSMetadataItem class]])
		[(PAResultsItemCell *)cell setItem:(NSMetadataItem *)item];
}


#pragma mark Actions
- (void)triangleClicked:(id)sender
{
	id item = [(NSDictionary *)[sender tag] objectForKey:@"group"];
	if([outlineView isItemExpanded:item])
		[outlineView collapseItem:item];
	else
		[outlineView expandItem:item];
	
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

- (void)segmentedControlClicked:(id)sender
{
	NSMetadataQueryResultGroup *item = [[(PASegmentedImageControl *)sender tag] objectForKey:@"group"];
	NSString *mode = [[(PAImageButtonCell *)[(PASegmentedImageControl *)sender selectedCell] tag] objectForKey:@"identifier"];
	
	// Save userDefaults
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSMutableDictionary *results = [NSMutableDictionary dictionaryWithDictionary:[defaults objectForKey:@"Results"]];
	NSMutableDictionary *currentDisplayModes = [NSMutableDictionary dictionaryWithDictionary:[results objectForKey:@"CurrentDisplayModes"]];
	[currentDisplayModes setObject:mode forKey:[item value]];	
	[results setObject:currentDisplayModes forKey:@"CurrentDisplayModes"];	
	[defaults setObject:results forKey:@"Results"];
	
	[outlineView collapseItem:item];
	[outlineView expandItem:item];
}


/*#pragma mark Temp
- (void)updateSubviews
{
	while([[outlineView subviews] count] > 0)
    {
		[[[outlineView subviews] lastObject] removeFromSuperview];
    }
	int i;
	for(i = 0; i < [outlineView numberOfRows]; i++)
	{
		if([outlineView levelForRow:i] == 0)
			[outlineView reloadItem:[outlineView itemAtRow:i]];
	}
}*/


#pragma mark Accessors
- (NSMetadataQuery *)query
{
	return query;
}

- (void)setQuery:(NSMetadataQuery *)aQuery
{
	query = aQuery;
}

- (NSOutlineView *)outlineView
{
	return outlineView;
}

- (void)setOutlineView:(NSOutlineView *)anOutlineView
{
	outlineView = anOutlineView;
}

@end
