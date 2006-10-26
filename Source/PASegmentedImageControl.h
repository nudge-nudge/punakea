//
//  PASegmentedImageControl.h
//  punakea
//
//  Created by Daniel on 10.04.06.
//  Copyright 2006 nudge:nudge. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PAImageButton.h"


@interface PASegmentedImageControl : NSMatrix {

	NSMutableDictionary *tag;

}

- (void)addSegment:(PAImageButtonCell *)imageButtonCell;

- (NSMutableDictionary *)tag;
- (void)setTag:(NSMutableDictionary *)aTag;

@end
