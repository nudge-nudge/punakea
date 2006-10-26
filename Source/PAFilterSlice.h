//
//  PAFilterSlice.h
//  punakea
//
//  Created by Daniel on 31.07.06.
//  Copyright 2006 nudge:nudge. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PAQuery.h"
#import "PAFilterButton.h"
#import "PAResultsOutlineView.h"
#import "PAResultsViewController.h"

extern NSSize const FILTERSLICE_PADDING;
extern unsigned const FILTERSLICE_BUTTON_SPACING;

@interface PAFilterSlice : NSView {

	IBOutlet PAResultsOutlineView		*outlineView;
	IBOutlet PAResultsViewController	*controller; 	
	
	NSMutableArray						*buttons;

}

@end
