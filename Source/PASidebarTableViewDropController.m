// Copyright (c) 2006-2011 nudge:nudge (Johannes Hoffart & Daniel Bär). All rights reserved.
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

#import "PASidebarTableViewDropController.h"


@implementation PASidebarTableViewDropController

#pragma mark init + dealloc
- (id)initWithTags:(NSArrayController*)usedTags
{
	if (self = [super init])
	{
		tags = [usedTags retain];
		dropManager = [PADropManager sharedInstance];
	}
	return self;
}

- (void)dealloc
{
	[tags release];
	[super dealloc];
}

#pragma mark table drag & drop support
- (BOOL)tableView:(NSTableView *)tv 
writeRowsWithIndexes:(NSIndexSet *)rowIndexes 
	 toPasteboard:(NSPasteboard*)pboard 
{
    // No drag support
	return NO;
}

- (NSDragOperation)tableView:(NSTableView*)tv 
				validateDrop:(id <NSDraggingInfo>)info 
				 proposedRow:(NSInteger)row 
	   proposedDropOperation:(NSTableViewDropOperation)op 
{
	// check if sender should be ignored
	if(![dropManager acceptsSender:[info draggingSource]])
		return NSDragOperationNone;
	
	NSEvent *currentEvent = [NSApp currentEvent];
    NSUInteger flags = [currentEvent modifierFlags];
    if (flags & NSAlternateKeyMask)
		[dropManager setAlternateState:YES];
	else 
		[dropManager setAlternateState:NO];
	
	
	if (op == NSTableViewDropOn)
		return [dropManager performedDragOperation:[info draggingPasteboard]];
	else
		return NSDragOperationNone;
}

- (BOOL)tableView:(NSTableView*)tv 
	   acceptDrop:(id <NSDraggingInfo>)info 
			  row:(NSInteger)row 
	dropOperation:(NSTableViewDropOperation)op 
{
	NSArray *objects = [dropManager handleDrop:[info draggingPasteboard]];
	NNTag *tag = [[tags arrangedObjects] objectAtIndex:row];
	
	// If dropManager is in alternateState, set manageFiles flag on each object
	
	BOOL alternateState = [dropManager alternateState];
	
	if(alternateState)
	{		
		NSEnumerator *e = [objects objectEnumerator];
		NNTaggableObject *object;
		
		while(object = [e nextObject])
		{
			BOOL theDefault = [[NSUserDefaults standardUserDefaults] boolForKey:@"ManageFiles.ManagedFolder.Enabled"];
			
			if([[object tags] count] > 0)
			{
				BOOL newFlag = !theDefault;
				[object setShouldManageFiles:newFlag];
			}
		}
	}
	
	// Perform action addTags:
	[objects makeObjectsPerformSelector:@selector(addTag:) withObject:tag];
	
	// Now switch back to automatic management 
	if(alternateState)
	{		
		NSEnumerator *e = [objects objectEnumerator];
		NNTaggableObject *object;
		
		while(object = [e nextObject])
		{	
			[object setShouldManageFilesAutomatically:YES];
		}
	}
	
    return YES;    
}

@end
