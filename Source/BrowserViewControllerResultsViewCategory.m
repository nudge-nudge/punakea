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
	return item;
	
	if([[tableColumn identifier] isEqualToString:@"title"]) {
		if([item isKindOfClass:[NSMetadataQueryResultGroup class]])
		{
			NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:3];
			[dict setValue:[item value] forKey:@"value"];
			return dict;
		}
		if([item isKindOfClass:[NSMetadataItem class]])
		{
			NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:3];
			[dict setValue:[item valueForAttribute:(id)kMDItemPath] forKey:@"path"];
			[dict setValue:[item valueForAttribute:(id)kMDItemDisplayName] forKey:@"displayName"];
			[dict setValue:[item valueForAttribute:(id)kMDItemLastUsedDate] forKey:@"lastUsedDate"];
			return dict;
		}
		if([item isKindOfClass:[PAResultsMultiItem class]])
		{
			return item;
		}
	}
	return @"";
}

- (id)outlineView:(NSOutlineView *)outlineView child:(int)index ofItem:(id)item
{		
	if(item == nil)	
	{
		// We're at top level of our results		
		if([query groupingAttributes] && [[query groupingAttributes] count] > 0)
		{
			//return [[query groupedResults] objectAtIndex:index];
			return [[[query groupedResults] objectAtIndex:index] value];
		} else {
			return [query resultAtIndex:index];
		}
	} else {
		return @"huhu"; //[[item resultAtIndex:index] valueForAttribute:(id)kMDItemDisplayName];
	}
	
	if([item isKindOfClass:[NSMetadataQueryResultGroup class]])
	{
		NSMetadataQueryResultGroup *group = item;
		
		// Child depends on display mode
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		NSDictionary *currentDisplayModes = [[defaults objectForKey:@"Results"] objectForKey:@"CurrentDisplayModes"];
		
		if([[currentDisplayModes objectForKey:[group value]] isEqualToString:@"IconMode"])
		{
			PAResultsMultiItem *multiItem = [[PAResultsMultiItem alloc] init];
			
			// TEMP - add ALL result items to MultiItem
			unsigned startIndex = 0;
			unsigned endIndex = [group resultCount];
			
			// Create this item as dictionary
			for(unsigned i = startIndex; i < endIndex; i++)
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

		return [group resultAtIndex:index];
	}
}

- (BOOL)outlineView:(NSOutlineView *)ov isItemExpandable:(id)item
{
	if(item == nil) return YES;
	return ([ov levelForItem:item] == 0) ? YES : NO;
	
	if([query groupingAttributes] && [[query groupingAttributes] count] > 0)
		return ([self outlineView:ov numberOfChildrenOfItem:item] != 0);
	return NO;
}

- (int)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item
{
	return 0;

	if(item == nil)
	{
		if([query groupingAttributes] && [[query groupingAttributes] count] > 0)
			return [[query groupedResults] count];
		else
			return [query resultCount];
	} else {
		return 1;
	}

	if([item isKindOfClass:[NSMetadataQueryResultGroup class]])
	{
		NSMetadataQueryResultGroup *group = item;
		
		// Number of childs depends on display mode
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		NSDictionary *currentDisplayModes = [[defaults objectForKey:@"Results"] objectForKey:@"CurrentDisplayModes"];
		
		if([[currentDisplayModes objectForKey:[group value]] isEqualToString:@"IconMode"])
			return 1;
		
		return [group resultCount];
	}
	
	return 0;
}

/*- (id)outlineView:(NSOutlineView *)outlineView persistentObjectForItem:(id)item
{
	return [item observedObject];
}*/


#pragma mark Delegate
- (float)outlineView:(NSOutlineView *)ov heightOfRowByItem:(id)item
{		
	return 20;

	if([item isKindOfClass:[NSMetadataQueryResultGroup class]]) return 20.0;
	if([item isKindOfClass:[NSMetadataItem class]]) return 19.0;
	
	// Get height of multi item dynamically	from outlineview
	PAResultsMultiItem *multiItem = item;
	NSSize cellSize = [[multiItem cellClass] cellSize];
	NSSize intercellSpacing = [[multiItem cellClass] intercellSpacing];
	float indentationPerLevel = [outlineView indentationPerLevel];
	float offsetToRightBorder = 20.0;
	NSRect frame = [outlineView frame];

	int numberOfItemsPerRow = (frame.size.width - indentationPerLevel - offsetToRightBorder) /
	                          (cellSize.width + intercellSpacing.width);

	int numberOfRows = [multiItem numberOfItems] / numberOfItemsPerRow;
	if([multiItem numberOfItems] % numberOfItemsPerRow > 0) numberOfRows++;

	return numberOfRows * (cellSize.height + intercellSpacing.height);
}

- (id)tableColumn:(NSTableColumn *)column
	  inTableView:(NSTableView *)tableView
   dataCellForRow:(int)row
{
	return [[[NSTextFieldCell alloc] initTextCell:@""] autorelease];

	NSOutlineView *ov = (NSOutlineView *)tableView;
	id item = [ov itemAtRow:row];
	
	if([item isKindOfClass:[NSMetadataQueryResultGroup class]])
	{
		return [[[NSTextFieldCell alloc] initTextCell:@""] autorelease];
		//return [[[PAResultsGroupCell alloc] initTextCell:@""] autorelease];
	}
	if([item isKindOfClass:[NSMetadataItem class]])
		return [[[PAResultsItemCell alloc] initTextCell:@""] autorelease];
	
	return [[[PAResultsMultiItemCell alloc] initTextCell:@""] autorelease];
}

- (void)outlineView:(NSOutlineView *)outlineView
  willDisplayOutlineCell:(id)cell
	 forTableColumn:(NSTableColumn *)tableColumn
               item:(id)item
{
	// Hide default triangle
	//[cell setImage:[NSImage imageNamed:@"transparent"]];
	//[cell setAlternateImage:[NSImage imageNamed:@"transparent"]];
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
	if(![item isKindOfClass:[PAResultsMultiItem class]])
	{
		[outlineView setResponder:nil];
	}

	return [item isKindOfClass:[NSMetadataQueryResultGroup class]] ? NO : YES;
}


#pragma mark Actions
- (void)triangleClicked:(id)sender
{
	/*NSString *identifier = [(NSDictionary *)[sender tag] objectForKey:@"identifier"];
	id item = [outlineView groupForIdentifier:identifier];
	
	NSLog(@"triangle clicked: %@", [item value]);
	NSLog(@"at row: %d", [outlineView rowForItem:item]);
	
	//if([outlineView isItemExpanded:[outlineView itemAtRow:[outlineView rowForItem:item]]])
	int row = [outlineView rowForItem:item] + 1;
	while([outlineView levelForRow:row++] == [outlineView levelForItem:item])
	{
		[[outlineView itemAtRow:row] retain];
	}
	
	if([outlineView isItemExpanded:item])
		NSLog(@"jo");*/
	//[item setExpanded:NO];
	//[outlineView reloadItem:item reloadChildren:YES];
	
	//else
	//	[outlineView expandItem:item];
	
	// Save userDefaults
	/*NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSMutableDictionary *results = [NSMutableDictionary dictionaryWithDictionary:[defaults objectForKey:@"Results"]];
	NSMutableArray *collapsedGroups = [NSMutableArray arrayWithArray:[results objectForKey:@"CollapsedGroups"]];
	
	if([outlineView isItemExpanded:item])
		[collapsedGroups removeObject:[item value]];
	else
		[collapsedGroups addObject:[item value]];
			
	[results setObject:collapsedGroups forKey:@"CollapsedGroups"];		
	[defaults setObject:results forKey:@"Results"];*/
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
		
		// TODO: Remember selected items
		/*NSMutableIndexSet *selectedIndexes = [NSMutableIndexSet indexSet];
		if([outlineView isItemExpanded:item])
		{
			int row = [outlineView rowForItem:item] + 1;
			if([[[outlineView itemAtRow:row] class] isEqualTo:[PAResultsMultiItem class]])
			{
				
			} else {
				int level = [outlineView levelForItem:item];
				NSIndexSet *indexSet = [outlineView selectedRowIndexes];
				while([outlineView levelForRow:row] == level)
				{
					if([indexSet containsIndex:row])
						[selectedIndexes addIndex:row];
					row++;
				}
			}
			NSLog(identifier);
		}*/
		
		// Refresh the group's display
		[outlineView reloadItem:item reloadChildren:YES];
		[self removeAllMultiItemSubviewsWithIdentifier:[item value]];
		//[outlineView setNeedsDisplay];
		
		// TODO: Restore selection
		/*for(int i = 0; i < [selectedIndexes count]; i++)
		{
			
		}*/
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
