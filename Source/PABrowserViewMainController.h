// Copyright (c) 2006-2012 nudge:nudge (Johannes Hoffart & Daniel Bär). All rights reserved.
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
#import "NNTagging/NNTag.h"
#import "PAViewController.h"

@interface NSObject (PATagManagementViewControllerDelegate)

- (void)displaySelectedTag:(NNTag*)tag;
- (NSView*)controlledView;
- (void)removeActiveTagButton;
- (void)displaySelectedTag:(NNTag*)tag;
- (void)showResults;

@end

/**
abstract class, controller for everything except tagcloud in 
 browserview
 */
@interface PABrowserViewMainController : PAViewController {
	IBOutlet NSView		*currentView;
	
	id					delegate;
	BOOL				working;
	
	NSString			*displayMessage;
}

- (NSView*)currentView;
- (void)setCurrentView:(NSView*)aView;
- (NSResponder*)dedicatedFirstResponder;

/**
abstract, must overwrite
 */
- (void)handleTagActivation:(NNTag*)tag;
- (void)handleTagNegation:(NNTag*)tag;
- (void)handleTagActivations:(NSArray*)someTags;
- (id)delegate;
- (void)setDelegate:(id)anObject;
- (BOOL)isWorking;
- (void)setWorking:(BOOL)flag;
- (NSString*)displayMessage;

/** is called when reset is needed
	(handle escape key reset here)
	default does nothing
	*/
- (void)reset; 

@end