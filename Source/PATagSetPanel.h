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
#import "PASourceItem.h"
#import "NNTagging/NNTag.h"
#import "TagAutoCompleteController.h"


@interface PATagSetPanel : NSPanel {

	// This outlet is a first draft. For future versions we need to distinguish
	// between simple and smart sets and offer more sophisticated accessors.
	IBOutlet NSTokenField				*tagField;	
	IBOutlet NSTextField				*tagLabel;
	IBOutlet NSButton					*confirmButton;
	
	IBOutlet TagAutoCompleteController	*tagAutoCompleteController;
	
	PASourceItem						*sourceItem;
	
}

- (void)removeAllTags;

- (IBAction)confirmSheet:(id)sender;

- (NSArray *)tags;
- (void)setTags:(NSArray *)someTags;
- (NSTokenField *)tagField;
- (PASourceItem *)sourceItem;
- (void)setSourceItem:(PASourceItem *)anItem;

@end
