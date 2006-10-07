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
	PADropManager *dropManager = [PADropManager sharedInstance];
	[self registerForDraggedTypes:[dropManager handledPboardTypes]];
	[dropManager release];
}

- (void)dealloc
{
	[self unregisterDraggedTypes];
	[super dealloc];
}

#pragma mark drawing
- (void)drawRect:(NSRect)rect
{
	// Draw border
	NSRect bounds = [self bounds];	
	
	[[NSColor lightGrayColor] set];
	[NSBezierPath strokeRect:bounds];
}

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
@end
