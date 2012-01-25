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
#import "PAInfoPaneSubview.h"
#import "NSTextFieldAdditions.h"
#import "NSDateFormatter+FriendlyFormat.h"


@interface PAInfoPaneSingleSelectionView : PAInfoPaneSubview {

	NNFile								*file;
	
	IBOutlet NSTextField				*kindLabel;
	IBOutlet NSTextField				*sizeLabel;
	IBOutlet NSTextField				*createdLabel;
	IBOutlet NSTextField				*modifiedLabel;
	IBOutlet NSTextField				*lastOpenedLabel;
	
	IBOutlet NSTextField				*kindField;
	IBOutlet NSTextField				*sizeField;
	IBOutlet NSTextField				*createdField;
	IBOutlet NSTextField				*modifiedField;
	IBOutlet NSTextField				*lastOpenedField;
	
}

- (NNFile *)file;
- (void)setFile:(NNFile *)aFile;

@end
