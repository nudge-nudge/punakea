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
	if([[tableColumn identifier] isEqualToString:@"title"]) {
		if([[item class] isEqualTo:[NSMetadataQueryResultGroup class]])
		{
			NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:1];
			[dict setValue:[item value] forKey:@"identifier"];
			return dict;
		}
		if([[item class] isEqualTo:[NSMetadataItem class]])
		{
			NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:3];
			[dict setValue:[item valueForAttribute:(id)kMDItemPath] forKey:@"path"];
			[dict setValue:[item valueForAttribute:(id)kMDItemDisplayName] forKey:@"displayName"];
			[dict setValue:[item valueForAttribute:(id)kMDItemLastUsedDate] forKey:@"lastUsedDate"];
			return dict;
		}
	}
	return @"hi";
}

- (id)outlineView:(NSOutlineView *)outlineView child:(int)index ofItem:(id)item
{
	// TODO: MEM LEAK!!
	
	if(item == nil)	return [[[query groupedResults] objectAtIndex:index] retain];
	
	if([[item class] isEqualTo:[NSMetadataQueryResultGroup class]])
	{
		NSMetadataQueryResultGroup *group = item;
		
		// Child depends on display mode
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		NSDictionary *currentDisplayModes = [[defaults objectForKey:@"Results"] objectForKey:@"CurrentDisplayModes"];
		
		if([[currentDisplayModes objectForKey:[group value]] isEqualToString:@"IconMode"])
		{
			PAResultsMultiItem *multiItem = [[PAResultsMultiItem alloc] init];
			
			// Add items to MultiItem
			int i;
			int startIndex = index * 3;		// TODO: Number of items per row is variable number
			int endIndex = (index + 1) * 3;
			if (endIndex > [group resultCount]) endIndex = [group resultCount];
			
			for(i = startIndex; i < endIndex; i++)
				[multiItem addItem:[group resultAtIndex:i]];
			
			// Set identifier
			NSMutableDictionary *tag = [multiItem tag];
			[tag setObject:[group value] forKey:@"identifier"];			
			
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
			int numberOfColumns = 3;	// TODO: Calculate dynamically
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
	//if([[item class] isEqualTo:[NSMetadataQueryResultGroup class]])
	//	[(PAResultsGroupCell *)cell setGroup:(NSMetadataQueryResultGroup *)item];
	//if([[item class] isEqualTo:[NSMetadataItem class]])
	//	[(PAResultsItemCell *)cell setItem:(NSMetadataItem *)item];
	
	// TODO Replace this by setObjectValue
	if([[item class] isEqualTo:[PAResultsMultiItem class]])
		[(PAResultsMultiItemCell *)cell setItem:(PAResultsMultiItem *)item];
}

- (void)outlineViewItemDidCollapse:(NSNotification *)notification
{
	NSMetadataQueryResultGroup *item = (NSMetadataQueryResultGroup *)[[notification userInfo] objectForKey:@"NSObject"];
	[self removeAllMultiItemSubviewsWithIdentifier:[item value]];
}

- (BOOL)outlineView:(NSOutlineView *)outlineView shouldSelectItem:(id)item
{
	return ([[item class] isEqualTo:[NSMetadataQueryResultGroup class]]) ? NO : YES;
}


#pragma mark Actions
- (void)triangleClicked:(id)sender
{
	NSString *identifier = [(NSDictionary *)[sender tag] objectForKey:@"identifier"];
	id item = [outlineView groupForIdentifier:identifier];
	
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
	NSString *identifier = [(NSDictionary *)[sender tag] objectForKey:@"identifier"];
	NSMetadataQueryResultGroup *item = [outlineView groupForIdentifier:identifier];
	NSString *mode = [[(PAImageButtonCell *)[(PASegmentedImageControl *)sender selectedCell] tag] objectForKey:@"identifier"];
	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	
	// Ignore this click if this state was already active
	if([mode isNotEqualTo:
			  [[[defaults objectForKey:@"Results"]
				          objectForKey:@"CurrentDisplayModes"]
						  objectForKey:[item value]]])
	{
		// Save userDefaults
		NSMutableDictionary *results = [NSMutableDictionary dictionaryWithDictionary:[defaults objectForKey:@"Results"]];
		NSMutableDictionary *currentDisplayModes = [NSMutableDictionary dictionaryWithDictionary:[results objectForKey:@"CurrentDisplayModes"]];
		[currentDisplayModes setObject:mode forKey:[item value]];	
		[results setObject:currentDisplayModes forKey:@"CurrentDisplayModes"];	
		[defaults setObject:results forKey:@"Results"];
		
		// Refresh the group's display
		[outlineView collapseItem:item];
		[outlineView expandItem:item];
	}
}

- (IBAction)doubleAction:(id)sender
{
	NSIndexSet *selectedRowIndexes = [outlineView selectedRowIndexes];	
	unsigned row = [selectedRowIndexes firstIndex];
	while(row != NSNotFound) 
	{
		id item = [outlineView itemAtRow:row];
		
		// TODO: If item is MultiItem, get selected cells and process them
		if([[item class] isEqualTo:[NSMetadataItem class]])
		{
			[[NSWorkspace sharedWorkspace] openFile:[item valueForAttribute:(id)kMDItemPath]];
		}
		
		row = [selectedRowIndexes indexGreaterThanIndex:row];
	}
	
	// TODO: Why are all items deselected after using openFile but not when commenting this line???
}

- (void)removeAllMultiItemSubviewsWithIdentifier:(NSString *)identifier
{
	NSEnumerator *enumerator = [[outlineView subviews] objectEnumerator];
	id anObject;
	while(anObject = [enumerator nextObject])
	{
		if([[anObject class] isEqualTo:[PAResultsMultiItemMatrix class]])
		{
			PAResultsMultiItem *thisItem = [(PAResultsMultiItemMatrix *)anObject item];
			NSString *thisIdentifier = [[thisItem tag] objectForKey:@"identifier"];
			if([identifier isEqualToString:thisIdentifier])
				[anObject removeFromSuperview];
		}
	}
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

- (NSOutlineView *)outlineView
{
	return outlineView;
}

- (void)setOutlineView:(NSOutlineView *)anOutlineView
{
	outlineView = anOutlineView;
}

@end
