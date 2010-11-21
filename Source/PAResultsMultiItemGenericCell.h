//
//  PAResultsMultiItemGenericCell.h
//  punakea
//
//  Created by Daniel on 24.10.06.
//  Copyright 2006 nudge:nudge. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "NNTagging/NNTaggableObject.h"
#import "NSDateFormatter+FriendlyFormat.h"

@interface PAResultsMultiItemGenericCell : NSTextFieldCell {

	NNFile			*item;

}

- (id)initTextCell:(NNTaggableObject *)anItem;

+ (NSSize)cellSize;				/**< subclass must override */
+ (NSSize)intercellSpacing;		/**< subclass must override */

- (NNFile *)item;
- (void)setItem:(NNFile *)anItem;

@end
