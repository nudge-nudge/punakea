//
//  PASidebar.h
//  punakea
//
//  Created by Johannes Hoffart on 26.06.06.
//  Copyright 2006 nudge:nudge. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Carbon/Carbon.h>
#import <ApplicationServices/ApplicationServices.h>

// setSticky stuff
typedef int CGSConnectionID;
typedef int CGSWindowID;
extern CGSConnectionID _CGSDefaultConnection();
extern OSStatus CGSGetWindowTags(const CGSConnectionID cid, const CGSWindowID wid, int *tags, int thirtyTwo);
extern OSStatus CGSSetWindowTags(const CGSConnectionID cid, const CGSWindowID wid, int *tags, int thirtyTwo);
extern OSStatus CGSClearWindowTags(const CGSConnectionID cid, const CGSWindowID wid, int *tags, int thirtyTwo);

extern double const SHOW_DELAY;

typedef enum _PASidebarPosition {
	PASidebarPositionLeft = 0,
	PASidebarPositionRight = 1
} PASidebarPosition;

extern NSString * const SIDEBAR_POSITION_KEYPATH;


@interface PASidebarWindow : NSWindow {
	
	BOOL								expanded;
	PASidebarPosition					sidebarPosition;
	
	NSNotificationCenter				*nc;
	NSUserDefaultsController			*defaultsController;
	
	BOOL								activatesLastFrontApp;
	ProcessSerialNumber					lastFrontProcess;	/**< Indicates the process that was front before showing the sidebar */
	
}

- (BOOL)isExpanded;
- (void)setExpanded:(BOOL)flag;

/** 
should be called after a mouse event inside the sidebar
- checks if it should be shown
*/
- (void)mouseEvent;

/**
should be called if the resolution or display setup changes
 */
- (void)reset;

- (BOOL)activatesLastFrontApp;
- (void)setActivatesLastFrontApp:(BOOL)flag;

@end