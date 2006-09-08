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
	PADropManager *dropManager = [[PADropManager alloc] init];
	[self registerForDraggedTypes:[dropManager handledPboardTypes]];
	[dropManager release];
}

- (void)dealloc
{
	[self unregisterDraggedTypes];
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
