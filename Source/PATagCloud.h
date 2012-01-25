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
#import <math.h>
#import "NNTagging/NNTag.h"
#import "NNTagging/NNTags.h"
#import "PATagButton.h"
#import "PADropManager.h"
#import "PATagCloudProtocols.h"

extern NSSize const TAGCLOUD_PADDING;
extern NSSize const TAGCLOUD_SPACING;

/**
displays all tags in dataSource in a nice tag cloud view
 */
@interface PATagCloud : NSView
{
	id<PATagCloudDelegate>			delegate;
	id<PATagCloudDataSource>		dataSource;

	NSMutableDictionary				*tagButtonDict; /**< holds the current controls in the view */
	NNTag							*selectedTag; /**< currently selected tag */
	PATagButton						*activeButton; /**< currently selected tagButton */
	
	NSPoint							pointForNextTagRect; /**< saves the point for the next tag to be displayed */
	NSInteger						tagPosition; /**< holds the position where the new line starts */
	
	NSUserDefaultsController		*userDefaultsController; /**< holds user defaults for tag cloud */
	
	NSString						*displayMessage;
	
	PADropManager					*dropManager;
	
	BOOL							showsDropBorder;	
}

- (id<PATagCloudDataSource>)dataSource;
- (void)setDataSource:(id<PATagCloudDataSource>)ds;
- (id<PATagCloudDelegate>)delegate;
- (void)setDelegate:(id<PATagCloudDelegate>)del;

- (void)reloadData;

- (NNTag*)selectedTag;
- (void)setSelectedTag:(NNTag*)aTag;
- (PATagButton*)activeButton;
- (void)setActiveButton:(PATagButton*)aTag;

- (NSString*)displayMessage;
- (void)setDisplayMessage:(NSString*)message;

- (NSMutableDictionary*)tagButtonDict;
- (void)setTagButtonDict:(NSMutableDictionary*)aDict;
- (void)selectUpperLeftButton;
- (void)selectTag:(NNTag*)tag;
- (void)removeActiveTagButton;

@end
