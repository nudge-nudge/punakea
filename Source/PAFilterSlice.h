//
//  PAFilterSlice.h
//  punakea
//
//  Created by Daniel on 31.07.06.
//  Copyright 2006 nudge:nudge. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "NNTagging/NNQuery.h"
#import "NNTagging/NNContentTypeTreeQueryFilter.h"

#import "PAFilterButton.h"
#import "PAResultsOutlineView.h"
#import "PAResultsViewController.h"

extern NSSize const FILTERSLICE_PADDING;
extern NSUInteger const FILTERSLICE_BUTTON_SPACING;

@interface PAFilterSlice : NSView {

	IBOutlet PAResultsOutlineView		*outlineView;
	IBOutlet PAResultsViewController	*controller; 	
	
	NSMutableArray						*buttons;
	NSButton							*groupingButton;

}

- (void)buttonClick:(id)sender;

@end
