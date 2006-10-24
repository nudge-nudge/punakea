//
//  PAResultsBookmarkCell.h
//  punakea
//
//  Created by Daniel on 24.10.06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PAQueryItem.h"
#import "PAThumbnailManager.h"
#import "NSDateFormatter+FriendlyFormat.h"
#import "NDResourceFork.h"

@interface PAResultsBookmarkCell : NSTextFieldCell {

	PAQueryItem				*item;

}

+ (float)heightOfRow;

@end
