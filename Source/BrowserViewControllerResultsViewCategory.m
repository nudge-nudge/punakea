//
//  BrowserViewControllerResultsViewCategory.m
//  punakea
//
//  Created by Daniel on 06.07.06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "BrowserViewControllerResultsViewCategory.h"


@implementation PAResultsViewController (ResultsViewCategory)

#pragma mark Actions
- (void)triangleClicked:(id)sender
{
	PAQueryBundle *item = [(NSDictionary *)[sender tag] objectForKey:@"bundle"];

	if([outlineView isItemExpanded:item])
	{
		// Just toggle the item's state
		[outlineView collapseItem:item];
	} else {
		// If we expand an item, we need to redraw all previously visible rows so that they
		// can correctly (re-)move their subviews
		
		NSRange previousVisibleRowsRange = [outlineView rowsInRect:[outlineView visibleRect]];
		
		[outlineView expandItem:item];
		
		int numberOfChildrenOfItem = [[outlineView delegate] outlineView:outlineView numberOfChildrenOfItem:item];
		for(unsigned i = 0; i < previousVisibleRowsRange.length; i++)
		{
			[outlineView drawRow:(numberOfChildrenOfItem + previousVisibleRowsRange.location + i) clipRect:[outlineView bounds]];
		}
	}
	
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

/*- (void)segmentedControlClicked:(id)sender
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
		//NSMutableIndexSet *selectedIndexes = [NSMutableIndexSet indexSet];
		//if([outlineView isItemExpanded:item])
		//{
		//	int row = [outlineView rowForItem:item] + 1;
		//	if([[[outlineView itemAtRow:row] class] isEqualTo:[PAResultsMultiItem class]])
		//	{
		//		
		//	} else {
		//		int level = [outlineView levelForItem:item];
		//		NSIndexSet *indexSet = [outlineView selectedRowIndexes];
		//		while([outlineView levelForRow:row] == level)
		//		{
		//			if([indexSet containsIndex:row])
		//				[selectedIndexes addIndex:row];
		//			row++;
		//		}
		//	}
		//	NSLog(identifier);
		//}
		
		// Refresh the group's display
		[outlineView reloadItem:item reloadChildren:YES];
		[self removeAllMultiItemSubviewsWithIdentifier:[item value]];
		//[outlineView setNeedsDisplay];
		
		// TODO: Restore selection
		//for(int i = 0; i < [selectedIndexes count]; i++)
		//{
		//	
		//}
	}
} */

- (IBAction)doubleAction:(id)sender
{
	NSIndexSet *selectedRowIndexes = [outlineView selectedRowIndexes];	
	unsigned row = [selectedRowIndexes firstIndex];
	while(row != NSNotFound) 
	{
		id item = [outlineView itemAtRow:row];
		
		// TODO: If item is MultiItem, get selected cells and process them
		if([[item class] isEqualTo:[PAQueryItem class]])
		{
			[[NSWorkspace sharedWorkspace] openFile:[item valueForAttribute:(id)kMDItemPath]];
		}
		
		row = [selectedRowIndexes indexGreaterThanIndex:row];
	}
}

- (void)removeAllMultiItemSubviewsWithIdentifier:(NSString *)identifier
{
	NSLog(@"removing subviews commented");
	/*NSEnumerator *enumerator = [[outlineView subviews] objectEnumerator];
	id anObject;
	while(anObject = [enumerator nextObject])
	{
		if([[anObject class] isEqualTo:[PAResultsMultiItemMatrix class]])
		{
			PAResultsMultiItem *theseItems = [(PAResultsMultiItemMatrix *)anObject items];
			NSString *thisIdentifier = [[thisItem tag] objectForKey:@"identifier"];
			if([identifier isEqualToString:thisIdentifier])
				[anObject removeFromSuperview];
		}
	}*/
}

- (void)hideAllSubviews
{
	NSEnumerator *enumerator = [[outlineView subviews] objectEnumerator];
	id anObject;
	while(anObject = [enumerator nextObject])
	{
		[anObject setHidden:YES];
	}
}

@end
