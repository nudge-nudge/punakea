#import "PAFileViewTableColumn.h"

@implementation PAFileViewTableColumn

- (id)typeCell
{
   if(!typeCell)
   {
      typeCell = [[NSButtonCell alloc] initTextCell:@"hallo"];
      [typeCell setButtonType:NSSwitchButton];
      [typeCell setControlSize:NSSmallControlSize];
      [typeCell setImagePosition:NSImageOnly];
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
