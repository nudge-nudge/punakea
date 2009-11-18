/* PAResultsTableColumn */

#import <Cocoa/Cocoa.h>


@interface NSObject (PAResultsTableColumnDelegate)

- (id)tableColumn:(NSTableColumn *)column inTableView:(NSTableView *)tableView dataCellForRow:(NSInteger)row;

@end


@interface PAResultsTableColumn : NSTableColumn
{

}

@end
