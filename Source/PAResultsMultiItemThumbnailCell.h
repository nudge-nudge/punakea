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
//#import "Epeg/EpegWrapperPublic.h"


@interface PAResultsMultiItemThumbnailCell : NSTextFieldCell {
	
	// TODO: Needed?
	NSString				*value;
	
	// TODO: Replace valueDict by PAQueryItem (type and name change)
	NSDictionary			*valueDict;
	
}

+ (NSSize)cellSize;
+ (NSSize)intercellSpacing;

@end
