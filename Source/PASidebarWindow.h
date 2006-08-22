//
//  PASidebar.h
//  punakea
//
//  Created by Johannes Hoffart on 26.06.06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

/**
TODO delay
  TODO check if tracking rects are handled correctly
 */
@interface PASidebarWindow : NSWindow {
	NSMutableDictionary *appearance;
	NSNotificationCenter *nc;
	
	BOOL expanded;
}

- (BOOL)isExpanded;
- (void)setExpanded:(BOOL)flag;

- (BOOL)isMoving;
- (void)setMoving:(BOOL)flag;
	
@end
