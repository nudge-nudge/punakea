//
//  SidebarDelegateCategory.m
//  Punakea
//
//  Created by Daniel on 09.02.06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "SidebarDelegateCategory.h"
#import "SubViewController.h"


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
