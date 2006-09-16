//
//  PASidebarTableView.m
//  punakea
//
//  Created by Johannes Hoffart on 26.08.06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "PASidebarTableView.h"


@implementation PASidebarTableView

#pragma mark drag'n'drop
/**
only works if parent window is a PASidebar
 */
- (NSDragOperation)draggingEntered:(id <NSDraggingInfo>)sender 
{
	[[self window] mouseEvent];
	return NSDragOperationNone;
}

/**
only works if parent window is a PASidebar
 */
- (void)draggingExited:(id <NSDraggingInfo>)sender 
{
	[[self window] mouseEvent];
}

- (void)mouseDown:(NSEvent *)theEvent
{
	return;
}

@end
