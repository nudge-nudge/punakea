/*
 *	DEPRECATED!
 */
 
 

#import "PAFileViewTableColumn.h"

@implementation PAFileViewTableColumn

- (id)typeCell
{
   if(!typeCell)
   {
      typeCell = [[PAFileMatrixGroupCell alloc] initTextCell:@"hallo"];
      [typeCell setControlSize:NSSmallControlSize];
   }
   return typeCell;
}

- (void)dealloc
{
   if(typeCell)
      [typeCell release];
   [super release];
}

- (id)dataCellForRow:(int)row
{
	id outlineView = [self tableView];
	int level = [outlineView levelForRow:row];
	
	return (level == 0) ? [self typeCell] : [self dataCell];
}

@end
