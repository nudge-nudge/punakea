//
//  BrowserViewControllerResultsViewCategory.m
//  punakea
//
//  Created by Daniel on 06.07.06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "BrowserViewControllerResultsViewCategory.h"


@implementation BrowserViewController (ResultsViewCategory)

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
		if([[item class] isEqualTo:[PAResultsMultiItem class]])
		{
			return [item retain];
		}
	}
	return @"hi";
}

- (id)outlineView:(NSOutlineView *)outlineView child:(int)index ofItem:(id)item
{
	// TODO: MEM LEAK!!
		
	if(item == nil)	
		if([query groupingAttributes] && [[query groupingAttributes] count] > 0)
			return [[[query groupedResults] objectAtIndex:index] retain];
		else
			return [[query resultAtIndex:index] retain];
	
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
			
			// TEMP - add ALL result items to MultiItem
			startIndex = 0;
			endIndex = [group resultCount];
			
			// Create this item as dictionary
			for(i = startIndex; i < endIndex; i++)
			{
				NSMetadataItem *currentItem = [group resultAtIndex:i];
				NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:3];
				[dict setValue:[currentItem valueForAttribute:(id)kMDItemPath] forKey:@"path"];
				[dict setValue:[currentItem valueForAttribute:(id)kMDItemDisplayName] forKey:@"displayName"];
				[dict setValue:[currentItem valueForAttribute:(id)kMDItemLastUsedDate] forKey:@"lastUsedDate"];
				[multiItem addItem:dict];
			}
			
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
	if(item == nil) return YES;
	if([query groupingAttributes] && [[query groupingAttributes] count] > 0)
		return ([self outlineView:ov numberOfChildrenOfItem:item] != 0);
	return NO;
}

- (int)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item
{
	if(item == nil)
		if([query groupingAttributes] && [[query groupingAttributes] count] > 0)
			return [[query groupedResults] count];
		else
			return [query resultCount];

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
			
			// TEMP return 1 item only
			//return numberOfRows;
			return 1;
			
		}
		
		return [group resultCount];
	}
	
	return 0;
}


#pragma mark Delegate
- (float)outlineView:(NSOutlineView *)ov heightOfRowByItem:(id)item
{
	if([[item class] isEqualTo:[NSMetadataQueryResultGroup class]]) return 20;
	if([[item class] isEqualTo:[NSMetadataItem class]]) return 19;
	
	// Get height of multi item dynamically	from outlineview
	PAResultsMultiItem *multiItem = item;
	NSSize cellSize = [[multiItem cellClass] cellSize];
	NSSize intercellSpacing = [[multiItem cellClass] intercellSpacing];
	float indentationPerLevel = [outlineView indentationPerLevel];
	NSRect frame = [outlineView frame];

	// TODO: Also use intercellSpacing to calc this (as class method like cellSize)
	int numberOfItemsPerRow = (frame.size.width - indentationPerLevel) / (cellSize.width + intercellSpacing.width);

	int numberOfRows = [multiItem numberOfItems] / numberOfItemsPerRow;
	if([multiItem numberOfItems] % numberOfItemsPerRow > 0) numberOfRows++;

	return numberOfRows * cellSize.height;
}

- (id)tableColumn:(NSTableColumn *)column
	  inTableView:(NSTableView *)tableView
   dataCellForRow:(int)row
{
	NSOutlineView *ov = (NSOutlineView *)tableView;
	id item = [ov itemAtRow:row];
	
	if([[item class] isEqualTo:[NSMetadataQueryResultGroup class]])
		return [[[PAResultsGroupCell alloc] initTextCell:@""] autorelease];
	if([[item class] isEqualTo:[NSMetadataItem class]])
		return [[[PAResultsItemCell alloc] initTextCell:@""] autorelease];
	
	return [[[PAResultsMultiItemCell alloc] initTextCell:@""] autorelease];
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
	/*if([[item class] isEqualTo:[PAResultsMultiItem class]])
		[(PAResultsMultiItemCell *)cell setItem:(PAResultsMultiItem *)item];*/
}

- (void)outlineViewItemDidCollapse:(NSNotification *)notification
{
	NSMetadataQueryResultGroup *item = (NSMetadataQueryResultGroup *)[[notification userInfo] objectForKey:@"NSObject"];
	[self removeAllMultiItemSubviewsWithIdentifier:[item value]];
}

- (BOOL)outlineView:(NSOutlineView *)ov shouldSelectItem:(id)item
{
	// Resign any matrix from being responder
	if(![[item class] isEqualTo:[PAResultsMultiItem class]])
	{
		[outlineView setResponder:nil];
	}

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
	
	// TODO: Why are all items deselected after using openFile but not when commenting that line???
}

- (void)removeAllMultiItemSubviewsWithIdentifier:(NSString *)identifier
{
	NSEnumerator *enumerator = [[outlineView subviews] objectEnumerator];
	id anObject;
	while(anObject = [enumerator nextObject])
	{
		if([[anObject class] isEqualTo:[PAResultsMultiItemMatrix class]])
		{
			PAResultsMultiItem *thisItem = [(PAResultsMultiItemMatrix *)anObject multiItem];
			NSString *thisIdentifier = [[thisItem tag] objectForKey:@"identifier"];
			if([identifier isEqualToString:thisIdentifier])
				[anObject removeFromSuperview];
		}
	}
}

/* TEMP */
- (void)hideAllSubviews
{
	/*NSRect frame = [outlineView frame];
	frame.size = NSMakeSize(50,50);
	frame.origin.x -= 100;
	frame.origin.y -= 100;*/

	NSEnumerator *enumerator = [[outlineView subviews] objectEnumerator];
	id anObject;
	while(anObject = [enumerator nextObject])
	{
		//[anObject setFrame:frame];
		[anObject setHidden:YES];
	}
}

@end
