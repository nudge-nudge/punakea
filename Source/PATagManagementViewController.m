//
//  PATagManagementViewController.m
//  punakea
//
//  Created by Johannes Hoffart on 13.07.06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "PATagManagementViewController.h"


@implementation PATagManagementViewController

- (id)initWithNibName:(NSString*)nibName
{
	if (self = [super init])
	{
		tagger = [PATagger sharedInstance];
		tags = [tagger tags];
		
		[self setDisplayTags:[[tags tagArray] mutableCopy]];
		[self sortDisplayTags];
		
		query = [[PAQuery alloc] init];
		
		[self setDeleting:NO];
		[self setRenaming:NO];
		
		nc = [NSNotificationCenter defaultCenter];
		[nc addObserver:self selector:@selector(tagsHaveChanged:) name:@"PATagsHaveChanged" object:tags];
		
		//TODO this stuff should be in the superclass!
		[NSBundle loadNibNamed:nibName owner:self];
	}
	return self;
}

- (void)dealloc
{
	[nc removeObserver:self];
	[displayTags release];
	[query release];
	[super dealloc];
}

#pragma mark accessors
- (BOOL)isDeleting
{
	return deleting;
}

- (void)setDeleting:(BOOL)flag
{
	deleting = flag;
}

- (BOOL)isRenaming
{
	return renaming;
}

- (void)setRenaming:(BOOL)flag
{
	renaming = flag;
}

- (NSMutableArray*)displayTags
{
	return displayTags;
}

- (void)setDisplayTags:(NSMutableArray*)someTags
{
	[displayTags release];
	[someTags retain];
	displayTags = someTags;
}

- (void)sortDisplayTags
{
	[self sortDisplayTags:YES];
}

- (void)sortDisplayTags:(BOOL)ascending
{
	//nameSortDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"name" ascending:ascending];
	//[displayTags sortUsingDescriptors:[NSArray arrayWithObject:nameSortDescriptor]];
}

#pragma mark notifications
- (void)tagsHaveChanged:(NSNotification*)notification
{
	NSDictionary *userInfo = [notification userInfo];
	PATagChangeOperation changeOperation = [[userInfo objectForKey:@"PATagChangeOperation"] intValue];
	
	if (changeOperation == PATagAddOperation)
	{
		PATag *tag = [userInfo objectForKey:@"tag"];
		[displayTags addObject:tag];
		[tableView reloadData];
	}
}

#pragma mark actions
- (IBAction)removeTag:(id)sender
{
	[self setDeleting:YES];
	
	NSIndexSet *indexes = [tableView selectedRowIndexes];
	NSArray *selectedTags = [displayTags objectsAtIndexes:indexes];
	[displayTags removeObjectsAtIndexes:indexes];
	[tableView reloadData];
	
	NSEnumerator *selectedTagsEnumerator = [selectedTags objectEnumerator];
	PATag *tag;
	
	while (tag = [selectedTagsEnumerator nextObject])
	{
		[tagger removeTag:tag];
		[tags removeTag:tag];
	}
	
	[self setDeleting:NO];
}

#pragma mark text delegate
- (BOOL)control:(NSControl *)control textShouldEndEditing:(NSText *)fieldEditor
{
	PATag *tag = [tags tagForName:[fieldEditor string]];
	
	if (tag)
	{
		// there already is a tag with this name
		return false;
	}
	else
	{
		return true;
	}
}

- (void)tableView:(NSTableView *)aTableView 
   setObjectValue:(id)anObject 
   forTableColumn:(NSTableColumn *)aTableColumn 
			  row:(int)rowIndex

{
	PATag *oldTag = [displayTags objectAtIndex:rowIndex];
	PATag *newTag = [tagger createTagForName:anObject];

	if ([[oldTag name] isEqualToString:[newTag name]])
	{
		return;
	}
	
	[self setRenaming:YES];
	
	[tagger renameTag:oldTag toTag:newTag];
	[tags removeTag:oldTag];
	[displayTags replaceObjectAtIndex:rowIndex withObject:newTag];	
	
	[self setRenaming:NO];
}

@end