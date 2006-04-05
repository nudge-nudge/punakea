/* PAResultsTableColumn */

#import <Cocoa/Cocoa.h>


@interface NSObject (PAResultsTableColumnDelegate)

- (id)tableColumn:(NSTableColumn *)column inTableView:(NSTableView *)tableView dataCellForRow:(int)row;

@end


@interface PAResultsTableColumn : NSTableColumn
{

}

@end
