//
//  PATaggerBackgroundView.h
//  punakea
//
//  Created by Daniel on 26.10.06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PAImageButton.h"
#import "TaggerController.h"

@class CTGradient;


@interface PATaggerBackgroundView : NSView {

	IBOutlet TaggerController		*controller;
	
}

@end
