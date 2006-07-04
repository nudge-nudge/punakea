//
//  PASidebarContentView.m
//  punakea
//
//  Created by Johannes Hoffart on 26.06.06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "PASidebarContentView.h"


@implementation PASidebarContentView

- (void)awakeFromNib 
{
	[self registerForDraggedTypes:[NSArray arrayWithObjects:NSFilenamesPboardType, nil]];
}

- (void)drawRect:(NSRect)rect 
{
    [super drawRect:rect];
}

#pragma mark drag'n'drop
/**
only works if parent window is a PASidebar
 */
- (NSDragOperation)draggingEntered:(id <NSDraggingInfo>)sender 
{
	NSLog(@"dragEnter");
	[[self window] show];
	return NSDragOperationNone;
}

/**
only works if parent window is a PASidebar
 */
- (void)draggingExited:(id <NSDraggingInfo>)sender 
{
	NSLog(@"dragExit");
	// only send recede if mouse pointer has left the view
	NSPoint mouse = [sender draggingLocation];
	if (!NSPointInRect(mouse,[self bounds]))
	{
		NSLog(@"dragLeft");
		[[self window] recede];
	}
}
@end
