//
//  PAFilterSlice.h
//  punakea
//
//  Created by Daniel on 31.07.06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "BrowserViewController.h"


@interface PAFilterSlice : NSView {

	IBOutlet NSOutlineView				*outlineView;
	IBOutlet BrowserViewController		*controller; 	
	
	NSMutableArray						*buttons;

}

@end
