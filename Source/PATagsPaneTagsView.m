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

#import "PATagsPaneTagsView.h"

@interface PATagsPaneTagsView (PrivateAPI)

- (NSArray *)initialTags;
- (void)setInitialTags:(NSArray *)someTags;

@end

@implementation PATagsPaneTagsView

#pragma mark Init + Dealloc
- (id)initWithFrame:(NSRect)frame 
{
    self = [super initWithFrame:frame];
    if(self)
	{		
		[self setInitialTags:[NSArray array]];
		
		NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
		[nc addObserver:self 
			   selector:@selector(tagsHaveChanged:)
				   name:NNSelectedTagsHaveChangedNotification
				 object:[tagAutoCompleteController currentCompleteTagsInField]];
		
		[nc addObserver:self
			   selector:@selector(editingDidEnd:)
				   name:NSControlTextDidEndEditingNotification
				 object:tagField];
		
		[nc addObserver:self
			   selector:@selector(editingDidEnd:)
				   name:NSWindowDidResignKeyNotification
				 object:[self window]];
		
		[nc addObserver:self
			   selector:@selector(editingDidEnd:)
				   name:NSWindowDidMiniaturizeNotification
				 object:[self window]];
		
		// call editingDidEnd on app termination to make sure tags are written
		[nc addObserver:self
			   selector:@selector(editingDidEnd:)
				   name:NSApplicationWillTerminateNotification
				 object:[NSApplication sharedApplication]];
    }
    return self;
}

- (void)awakeFromNib{
	[tagAutoCompleteController retain];
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];

	[taggableObjects release];
	[initialTags release];
	[tagAutoCompleteController release];
	
	[super dealloc];
}


#pragma mark Notifications
- (void)tagsHaveChanged:(NSNotification *)notification
{
	// Nothing yet
}

- (void)editingDidEnd:(NSNotification *)aNotification
{
	// DO THE ACTUAL WRITING OF TAGS TO FILES AFTER LOSING FOCUS, OTHERWISE
	// QUERY WILL UPDATE AND TAGS PANE LOSES REFERENCES
	
	// FIXME tagAutoCompleteController is not available when the window is closed!
	// This is just a small workaround - probably best to redesign this and
	// pull the controller out of the nib!
	if (tagAutoCompleteController == nil)
	{
		lcl_log(lcl_cglobal, lcl_vWarning, @"Notification received, but no tagAutoCompleteController available");
		return;
	}
	
	// Tag sets
	NSSet *initialTagSet = [NSSet setWithArray:initialTags];
	NSSet *tagSet = [NSSet setWithArray:[[tagAutoCompleteController currentCompleteTagsInField] selectedTags]];
	
	// Get diff set (tags that have been added or removed)
	NSMutableSet *unchangedSet = [NSMutableSet setWithSet:tagSet];
	[unchangedSet intersectSet:initialTagSet];
	
	NSMutableSet *diffSetToAdd = [NSMutableSet setWithSet:tagSet];
	[diffSetToAdd minusSet:unchangedSet];
	
	NSMutableSet *diffSetToRemove = [NSMutableSet setWithSet:initialTagSet];
	[diffSetToRemove minusSet:unchangedSet];
	
	// Write tags on files
	if ([diffSetToRemove count] > 0)
	{
		for (NNTaggableObject* taggableObject in taggableObjects)
			[taggableObject removeTags:[diffSetToRemove allObjects]];
	}
	
	if([diffSetToAdd count] > 0)
	{
		for(NNTaggableObject *taggableObject in taggableObjects)
			[taggableObject addTags:[diffSetToAdd allObjects]];
	}
}

#pragma mark Accessors
- (NSArray *)tags
{
	return [[tagAutoCompleteController currentCompleteTagsInField] selectedTags];
}

- (void)setTags:(NSArray *)someTags
{
	NNSelectedTags *selTags = [[NNSelectedTags alloc] initWithTags:someTags];
	
	// Update tagField
	[tagAutoCompleteController setCurrentCompleteTagsInField:selTags];
	[tagField setObjectValue:[selTags selectedTags]];
	
	// Update initialTags
	[self setInitialTags:someTags];
	
	[selTags release];
}

- (NSArray *)initialTags
{
	return initialTags;
}

- (void)setInitialTags:(NSArray *)someTags
{
	[initialTags release];
	initialTags = [someTags retain];
}

- (NSString *)label
{
	return [editTagsLabel stringValue];
}

- (void)setLabel:(NSString *)aString;
{
	[editTagsLabel setStringValue:aString];
}

- (NSArray *)taggableObjects
{
	return taggableObjects;
}

- (void)setTaggableObject:(NNTaggableObject *)object
{
	[taggableObjects release];
	taggableObjects = [[NSArray arrayWithObject:object] retain];
}

- (void)setTaggableObjects:(NSArray *)objects
{
	[taggableObjects release];
	taggableObjects = [objects retain];
}

- (NSTokenField *)tagField
{
	return tagField;
}

@end
