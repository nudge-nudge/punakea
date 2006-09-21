//
//  PAResultsMultiItemMatrix.h
//  punakea
//
//  Created by Daniel on 17.04.06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PAResultsMultiItemPlaceholderCell.h"
#import "PAResultsMultiItemThumbnailCell.h"
#import "PAQueryItem.h"


@interface PAResultsMultiItemMatrix : NSMatrix {

	NSArray					*items;
	NSCell					*multiItemCell;
	
	NSCell					*selectedCell;
	NSMutableIndexSet		*selectedIndexes;
	NSMutableArray			*selectedCells;
	
}

- (NSArray *)items;
- (void)setItems:(NSArray *)theItems;

@end
