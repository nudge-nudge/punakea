//
//  ResultsOutlineViewController.h
//  punakea
//
//  Created by Daniel on 04.04.06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PAResultsGroupCell.h"
#import "PAResultsItemCell.h"
#import "PAResultsMultiItem.h"
#import "PAResultsMultiItemCell.h"


@interface ResultsOutlineViewController : NSObject
{
	NSMetadataQuery *query;
	NSOutlineView *outlineView;
}

- (IBAction)doubleAction:(id)sender;

- (NSMetadataQuery *)query;
- (void)setQuery:(NSMetadataQuery *)aQuery;
- (NSOutlineView *)outlineView;
- (void)setOutlineView:(NSOutlineView *)anOutlineView;

@end
