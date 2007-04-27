//
//  PAStatusBar.h
//  punakea
//
//  Created by Daniel on 25.04.07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface PAStatusBar : NSView {

	IBOutlet NSSplitView		*resizableSplitView;
	
	NSMutableArray				*items;
	
}

- (void)addItem:(NSView *)anItem;

@end
