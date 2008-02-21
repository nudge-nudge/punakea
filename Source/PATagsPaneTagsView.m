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
        selectedTags = [[NNSelectedTags alloc] initWithTags:[NSArray array]];
    }
    return self;
}

- (void)dealloc
{
	[selectedTags release];
	
	[super dealloc];
}


#pragma mark Accessors
- (NSArray *)tags
{
	return [selectedTags selectedTags];
}

- (void)setTags:(NSArray *)someTags
{
	NNSelectedTags *selTags = [[NNSelectedTags alloc] initWithTags:someTags];
	
	// Update tagField
	[tagAutoCompleteController setCurrentCompleteTagsInField:selTags];
	[tagField setObjectValue:[selTags selectedTags]];
	
	[selectedTags release];
	selectedTags = selTags;
}

- (NSString *)label
{
	return [editTagsLabel stringValue];
}

- (void)setLabel:(NSString *)aString;
{
	[editTagsLabel setStringValue:aString];
}

- (NSTokenField *)tagField
{
	return tagField;
}

@end
