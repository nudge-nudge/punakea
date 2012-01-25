// Copyright (c) 2006-2012 nudge:nudge (Johannes Hoffart & Daniel Bär). All rights reserved.
// 
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "PATagManagementViewController.h"

NSString * const PATagManagementOperation = @"PATagManagementOperation";
NSString * const PATagManagementRenameOperation = @"PATagManagementRenameOperation";
NSString * const PATagManagementRemoveOperation = @"PATagManagementRemoveOperation";

@interface PATagManagementViewController (PrivateAPI)

- (void)loadViewForTag:(NNTag*)tag;

@end

@implementation PATagManagementViewController

#pragma mark init
- (id)init
{
	if (self = [super init])
	{
		tags = [NNTags sharedTags];
		
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
- (NNTag*)currentEditedTag
{
	return currentEditedTag;
}

- (void)setCurrentEditedTag:(NNTag*)aTag
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
- (void)handleTagActivation:(NNTag*)tag
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

- (void)handleTagActivations:(NSArray*)someTags
{
	// show edit menu for first tag
	[self handleTagActivation:[someTags objectAtIndex:0]];
}

- (void)loadViewForTag:(NNTag*)tag
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
	
	if ([tag isKindOfClass:[NNSimpleTag class]])
		[self setCurrentView:simpleTagManagementView];
		
	[sv addSubview:currentView];
	[currentView setFrameSize:[sv frame].size];
	
	// Update ui fields	
	tagNameField = [currentView viewWithTag:1];
	[tagNameField setObjectValue:[tag name]];
	
	NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];	
	[dateFormatter setFormatterBehavior:NSDateFormatterBehavior10_4];
	[dateFormatter setDateStyle:NSDateFormatterLongStyle];	

	[totalClickedField setStringValue:[NSString stringWithFormat:@"%ld times",[tag clickCount]]];
	[lastClickedField setStringValue:[NSString stringWithFormat:@"(last time: %@)",[dateFormatter friendlyStringFromDate:[tag lastClicked]]]];
	
	[totalUsedField setStringValue:[NSString stringWithFormat:@"%ld times",[tag useCount]]];
	[lastUsedField setStringValue:[NSString stringWithFormat:@"(last time: %@)",[dateFormatter friendlyStringFromDate:[tag lastUsed]]]];
	
	NNTag *currentBestTag = [tags currentBestTag];

	[popularityIndicator setDoubleValue:[tag relativeRatingToTag:currentBestTag]];
	
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
	
	[currentView removeFromSuperview];
	[self setCurrentView:view];
	[sv addSubview:currentView];
}

#pragma mark alerts
- (void)alertDidEnd:(NSAlert *)alert returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo
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