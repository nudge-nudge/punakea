//
//  PAResultsBookmarkCell.h
//  punakea
//
//  Created by Daniel on 24.10.06.
//  Copyright 2006 nudge:nudge. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "NNTagging/NNTaggableObject.h"
#import "PAThumbnailManager.h"
#import "NSDateFormatter+FriendlyFormat.h"
#import "FVFinderLabel.h"


@interface PAResultsBookmarkCell : NSTextFieldCell {

	NNFile				*item;

}

+ (CGFloat)heightOfRow;

@end
