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


@interface PAResultsMultiItemMatrix : NSMatrix {

	NSArray				*items;
	NSCell				*multiItemCell;
	
}

- (NSArray *)items;
- (void)setItems:(NSArray *)theItems;

@end
