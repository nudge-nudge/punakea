/*
 *	DEPRECATED!
 */



//
//  FileOutlineViewDelegateCategory.m
//  Punakea
//
//  Created by Daniel on 09.02.06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "FileOutlineViewDelegateCategory.h"
#import "Controller.h"


@implementation Controller (FileOutlineViewDelegateCategory)

- (void)outlineView:(NSOutlineView *)ov
  willDisplayOutlineCell:(NSButtonCell *)cell
  forTableColumn:(NSTableColumn *)tableColumn
  item:(id)item
{
  [cell setImage:[NSImage imageNamed:@"CollapsedTriangleWhite"]];
  [cell setAlternateImage:[NSImage imageNamed:@"MD0-0-Middle-1"]];
}

@end
