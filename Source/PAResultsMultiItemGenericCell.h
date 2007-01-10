//
//  PAResultsMultiItemGenericCell.h
//  punakea
//
//  Created by Daniel on 24.10.06.
//  Copyright 2006 nudge:nudge. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PATagging/PATaggableObject.h"
#import "NSDateFormatter+FriendlyFormat.h"

@interface PAResultsMultiItemGenericCell : NSTextFieldCell {

	PATaggableObject			*item;

}

- (id)initTextCell:(PATaggableObject *)anItem;

+ (NSSize)cellSize;				/**< subclass must override */
+ (NSSize)intercellSpacing;		/**< subclass must override */

- (PATaggableObject *)item;
- (void)setItem:(PATaggableObject *)anItem;

@end
