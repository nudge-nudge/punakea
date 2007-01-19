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
	if (op == NSTableViewDropOn)
	{
		return [dropManager performedDragOperation:[info draggingPasteboard]];
	}
	else
	{
		return NSDragOperationNone;
	}
}

- (BOOL)tableView:(NSTableView*)tv 
	   acceptDrop:(id <NSDraggingInfo>)info 
			  row:(int)row 
	dropOperation:(NSTableViewDropOperation)op 
{
	NSArray *objects = [dropManager handleDrop:[info draggingPasteboard]];
	NNTag *tag = [[tags arrangedObjects] objectAtIndex:row];
	
	[objects makeObjectsPerformSelector:@selector(addTag:) withObject:tag];
    return YES;    
}

@end
