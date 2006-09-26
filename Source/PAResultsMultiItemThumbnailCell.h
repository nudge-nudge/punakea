//
//  PAResultsMultiItemThumbnailCell.h
//  punakea
//
//  Created by Daniel on 17.06.06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PAThumbnailManager.h"
#import "NSBezierPathCategory.h"
#import "PAQueryItem.h"


@interface PAResultsMultiItemThumbnailCell : NSTextFieldCell {

	PAQueryItem			*item;
	
}

+ (NSSize)cellSize;
+ (NSSize)intercellSpacing;

@end
