//
//  PASidebar.h
//  punakea
//
//  Created by Johannes Hoffart on 26.06.06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

extern double const SHOW_DELAY;

typedef enum _PASidebarPosition {
	PASidebarPositionLeft = 0,
	PASidebarPositionRight = 1
} PASidebarPosition;

@interface PASidebarWindow : NSWindow {
	BOOL expanded;
	PASidebarPosition sidebarPosition;
	
	NSNotificationCenter *nc;
}

- (BOOL)isExpanded;
- (void)setExpanded:(BOOL)flag;

- (BOOL)isMoving;
- (void)setMoving:(BOOL)flag;

/** 
should be called after a mouse event inside the sidebar
- checks if it should be shown
*/
- (void)mouseEvent;
	
@end
