//
//  PATagsPaneTagsView.m
//  punakea
//
//  Created by Daniel on 21.02.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "PATagsPaneTagsView.h"


@implementation PATagsPaneTagsView

#pragma mark Init + Dealloc
- (id)initWithFrame:(NSRect)frame 
{
    self = [super initWithFrame:frame];
    if(self)
	{		
		initialTags = [[NSArray alloc] init];
		
		NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
		[nc addObserver:self 
			   selector:@selector(tagsHaveChanged:)
				   name:NNSelectedTagsHaveChangedNotification
				 object:[tagAutoCompleteController currentCompleteTagsInField]];
		
		[nc addObserver:self
			   selector:@selector(editingDidEnd:)
				   name:NSControlTextDidEndEditingNotification
				 object:tagField];
    }
    return self;
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	[taggableObjects release];
	[initialTags release];
	
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
	if([diffSetToAdd count] > 0 || [diffSetToRemove count] > 0)
	{
		for(NNTaggableObject *taggableObject in taggableObjects)
		{
			[taggableObject removeTags:[diffSetToRemove allObjects]];
			[taggableObject addTags:[diffSetToAdd allObjects]];
		}
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
	initialTags = [someTags retain];
	
	[selTags release];
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
