#import "SidebarCell.h"

@implementation SidebarCell

- (void)drawInteriorWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
		/*NSString *cellPersonName = [NSString stringWithString:[dict objectForKey:@"Title"]];
		NSString *cellPersonTitle = [NSString stringWithString:[dict objectForKey:@"Artist"]];*/
		NSString *cellPersonTitle = [NSString stringWithString:@"Steve"];
	
		/*NSImage *img = [[NSImage alloc] initWithContentsOfFile:[dict objectForKey:@"Artwork"]];
		[img setScalesWhenResized:YES];
		[img setSize:NSMakeSize(cellFrame.size.height - 2, cellFrame.size.height - 2)];
		[img compositeToPoint:NSMakePoint(cellFrame.origin.x+2, cellFrame.origin.y+cellFrame.size.height-2) operation:NSCompositeSourceOver]; */

		NSMutableDictionary *fontAttributes = [NSMutableDictionary dictionaryWithCapacity:3];
		[fontAttributes setObject:[NSColor textColor] forKey:NSForegroundColorAttributeName];
		[fontAttributes setObject:[NSFont systemFontOfSize:11] forKey:NSFontAttributeName];
		
		/* NSSize fontSize = [cellPersonName sizeWithAttributes:fontAttributes];
		[cellPersonName drawAtPoint:NSMakePoint(cellFrame.origin.x + cellFrame.size.height + 10, cellFrame.origin.y + (fontSize.height / 2)) withAttributes:fontAttributes]; */
		
		NSSize fontSize = [cellPersonTitle sizeWithAttributes:fontAttributes];
		[cellPersonTitle drawAtPoint:NSMakePoint(cellFrame.origin.x + cellFrame.size.height + fontSize.width + 10, cellFrame.origin.y + (fontSize.height / 2)) withAttributes:fontAttributes];
}

- (void)setObjectValue:(id <NSCopying>)object
{
	// ?????
	//dict = object;
}
@end
