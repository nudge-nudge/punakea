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


extern NSSize const STATUSBAR_BUTTON_PADDING;
extern NSSize const STATUSBAR_BUTTON_MIN_SIZE;


@interface PAStatusBarButtonCell : NSActionCell {

	NSButtonType		buttonType;
	
	NSImage				*image;
	NSImage				*alternateImage;			/**< Image that will be displayed if user holds down the option key */
	
	BOOL				alternateState;
	
}

- (NSButtonType)buttonType;
- (void)setButtonType:(NSButtonType)aType;

- (NSImage *)image;
- (void)setImage:(NSImage *)anImage;
- (NSImage *)alternateImage;
- (void)setAlternateImage:(NSImage *)anImage;

- (BOOL)alternateState;
- (void)setAlternateState:(BOOL)flag;

@end
