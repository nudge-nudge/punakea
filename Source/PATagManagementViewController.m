//
//  PATagManagementViewController.m
//  punakea
//
//  Created by Johannes Hoffart on 13.07.06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "PATagManagementViewController.h"


@implementation PATagManagementViewController

- (id)init
{
	if (self = [super init])
	{
		tagger = [PATagger sharedInstance];
		
		[self setDeleting:NO];
		[self setRenaming:NO];
		
		[NSBundle loadNibNamed:@"TagManagementView" owner:self];
	}
	return self;
}

#pragma mark accessors
- (NSView*)simpleTagManagementView
{
	return simpleTagManagementView;
}

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

#pragma mark delegate
- (BOOL)control:(NSControl *)control textShouldBeginEditing:(NSText *)fieldEditor
{
	NSLog(@"shouldBegin");
	
	[self setEditedTagName:[[fieldEditor string] copy]];
	return YES;
}

/*
- (void)controlTextDidChange:(NSNotification *)aNotification
{
	NSLog(@"didChange");

	NSDictionary *userInfo = [aNotification userInfo];
	NSText *fieldEditor = [userInfo objectForKey:@"NSFieldEditor"];
	NSString *currentName = [fieldEditor string];

	NSLog(@"edited: %@, current: %@",editedTagName,currentName);
	
	if ([tags tagForName:currentName] != nil)
	{
		NSLog(@"error: %@",[tags tagForName:currentName]);
	}
	
	if ([tags tagForName:currentName] != nil && [currentName isNotEqualTo:editedTagName])
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

	NSString *currentName = [fieldEditor string];
	
	NSLog(@"edited: %@, current: %@",editedTagName,currentName);
	
	if ([tags tagForName:currentName] == nil)
	{
		[control setStringValue:currentName];
		[control setEnabled:NO];
		[self renameTag:[tags tagForName:editedTagName] toTagName:currentName];
		[control setEnabled:YES];
		return YES;
	}
	else if ([currentName isEqualTo:editedTagName])
	{
		return YES;
	}
	else
	{
		return NO;
	}
}
*/

#pragma mark actions
- (void)handleTagActivation:(PATag*)tag
{
	// TODO
}

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