//
//  PAResultsMultiItemCell.h
//  punakea
//
//  Created by Daniel on 15.04.06.
//  Copyright 2006 nudge:nudge. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PAResultsMultiItemMatrix.h"


@interface PAResultsMultiItemCell : NSCell {

	NSMutableArray				*items;
	PAResultsMultiItemMatrix	*matrix;

}

@end
