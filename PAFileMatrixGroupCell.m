#import "PAFileMatrixGroupCell.h"

@implementation PAFileMatrixGroupCell

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
		
	[backgroundImage drawInRect:cellFrame fromRect:imageRect operation:NSCompositeSourceOver fraction:1.0];
					   
	// Draw triangle
	NSImage *triangle = [NSImage imageNamed:@"ExpandedTriangleWhite"];
	[triangle setFlipped:YES];
	imageRect.size = NSMakeSize(16,16);
	[triangle drawAtPoint:NSMakePoint(cellFrame.origin.x + 3, cellFrame.origin.y + 2)
				fromRect:imageRect
			   operation:NSCompositeSourceOver
			    fraction:1.0];
					   
	// Draw text
	NSString *cellTitle = [NSString stringWithString:key];

	NSMutableDictionary *fontAttributes = [NSMutableDictionary dictionaryWithCapacity:3];
	[fontAttributes setObject:[NSColor whiteColor] forKey:NSForegroundColorAttributeName];
	[fontAttributes setObject:[NSFont systemFontOfSize:11] forKey:NSFontAttributeName];
	
	[cellTitle drawAtPoint:NSMakePoint(cellFrame.origin.x + 20, cellFrame.origin.y + 4) withAttributes:fontAttributes];
}

- (NSString*)key
{
	return key;
}

- (void)initTextCell:(NSString*)aText
{
	key = aText;
	[super initTextCell:aText];
}

- (void)dealloc
{
	if(key) { [key release]; }
	[super dealloc];
}
@end
