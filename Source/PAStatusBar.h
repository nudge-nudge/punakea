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
#import "PAStatusBarButton.h"
#import "PAStatusBarLink.h"
#import "PAStatusBarProgressIndicator.h"
#import "PAImageButton.h"
#import "PAResultsOutlineView.h"


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
	NSString					*filePath;
	
	PAImageButton				*gotoButton;
	
}

- (void)addItem:(NSView *)anItem;
- (void)reloadData;

- (id)delegate;
- (void)setDelegate:(id)anObject;

- (void)setAlternateState:(BOOL)flag;

- (void)revealInFinder:(id)sender;

- (NSString *)stringValue;
- (void)setStringValue:(NSString *)value;
- (NSString *)filePath;
- (void)setFilePath:(NSString *)value;

@end
