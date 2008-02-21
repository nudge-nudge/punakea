//
//  PATagSetPanel.m
//  punakea
//
//  Created by Daniel on 03.05.07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

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
