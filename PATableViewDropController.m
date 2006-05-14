//
//  PATableViewDropController.m
//  punakea
//
//  Created by Johannes Hoffart on 07.05.06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "PATableViewDropController.h"


@implementation PATableViewDropController

#pragma mark init + dealloc
- (id)initWithTags:(NSArrayController*)usedTags
{
	if (self = [super init])
	{
		tags = [usedTags retain];
	}
	return self;
}

- (void)dealloc
{
	[tags release];
	[super dealloc];
}

#pragma mark table drag & drop support
- (BOOL)tableView:(NSTableView *)tv writeRowsWithIndexes:(NSIndexSet *)rowIndexes toPasteboard:(NSPasteboard*)pboard 
{
    // No drag support
	return NO;
}

- (NSDragOperation)tableView:(NSTableView*)tv validateDrop:(id <NSDraggingInfo>)info proposedRow:(int)row proposedDropOperation:(NSTableViewDropOperation)op 
{
	if (op == NSTableViewDropOn)
	{
		return NSDragOperationEvery;
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
	PASimpleTag *tag = [[tags arrangedObjects] objectAtIndex:row];
	
	NSPasteboard *pboard = [info draggingPasteboard];
	NSArray *files = [pboard propertyListForType:@"NSFilenamesPboardType"];
	
	PATagger *tagger = [PATagger sharedInstance];
	[tagger addTag:tag ToFiles:files];
    return YES;    
}

@end
