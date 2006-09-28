//
//  PATagManagementViewController.m
//  punakea
//
//  Created by Johannes Hoffart on 13.07.06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "PATagManagementViewController.h"

NSString * const PATagManagementOperation = @"PATagManagementOperation";
NSString * const PATagManagementRenameOperation = @"PATagManagementRenameOperation";
NSString * const PATagManagementRemoveOperation = @"PATagManagementRemoveOperation";

@interface PATagManagementViewController (PrivateAPI)

- (void)loadViewForTag:(PATag*)tag;

@end

@implementation PATagManagementViewController

#pragma mark init
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

- (void)awakeFromNib
{
	[self setCurrentView:mainView];
}

- (void)dealloc
{
	[currentEditedTag release];
	[super dealloc];
}

#pragma mark accessors
- (PATag*)currentEditedTag
{
	return currentEditedTag;
}

- (void)setCurrentEditedTag:(PATag*)aTag
{
	[aTag retain];
	[currentEditedTag release];
	currentEditedTag = aTag;

	[self loadViewForTag:currentEditedTag];
}

- (BOOL)isWorking
{
	return working;
}

- (void)setWorking:(BOOL)flag
{
	working = flag;
}

- (NSView*)currentView
{
	return currentView;
}

/**
not retained!
 */
- (void)setCurrentView:(NSView*)aView
{
	currentView = aView;
	
	[currentView setNextResponder:self];
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

- (IBAction)renameOperation:(id)sender
{
	NSString *newTagName = [sender stringValue];
	
	if ([newTagName isEqualTo:[currentEditedTag name]])
		return;
	
	NSDictionary *contextInfo = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:PATagManagementRenameOperation,newTagName,nil]
															forKeys:[NSArray arrayWithObjects:PATagManagementOperation,@"newTagName",nil]];
	
	NSAlert *alert = [[[NSAlert alloc] init] autorelease];
	[alert setMessageText:NSLocalizedStringFromTable(@"TAG_RENAME_REQUEST",@"Tags",@"")];
	[alert setInformativeText:NSLocalizedStringFromTable(@"TAG_RENAME_REQUEST_INFO",@"Tags",@"")];
	[alert addButtonWithTitle:NSLocalizedStringFromTable(@"OK",@"Global",@"")];
	[alert addButtonWithTitle:NSLocalizedStringFromTable(@"CANCEL",@"Global",@"")];

	[alert setAlertStyle:NSWarningAlertStyle];
	
	[alert beginSheetModalForWindow:[currentView window]
					  modalDelegate:self 
					 didEndSelector:@selector(alertDidEnd:returnCode:contextInfo:)
						contextInfo:[contextInfo retain]];
}

- (IBAction)removeOperation:(id)sender
{	
	NSDictionary *contextInfo = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:PATagManagementRemoveOperation,nil]
															forKeys:[NSArray arrayWithObjects:PATagManagementOperation,nil]];
	
	NSAlert *alert = [[[NSAlert alloc] init] autorelease];
	[alert setMessageText:NSLocalizedStringFromTable(@"TAG_REMOVE_REQUEST",@"Tags",@"")];
	[alert setInformativeText:NSLocalizedStringFromTable(@"TAG_REMOVE_REQUEST_INFO",@"Tags",@"")];
	[alert addButtonWithTitle:NSLocalizedStringFromTable(@"OK",@"Global",@"")];
	[alert addButtonWithTitle:NSLocalizedStringFromTable(@"CANCEL",@"Global",@"")];

	[alert setAlertStyle:NSWarningAlertStyle];
	
	[alert beginSheetModalForWindow:[currentView window]
					  modalDelegate:self 
					 didEndSelector:@selector(alertDidEnd:returnCode:contextInfo:)
						contextInfo:[contextInfo retain]];
}

- (BOOL)control:(NSControl *)control textView:(NSTextView *)textView doCommandBySelector:(SEL)command
{
    if (command == @selector(cancelOperation:)) {
		[self cancelOperation:control];
		return YES;
    }
    return NO;
}

- (void)cancelOperation:(id)sender
{
	NSLog(@"cancel");
	[sender abortEditing];
}

#pragma mark actions
- (void)handleTagActivation:(PATag*)tag
{
	[self setCurrentEditedTag:tag];
}

- (void)loadViewForTag:(PATag*)tag
{
	NSView *sv = [delegate controlledView]; 
	[currentView removeFromSuperview];	
	
	if ([tag isKindOfClass:[PASimpleTag class]])
		[self setCurrentView:simpleTagManagementView];
		
	[sv addSubview:currentView];
	[currentView setFrameSize:[sv frame].size];
			
	// TODO this connection needs update
	[tagNameField setObjectValue:[currentEditedTag name]];
	NSWindow *window = [[self currentView] window];
	[window makeFirstResponder:tagNameField];
}

- (void)removeEditedTag
{	
	[self setWorking:YES];
	
	[tagger removeTag:currentEditedTag];
	[tags removeTag:currentEditedTag];
	
	[self setWorking:NO];
}

- (void)renameEditedTagTo:(NSString*)newTagName;
{
	[self setWorking:YES];
	
	[tagger renameTag:[currentEditedTag name] toTag:newTagName];
	[currentEditedTag setName:newTagName];

	[self setWorking:NO];
}

#pragma mark alerts
- (void)alertDidEnd:(NSAlert *)alert returnCode:(int)returnCode contextInfo:(void *)contextInfo
{
	NSString *operation = [contextInfo objectForKey:PATagManagementOperation];
	
	if ([operation isEqualTo:PATagManagementRemoveOperation] && returnCode == NSAlertFirstButtonReturn)
	{
		[self removeEditedTag];
	}
	else if ([operation isEqualTo:PATagManagementRenameOperation] && returnCode == NSAlertFirstButtonReturn)
	{
		NSString *newTagName = [contextInfo objectForKey:@"newTagName"];
		[self renameEditedTagTo:newTagName];
	}
	
	[contextInfo release];
}
@end