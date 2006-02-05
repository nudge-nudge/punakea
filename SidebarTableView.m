#import "SidebarTableView.h"
#import "SidebarCell.h"

@implementation SidebarTableView

- (void)awakeFromNib
{
	id sidebarCell = [[SidebarCell alloc] init];
	[[self tableColumnWithIdentifier:@"folder"] setDataCell:sidebarCell];
	
	// Needed?
	[self reloadData];
	
	// Copied from an older project... more on this l8r...
	[self registerForDraggedTypes:[NSArray arrayWithObjects:
            NSColorPboardType, NSFilenamesPboardType, nil]];	
}
@end
