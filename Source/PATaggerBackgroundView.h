//
//  PATaggerBackgroundView.h
//  punakea
//
//  Created by Daniel on 26.10.06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "CTGradient.h"
#import "PAImageButton.h"
#import "TaggerController.h"


@interface PATaggerBackgroundView : NSView {

	IBOutlet TaggerController		*controller;

	PAImageButton					*addButton;
	
}

@end
