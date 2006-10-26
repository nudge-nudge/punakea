//
//  PAResultsItemCell.h
//  punakea
//
//  Created by Daniel on 05.04.06.
//  Copyright 2006 nudge:nudge. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PAQueryItem.h"
#import "PAThumbnailManager.h"
#import "NSDateFormatter+FriendlyFormat.h"


@interface PAResultsItemCell : NSTextFieldCell {

	PAQueryItem				*item;

}

+ (float)heightOfRow;

@end
