//
//  PATagManagementArrayController.m
//  punakea
//
//  Created by Johannes Hoffart on 26.08.06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "PATagManagementArrayController.h"


@implementation PATagManagementArrayController

- (void)dealloc
{
	if (editedTag) [editedTag release];
	[super dealloc];
}

- (PATag*)editedTag
{
	return editedTag;
}

- (void)setEditedTag:(PATag*)aTag
{
	[aTag retain];
	[editedTag release];
	editedTag = aTag;
}

- (void)objectDidBeginEditing:(id)editor
{
	PATag *tag = [[self selectedObjects] objectAtIndex:0];
	[self setEditedTag:[tag copy]];
}

- (void)objectDidEndEditing:(id)editor
{
	PATag *tag = [[self selectedObjects] objectAtIndex:0];
	[controller renameTag:editedTag toTag:tag];
}

- (void)remove:(id)sender
{
	NSArray *tags = [self selectedObjects];
	[controller removeTagsFromFiles:tags];
	[super remove:sender];
}

@end
