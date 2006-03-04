#import "PAFileViewTableColumn.h"

@implementation PAFileViewTableColumn

- (id)dataCellForRow:(int)row
{
	id outlineView = [self tableView];
	int level = [outlineView levelForRow:row];
	
	return (level == 0) ? [self headerCell] : [self dataCell];

@end
