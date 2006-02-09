//
//  SidebarDelegateCategory.h
//  punakea
//
//  Created by Daniel on 04.02.06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "SubViewController.h"


@interface SubViewController (SidebarDelegateCategory)
- (int)numberOfRowsInTableView:(NSTableView *)tableView;
- (id)tableView:(NSTableView *)tableView
      objectValueForTableColumn:(NSTableColumn *)tableColumn
      row:(int)row;
@end
