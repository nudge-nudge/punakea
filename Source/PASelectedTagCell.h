//
//  PASelectedTagCell.h
//  punakea
//
//  Created by Daniel on 23.06.06.
//  Copyright 2006 nudge:nudge. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PAImageButton.h"


@interface PASelectedTagCell : PAImageButtonCell {

	NSDictionary *valueDict;
	
	PAImageButton *contentButton;
	PAImageButton *stopButton;

}

@end
