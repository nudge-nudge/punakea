//
//  PATagManagementViewController.m
//  punakea
//
//  Created by Johannes Hoffart on 13.07.06.
//  Copyright 2006 nudge:nudge. All rights reserved.
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
		tags = [PATags sharedTags];
		
		[self setWorking:NO];
		
		[NSBundle loadNibNamed:@"TagManagementView" owner:self];
	}
	return self;
}

- (void)awakeFromNib
{
	[self setCurrentView:view];
	
	[popularityIndicator setEnabled:NO];
	
	// Add remove button
	NSRect rect;
	rect.origin = NSZeroPoint;
	rect.size.width = 12;
	rect.size.height = 12;

	removeButton = [[PAImageButton alloc] initWithFrame:rect];
	[removeButton setImage:[NSImage imageNamed:@"RemoveRound"] forState:PAOffState];
	[removeButton setImage:[NSImage imageNamed:@"RemoveRoundPressed"] forState:PAOnState];
	[removeButton setState:PAOffState];
	
	[removeButton setAction:@selector(removeOperation:)];
	[removeButton setTarget:self];
	
	[removeButton setToolTip:@"Delete this tag"];

	[removeButtonPlaceholderView addSubview:removeButton]; 
}

- (void)dealloc
{
	// loading from nib causes retain count 1 
	// -> release simpleTagManagementView
	[simpleTagManagementView release];
	
	[currentEditedTag release];
	[removeButton release];
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
	
	if (working)
		[progressIndicator startAnimation:self];
	else
		[progressIndicator stopAnimation:self];
}

- (NSView*)currentView
{
	return currentView;
}

#pragma mark delegate
- (void)controlTextDidChange:(NSNotification *)aNotification
{
	NSDictionary *userInfo = [aNotification userInfo];
	NSText *fieldEditor = [userInfo objectForKey:@"NSFieldEditor"];
	NSString *currentName = [fieldEditor string];
	NSString *editedTagName = [currentEditedTag name];

	if ([tags tagForName:currentName] != nil 
		&& [currentName caseInsensitiveCompare:editedTagName] != NSOrderedSame)
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
	NSString *currentName = [fieldEditor string];
	NSString *editedTagName = [currentEditedTag name];
	
	if ([currentName isWhiteSpace])
	{
		NSAlert *alert = [[[NSAlert alloc] init] autorelease];
		[alert setMessageText:NSLocalizedStringFromTable(@"TAG_WHITESPACE_REQUEST",@"Tags",@"")];
		[alert setInformativeText:NSLocalizedStringFromTable(@"TAG_WHITESPACE_REQUEST_INFO",@"Tags",@"")];
		[alert addButtonWithTitle:NSLocalizedStringFromTable(@"OK",@"Global",@"")];
		
		[alert setAlertStyle:NSInformationalAlertStyle];
		
		[alert beginSheetModalForWindow:[currentView window]
						  modalDelegate:self 
						 didEndSelector:@selector(alertDidEnd:returnCode:contextInfo:)
							contextInfo:nil];
		return NO;
	}
	
	if ([tags tagForName:currentName] == nil 
		|| [currentName caseInsensitiveCompare:editedTagName] == NSOrderedSame)
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
    if (command == @selector(cancelOperation:)) 
	{
		[self cancelOperation:control];
		return YES;
    }
    return NO;
}

- (void)cancelOperation:(id)sender
{
	[sender abortEditing];
}

#pragma mark actions
- (void)handleTagActivation:(PATag*)tag
{
	[self setCurrentEditedTag:tag];
	
	if ([delegate respondsToSelector:@selector(displaySelectedTag:)])
	{
		[delegate displaySelectedTag:tag];
	}
	else
	{
		[NSException raise:NSInternalInconsistencyException
					format:@"delegate invalid"];
	}
}

- (void)loadViewForTag:(PATag*)tag
{
	NSView *sv;
	
	if ([delegate respondsToSelector:@selector(controlledView)])
	{
		sv = [delegate controlledView]; 
	}
	else
	{
		[NSException raise:NSInternalInconsistencyException
					format:@"delegate invalid"];
	}
	
	[currentView removeFromSuperview];
	
	if ([tag isKindOfClass:[PASimpleTag class]])
		[self setCurrentView:simpleTagManagementView];
		
	[sv addSubview:currentView];
	[currentView setFrameSize:[sv frame].size];
	
	// Update ui fields	
	tagNameField = [currentView viewWithTag:1];
	[tagNameField setObjectValue:[tag name]];
	
	NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];	
	[dateFormatter setFormatterBehavior:NSDateFormatterBehavior10_4];
	[dateFormatter setDateStyle:NSDateFormatterLongStyle];	

	[lastClickedField setStringValue:[dateFormatter friendlyStringFromDate:[tag lastClicked]]];
	
	[lastUsedField setStringValue:[dateFormatter friendlyStringFromDate:[tag lastUsed]]];
	
	PATag *currentBestTag = [tags currentBestTag];

	[popularityIndicator setFloatValue:[tag relativeRatingToTag:currentBestTag]];
	
	NSWindow *window = [[self currentView] window];
	[window makeFirstResponder:tagNameField];
}

- (void)removeEditedTag
{	
	[self setWorking:YES];
	
	[tags removeTag:currentEditedTag];
	
	[self setWorking:NO];
	
	[self reset];
}

- (void)renameEditedTagTo:(NSString*)newTagName;
{
	[self setWorking:YES];
	
	if ([delegate respondsToSelector:@selector(removeActiveTagButton)])
	{
		[delegate removeActiveTagButton];
	}
	else
	{
		[NSException raise:NSInternalInconsistencyException
					format:@"delegate invalid"];
	}
	
	[currentEditedTag renameTo:newTagName];

	if ([delegate respondsToSelector:@selector(displaySelectedTag:)])
	{
		[delegate displaySelectedTag:currentEditedTag];
	}
	else
	{
		[NSException raise:NSInternalInconsistencyException
					format:@"delegate invalid"];
	}
		
	[self setWorking:NO];
}

- (IBAction)endTagManagement:(id)sender
{	
	[self reset];
	
	if ([delegate respondsToSelector:@selector(showResults)])
	{
		[delegate showResults];
	}
	else
	{
		[NSException raise:NSInternalInconsistencyException
					format:@"delegate invalid"];
	}
}

- (void)reset
{
	NSView *sv;
	
	if ([delegate respondsToSelector:@selector(controlledView)])
	{
		sv = [delegate controlledView];
	}
	else
	{
		[NSException raise:NSInternalInconsistencyException
					format:@"delegate invalid"];
	}
	
	[delegate resetDisplayTags];
	[currentView removeFromSuperview];
	[self setCurrentView:view];
	[sv addSubview:currentView];
}

#pragma mark alerts
- (void)alertDidEnd:(NSAlert *)alert returnCode:(int)returnCode contextInfo:(void *)contextInfo
{	
	if (contextInfo)
	{
		NSDictionary *conInfo = (NSDictionary*)contextInfo;
	
		NSString *operation = [conInfo objectForKey:PATagManagementOperation];
		
		if ([operation isEqualTo:PATagManagementRemoveOperation] && returnCode == NSAlertFirstButtonReturn)
		{
			[self removeEditedTag];
		}
		else if ([operation isEqualTo:PATagManagementRenameOperation] && returnCode == NSAlertFirstButtonReturn)
		{
			NSString *newTagName = [conInfo objectForKey:@"newTagName"];
			[self renameEditedTagTo:newTagName];
		}
		
		[conInfo release];
	}
}
@end