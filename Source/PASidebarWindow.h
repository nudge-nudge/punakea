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

#import "NNActiveAppSavingPanel.h"

// setSticky stuff
typedef NSInteger CGSConnectionID;
typedef NSInteger CGSWindowID;
extern CGSConnectionID _CGSDefaultConnection();
extern OSStatus CGSGetWindowTags(const CGSConnectionID cid, const CGSWindowID wid, NSInteger *tags, NSInteger thirtyTwo);
extern OSStatus CGSSetWindowTags(const CGSConnectionID cid, const CGSWindowID wid, NSInteger *tags, NSInteger thirtyTwo);
extern OSStatus CGSClearWindowTags(const CGSConnectionID cid, const CGSWindowID wid, NSInteger *tags, NSInteger thirtyTwo);

typedef enum _PASidebarPosition {
	PASidebarPositionLeft = 0,
	PASidebarPositionRight = 1
} PASidebarPosition;

extern NSString * const SIDEBAR_SHOW_DELAY_KEYPATH;
extern NSString * const SIDEBAR_POSITION_KEYPATH;


@interface PASidebarWindow : NNActiveAppSavingPanel {
	
	BOOL								expanded;
	PASidebarPosition					sidebarPosition;
	
	NSNotificationCenter				*nc;
	NSUserDefaultsController			*defaultsController;
	
	double								sidebarShowDelay;
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

@end