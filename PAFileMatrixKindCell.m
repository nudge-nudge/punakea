#import "PAFileMatrixHeaderCell.h"

@implementation PAFileMatrixHeaderCell

/*- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
	
}*/

- (void)drawInteriorWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{	
	// Draw background
	NSImage *backgroundImage = [NSImage imageNamed:@"MD0-0-Middle-1"];
	[backgroundImage setFlipped:YES];
	[backgroundImage setScalesWhenResized:YES];
	
	NSRect imageRect;
	imageRect.origin = NSZeroPoint;
	imageRect.size = [backgroundImage size];
		
	[backgroundImage drawInRect:cellFrame
					   fromRect:imageRect
					  operation:NSCompositeSourceOver
					   fraction:1.0];
					   
	// Draw text
	NSString *cellTitle = [NSString stringWithString:text];

	NSMutableDictionary *fontAttributes = [NSMutableDictionary dictionaryWithCapacity:3];
	[fontAttributes setObject:[NSColor textColor] forKey:NSForegroundColorAttributeName];
	[fontAttributes setObject:[NSFont systemFontOfSize:11] forKey:NSFontAttributeName];
	
	[cellTitle drawAtPoint:NSMakePoint(cellFrame.origin.x + 10, cellFrame.origin.y + 2) withAttributes:fontAttributes];
}

- (void)initTextCell:(NSString*)aText
{
	text = aText;
}

@end
