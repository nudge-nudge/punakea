//
//  PASegmentedImageControl.h
//  punakea
//
//  Created by Daniel on 10.04.06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PAImageButton.h"


@interface PASegmentedImageControl : NSMatrix {

	NSMutableDictionary *tag;

}

- (NSMutableDictionary *)tag;

@end
