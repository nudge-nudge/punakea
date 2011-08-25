// Copyright (c) 2006-2011 nudge:nudge (Johannes Hoffart & Daniel Bär). All rights reserved.
// 
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

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