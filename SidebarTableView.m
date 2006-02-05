#import "SidebarTableView.h"

@implementation SidebarTableView

- (void)awakeFromNib
{
	//id headerCell = [[SidebarHeaderCell alloc] init];
	//[[sidebarHeaderControl setCell:headerCell];
}

- (NSRect)frameOfCellAtColumn:(int)columnIndex row:(int)rowIndex
{
	NSLog(@"frameOfCell column: %d row: %d", columnIndex, rowIndex);
}
@end
