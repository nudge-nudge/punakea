//
//  PAStatusBar.h
//  punakea
//
//  Created by Daniel on 25.04.07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PAStatusBarButton.h"
#import "PAStatusBarProgressIndicator.h"
#import "PAImageButton.h"


@interface NSObject (PAStatusBarDelegate)

- (BOOL)statusBar:(id)sender validateItem:(PAStatusBarButton *)item;

@end


@interface PAStatusBar : NSView
{

	IBOutlet id					delegate;
	
	IBOutlet NSSplitView		*resizableSplitView;
	
	NSRect						gripRect;
	BOOL						gripDragged;
	NSSize						gripDragOffset;
	
	NSMutableArray				*items;
	
	NSString					*stringValue;
	
	PAImageButton				*gotoButton;
	
}

- (void)addItem:(NSView *)anItem;
- (void)reloadData;

- (id)delegate;
- (void)setDelegate:(id)anObject;

- (void)setAlternateState:(BOOL)flag;

- (NSString *)stringValue;
- (void)setStringValue:(NSString *)value;

@end
