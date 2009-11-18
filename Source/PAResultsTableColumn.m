#import "PAResultsTableColumn.h"

@implementation PAResultsTableColumn

- (id)dataCellForRow:(NSInteger)row {
    id delegate = [[self tableView] delegate];
    if ([delegate respondsToSelector:@selector(tableColumn:inTableView:dataCellForRow:)]) {
        return [delegate tableColumn:self inTableView:[self tableView] dataCellForRow:row];
    } else {
        return [super dataCellForRow:row];
    }
}

@end
