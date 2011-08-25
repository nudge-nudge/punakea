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
#import "PABrowserViewMainController.h"
#import "NNTagging/NNTags.h"
#import "NNTagging/NNTag.h"
#import "NSDateFormatter+FriendlyFormat.h"
#import "NSString+CharacterSetChecks.h"
#import "PAImageButton.h"

extern NSString * const PATagManagementOperation;
extern NSString * const PATagManagementRenameOperation;
extern NSString * const PATagManagementRemoveOperation;


@interface NSObject (PATagManagementViewControllerAdditions)

- (void)resetDisplayTags;

@end


@interface PATagManagementViewController : PABrowserViewMainController {
	
	IBOutlet NSProgressIndicator	*progressIndicator;
	IBOutlet NSTextField			*tagNameField;
	IBOutlet NSTextField			*lastClickedField;
	IBOutlet NSTextField			*totalClickedField;
	IBOutlet NSTextField			*lastUsedField;
	IBOutlet NSTextField			*totalUsedField;
	IBOutlet NSLevelIndicator		*popularityIndicator;
	IBOutlet NSView					*removeButtonPlaceholderView;
	PAImageButton					*removeButton;
	
	IBOutlet NSView					*simpleTagManagementView;
	
	NNTag							*currentEditedTag;
	
	NNTags							*tags;
	
}

- (NNTag*)currentEditedTag;
- (void)setCurrentEditedTag:(NNTag*)aTag;
- (BOOL)isWorking;

- (IBAction)renameOperation:(id)sender;
- (IBAction)removeOperation:(id)sender;

- (void)removeEditedTag;
- (void)renameEditedTagTo:(NSString*)newTagName;

@end
