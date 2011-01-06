//
//  PAResultsItemCell.h
//  punakea
//
//  Created by Daniel on 05.04.06.
//  Copyright 2006 nudge:nudge. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "NNTagging/NNFile.h"
#import "PAThumbnailManager.h"
#import "NSDateFormatter+FriendlyFormat.h"
#import "FVFinderLabel.h"
#import "NSNumberFormatterAdditions.h"


@interface PAResultsItemCell : NSTextFieldCell {

	NNFile				*item;

}

+ (CGFloat)heightOfRow;

@end
