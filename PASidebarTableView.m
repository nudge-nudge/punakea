#import "PASidebarTableView.h"
#import "PASidebarCell.h"

@implementation PASidebarTableView

- (void)awakeFromNib
{
	id sidebarCell = [[PASidebarCell alloc] init];
	[[self tableColumnWithIdentifier:@"folder"] setDataCell:sidebarCell];
	
	// Needed?
	[self reloadData];
	
	// Copied from an older project... more on this l8r...
	[self registerForDraggedTypes:[NSArray arrayWithObjects:
            NSColorPboardType, NSFilenamesPboardType, nil]];	
}

- (id)_highlightColorForCell:(NSCell *)cell
{
	return nil;
}

- (void)highlightSelectionInClipRect:(NSRect)clipRect
{
	NSImage *backgroundImage;
	NSResponder *firstResponder = [[self window] firstResponder];
	if ( (![firstResponder isKindOfClass:[NSView class]]) ||
		 (![(NSView *)firstResponder isDescendantOf:self]) ||
		 (![[self window] isKeyWindow]) )
	{
		backgroundImage = [NSImage imageNamed:@"sidebarSelectionBackground"];
	} else {
		backgroundImage = [NSImage imageNamed:@"sidebarSelectionBackgroundFocus"];
	}
	
	if(backgroundImage)
	{
		[backgroundImage setScalesWhenResized:YES];
		[backgroundImage setFlipped:YES];
		
		NSRect drawingRect;
		drawingRect = [self rectOfRow:[self selectedRow]];
		drawingRect.size.height -= 2;

		NSSize bgImageSize;
		bgImageSize = drawingRect.size;
		[backgroundImage setSize:bgImageSize];

		NSRect imageRect;
		imageRect.origin = NSZeroPoint;
		imageRect.size = [backgroundImage size];

		if(drawingRect.size.width != 0 && drawingRect.size.height != 0)
			[backgroundImage drawInRect:drawingRect
						   fromRect:imageRect
						  operation:NSCompositeSourceOver
						   fraction:1.0];
	}
}

- (void)drawBackgroundInClipRect:(NSRect)clipRect
{
	[[NSColor whiteColor] set];
	NSRectFill(clipRect);
}
@end
