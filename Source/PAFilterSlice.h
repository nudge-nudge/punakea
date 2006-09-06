//
//  PAFilterSlice.h
//  punakea
//
//  Created by Daniel on 31.07.06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PAQuery.h"
#import "PAFilterButton.h"
#import "PAResultsOutlineView.h"
#import "BrowserViewController.h"


@interface PAFilterSlice : NSView {

	IBOutlet PAResultsOutlineView		*outlineView;
	IBOutlet BrowserViewController		*controller; 	
	
	NSMutableArray						*buttons;

}

@end
