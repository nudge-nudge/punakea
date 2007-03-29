//
//  PAGenericTableColumn.h
//  punakea
//
//  Created by Daniel on 29.03.07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface NSObject (PAGenericTableColumnDelegate)

- (id)tableColumn:(NSTableColumn *)column inTableView:(NSTableView *)tableView dataCellForRow:(int)row;

@end


@interface PAGenericTableColumn : NSTableColumn {

}

@end
