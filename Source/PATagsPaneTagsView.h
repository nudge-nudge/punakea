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
#import "PAInfoPaneSubview.h"
#import "TagAutoCompleteController.h"
#import "NNTagging/NNSelectedTags.h"
#import "NNTagging/NNTaggableObject.h"

#import "lcl.h"

// TODO actually this is in total violation of the MVC pattern? does that matter? should have its own controller maybe
@interface PATagsPaneTagsView : PAInfoPaneSubview {

	IBOutlet NSTokenField				*tagField;
	IBOutlet NSTextField				*editTagsLabel;
	
	IBOutlet TagAutoCompleteController	*tagAutoCompleteController;
	
	NSArray								*taggableObjects;
	NSArray								*initialTags;						/**< Tags that are present before editing. */
	
}

- (NSArray *)tags;
- (void)setTags:(NSArray *)someTags;
- (NSString *)label;
- (void)setLabel:(NSString *)aString;

- (NSArray *)taggableObjects;
- (void)setTaggableObject:(NNTaggableObject *)object;
- (void)setTaggableObjects:(NSArray *)objects;

- (NSTokenField *)tagField;

@end
