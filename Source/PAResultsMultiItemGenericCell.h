//
//  PAResultsMultiItemGenericCell.h
//  punakea
//
//  Created by Daniel on 24.10.06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PAQueryItem.h"
#import "NSDateFormatter+FriendlyFormat.h"

@interface PAResultsMultiItemGenericCell : NSTextFieldCell {

	PAQueryItem			*item;

}

+ (NSSize)cellSize;				/**< subclass must override */
+ (NSSize)intercellSpacing;		/**< subclass must override */

@end
