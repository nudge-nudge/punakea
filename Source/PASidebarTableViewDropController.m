//
//  PASidebarTableViewDropController.m
//  punakea
//
//  Created by Johannes Hoffart on 07.05.06.
//  Copyright 2006 nudge:nudge. All rights reserved.
//

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
				 proposedRow:(int)row 
	   proposedDropOperation:(NSTableViewDropOperation)op 
{
	// check if sender should be ignored
	if(![dropManager acceptsSender:[info draggingSource]])
		return NSDragOperationNone;
	
	NSEvent *currentEvent = [NSApp currentEvent];
    unsigned flags = [currentEvent modifierFlags];
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
			  row:(int)row 
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
