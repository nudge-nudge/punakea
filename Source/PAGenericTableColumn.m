//
//  PAGenericTableColumn.m
//  punakea
//
//  Created by Daniel on 29.03.07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "PAGenericTableColumn.h"


@implementation PAGenericTableColumn

- (id)dataCellForRow:(NSInteger)row {
    id delegate = [[self tableView] delegate];
    if ([delegate respondsToSelector:@selector(tableColumn:inTableView:dataCellForRow:)]) {
        return [delegate tableColumn:self inTableView:[self tableView] dataCellForRow:row];
    } else {
        return [super dataCellForRow:row];
    }
}

@end
