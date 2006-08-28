//
//  PAResultsMultiItemThumbnailCell.h
//  punakea
//
//  Created by Daniel on 17.06.06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "NSBezierPathCategory.h"
#import "Epeg/EpegWrapperPublic.h"


@interface PAResultsMultiItemThumbnailCell : NSTextFieldCell {

	NSString *value;
	NSDictionary *valueDict;
	
}

+ (NSSize)cellSize;
+ (NSSize)intercellSpacing;

@end
