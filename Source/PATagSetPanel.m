//
//  PATagSetPanel.m
//  punakea
//
//  Created by Daniel on 03.05.07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "PATagSetPanel.h"
#import "NNTagging/NNSelectedTags.h"


@implementation PATagSetPanel

#pragma mark Init + Dealloc
- (void)awakeFromNib
{
	[[tagField cell] setWraps:YES];
	
	NSRect frame = [tagField frame];	
	frame.size.height = 74;
	frame.origin.y = 48;
	
	[tagField setFrame:frame];
}


#pragma mark Misc
- (void)removeAllTags
{
	[tagField setStringValue:@""];
	[[self delegate] setCurrentCompleteTagsInField:[[[NNSelectedTags alloc] init] autorelease]];
}


#pragma mark Accessors
- (NSArray *)tags
{
	return [[[self delegate] currentCompleteTagsInField] selectedTags];
}

- (void)setTags:(NSArray *)someTags
{
	NNSelectedTags *selTags = [[[NNSelectedTags alloc] initWithTags:someTags] autorelease];
	[[self delegate] setCurrentCompleteTagsInField:selTags];
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
}

@end
