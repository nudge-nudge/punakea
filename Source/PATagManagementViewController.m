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
		query = [[PAQuery alloc] init];
		
		[self setDeleting:NO];
		[self setRenaming:NO];
		
		NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
		sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor,nil];
		[sortDescriptor release];
		
		[NSBundle loadNibNamed:nibName owner:self];
	}
	return self;
}

- (void)dealloc
{
	[newTagName release];
	[sortDescriptors release];
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

- (NSString*)newTagName
{
	return newTagName;
}

- (void)setNewTagName:(NSString*)name
{
	[name retain];
	[newTagName release];
	newTagName = name;
}

#pragma mark delegate
- (void)controlTextDidChange:(NSNotification *)aNotification
{
	NSLog(@"didChange");

	NSString *editedTagName = [[[arrayController selectedObjects] objectAtIndex:0] name];
	
	NSDictionary *userInfo = [aNotification userInfo];
	NSText *fieldEditor = [userInfo objectForKey:@"NSFieldEditor"];
	NSString *currentName = [fieldEditor string];
	
	if ([tags tagForName:currentName] && [currentName isNotEqualTo:editedTagName])
	{
		[fieldEditor setTextColor:[NSColor redColor]];
	} 
	else 
	{
		[fieldEditor setTextColor:[NSColor textColor]];
	}
}

- (BOOL)control:(NSControl *)control textShouldEndEditing:(NSText *)fieldEditor
{
	NSLog(@"shouldEnd");

	[self setNewTagName:[[[arrayController selectedObjects] objectAtIndex:0] name]];
	
	NSString *currentName = [fieldEditor string];
	return !([tags tagForName:currentName] && [currentName isNotEqualTo:newTagName]);
}

- (void)controlTextDidEndEditing:(NSNotification *)aNotification
{
	// TODO
	NSLog(@"didEnd");

	NSDictionary *userInfo = [aNotification userInfo];
	NSString *newName = [[userInfo objectForKey:@"NSFieldEditor"] string];
	
	if ([newName isNotEqualTo:newTagName])
	{
		[self renameTag:[tags tagForName:newTagName] toTagName:newName];
	}
}

#pragma mark actions
- (void)removeTags:(NSArray*)tags
{
	[self setDeleting:YES];
	
	NSEnumerator *tagEnumerator = [tags objectEnumerator];
	PATag *tag;
	
	while (tag = [tagEnumerator nextObject])
	{
		[tagger removeTag:tag];
	}
	
	[self setDeleting:NO];
}

- (void)renameTag:(PATag*)oldTag toTagName:(NSString*)newTagName
{
	[self setRenaming:YES];
	
	[tagger renameTag:[oldTag name] toTag:newTagName];
	
	[self setRenaming:NO];
}
@end