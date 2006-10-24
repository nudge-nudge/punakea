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


@end
