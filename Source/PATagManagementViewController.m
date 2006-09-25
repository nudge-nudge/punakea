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
		tags = [tagger tags];
		
		[self setWorking:NO];
		
		[NSBundle loadNibNamed:@"TagManagementView" owner:self];
	}
	return self;
}

- (void)dealloc
{
	[currentEditedTag release];
	[super dealloc];
}

#pragma mark accessors
- (id)delegate
{
	return delegate;
}

- (void)setDelegate:(id)anObject
{
	delegate = anObject;
}

- (PATag*)currentEditedTag
{
	return currentEditedTag;
}

- (void)setCurrentEditedTag:(PATag*)aTag
{
	[aTag retain];
	[currentEditedTag release];
	currentEditedTag = aTag;
}

- (BOOL)isWorking
{
	return working;
}

- (void)setWorking:(BOOL)flag
{
	working = flag;
}

#pragma mark delegate
- (void)controlTextDidChange:(NSNotification *)aNotification
{
	NSLog(@"didChange");

	NSDictionary *userInfo = [aNotification userInfo];
	NSText *fieldEditor = [userInfo objectForKey:@"NSFieldEditor"];
	NSString *currentName = [fieldEditor string];
	NSString *editedTagName = [currentEditedTag name];

	NSLog(@"edited: %@, current: %@",editedTagName,currentName);

	// DEBUG
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
	NSString *editedTagName = [currentEditedTag name];
	
	NSLog(@"edited: %@, current: %@",editedTagName,currentName);
	
	if ([tags tagForName:currentName] == nil || [currentName isEqualTo:editedTagName])
		return YES;
	else
		return NO;
}

- (void)controlTextDidEndEditing:(NSNotification *)aNotification
{
	NSLog(@"didEnd");
	
	NSDictionary *userInfo = [aNotification userInfo];
	NSText *fieldEditor = [userInfo objectForKey:@"NSFieldEditor"];
	NSString *currentName = [fieldEditor string];
		
	[self renameTag:currentEditedTag toTagName:currentName];
}

#pragma mark actions
- (void)handleTagActivation:(PATag*)tag
{
	[tagNameField setEnabled:YES];
	[self setCurrentEditedTag:tag];
}

- (IBAction)removeTag:(id)sender
{
	[self setWorking:YES];
	
	[tagger removeTag:currentEditedTag];
	[tags removeTag:currentEditedTag];
	
	[self setWorking:NO];
}

- (void)renameTag:(PATag*)oldTag toTagName:(NSString*)newTagName
{
	[self setWorking:YES];
	
	[tagger renameTag:[oldTag name] toTag:newTagName];
	[currentEditedTag setName:newTagName];

	[self setWorking:NO];
}
@end