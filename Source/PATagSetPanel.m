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

#import "PATagSetPanel.h"
#import "NNTagging/NNSelectedTags.h"


@interface PATagSetPanel (PrivateAPI)

- (void)validateConfirmButton;

@end


@implementation PATagSetPanel

#pragma mark Init + Dealloc
- (void)awakeFromNib
{
	[[tagField cell] setWraps:YES];
	
	NSRect frame = [tagField frame];	
	frame.size.height = 74;
	frame.origin.y = 48;
	
	[tagField setFrame:frame];
	
	[tagLabel setStringValue:NSLocalizedStringFromTable(@"TAGSETPANEL_ADD_TAG_SET_LABEL", @"Global", nil)];
	
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	[nc addObserver:self 
		   selector:@selector(tagsHaveChanged:)
		       name:NNSelectedTagsHaveChangedNotification
		     object:nil];
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	[super dealloc];
}


#pragma mark Misc
- (void)removeAllTags
{
	[tagField setStringValue:@""];
	[tagAutoCompleteController setCurrentCompleteTagsInField:[[[NNSelectedTags alloc] init] autorelease]];
	
	[self validateConfirmButton];
}

- (void)validateConfirmButton
{
	if(!confirmButton)
		return;
	
	[confirmButton setEnabled:([[tagAutoCompleteController currentCompleteTagsInField] count] > 0)];
}


#pragma mark Notifications
- (void)tagsHaveChanged:(NSNotification *)notification
{
	[self validateConfirmButton];
}


#pragma mark Accessors
- (NSArray *)tags
{
	return [[tagAutoCompleteController currentCompleteTagsInField] selectedTags];
}

- (void)setTags:(NSArray *)someTags
{
	[self removeAllTags];
	
	NNSelectedTags *selTags = [[[NNSelectedTags alloc] initWithTags:someTags] autorelease];
	
	// Update tagField
	[tagAutoCompleteController setCurrentCompleteTagsInField:selTags];
	[tagField setObjectValue:[selTags selectedTags]];
	[self validateConfirmButton];
	
	// Move cursor to end
	[tagField selectText:self];
}

- (NSTokenField *)tagField
{
	return tagField;
}

- (PASourceItem *)sourceItem
{
	return sourceItem;
}

- (void)setSourceItem:(PASourceItem *)anItem
{
	[sourceItem release];
	sourceItem = [anItem retain];
	
	// Update tag label
	if(anItem)
		[tagLabel setStringValue:NSLocalizedStringFromTable(@"TAGSETPANEL_EDIT_TAG_SET_LABEL", @"Global", nil)];
	else
		[tagLabel setStringValue:NSLocalizedStringFromTable(@"TAGSETPANEL_ADD_TAG_SET_LABEL", @"Global", nil)];
}

@end
