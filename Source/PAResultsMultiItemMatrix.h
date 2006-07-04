//
//  PAResultsMultiItemMatrix.h
//  punakea
//
//  Created by Daniel on 17.04.06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PAResultsMultiItem.h"
#import "PASegmentedImageControl.h"
#import "PAResultsMultiItemThumbnailCell.h"


@interface PAResultsMultiItemMatrix : NSMatrix {

	PAResultsMultiItem *item;

}

- (PAResultsMultiItem *)item;
- (void)setItem:(PAResultsMultiItem *)anItem;

@end
