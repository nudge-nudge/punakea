//
//  PAResultsMultiItemMatrix.h
//  punakea
//
//  Created by Daniel on 17.04.06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PAResultsMultiItem.h"
#import "PAResultsMultiItemPlaceholderCell.h"


@interface PAResultsMultiItemMatrix : NSMatrix {

	PAResultsMultiItem *multiItem;
	NSCell *multiItemCell;
	
}

- (PAResultsMultiItem *)multiItem;
- (void)setMultiItem:(PAResultsMultiItem *)anItem;

@end
