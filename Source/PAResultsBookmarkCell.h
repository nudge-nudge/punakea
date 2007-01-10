//
//  PAResultsBookmarkCell.h
//  punakea
//
//  Created by Daniel on 24.10.06.
//  Copyright 2006 nudge:nudge. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PATagging/PATaggableObject.h"
#import "PAThumbnailManager.h"
#import "NSDateFormatter+FriendlyFormat.h"
#import "NDResourceFork.h"


@interface PAResultsBookmarkCell : NSTextFieldCell {

	PATaggableObject				*item;

}

+ (float)heightOfRow;

@end
