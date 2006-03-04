/* PAFileViewTableColumn */

#import <Cocoa/Cocoa.h>
#import "PAFileViewHeaderCell.h"

@interface PAFileViewTableColumn : NSTableColumn
{
	PAFileViewHeaderCell* typeCell;
}
@end
