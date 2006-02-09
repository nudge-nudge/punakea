//
//  PASidebarDelegateCategory.m
//  punakea
//
//  Created by Daniel on 04.02.06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "SidebarDelegateCategory.h"


@implementation SubViewController (SidebarDelegateCategory)
- (int)numberOfRowsInTableView:(NSTableView *)tableView
{
    return 4;
}

- (id)tableView:(NSTableView *)tableView
      objectValueForTableColumn:(NSTableColumn *)tableColumn
      row:(int)row
{
	return @"Steve";
}
@end
