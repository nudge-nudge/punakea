#import "PASidebarCell.h"

@implementation PASidebarCell

- (void)drawInteriorWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
		/*NSString *cellPersonName = [NSString stringWithString:[dict objectForKey:@"Title"]];
		NSString *cellPersonTitle = [NSString stringWithString:[dict objectForKey:@"Artist"]];*/
		NSString *cellPersonTitle = [NSString stringWithString:@"Smart Tag"];
	
		/*NSImage *img = [[NSImage alloc] initWithContentsOfFile:[dict objectForKey:@"Artwork"]];
		[img setScalesWhenResized:YES];
		[img setSize:NSMakeSize(cellFrame.size.height - 2, cellFrame.size.height - 2)];
		[img compositeToPoint:NSMakePoint(cellFrame.origin.x+2, cellFrame.origin.y+cellFrame.size.height-2) operation:NSCompositeSourceOver]; */

		NSMutableDictionary *fontAttributes = [NSMutableDictionary dictionaryWithCapacity:3];
		
					
		if ([self isHighlighted])
		{
			NSShadow *shadow = [[NSShadow alloc] init];
			[shadow setShadowOffset:NSMakeSize(0,-1)];
			[shadow setShadowBlurRadius:1];
			[fontAttributes setObject:shadow forKey:NSShadowAttributeName];
			[fontAttributes setObject:[NSFont boldSystemFontOfSize:11] forKey:NSFontAttributeName];
			[fontAttributes setObject:[NSColor highlightColor] forKey:NSForegroundColorAttributeName];
		} else {
			[fontAttributes setObject:[NSFont systemFontOfSize:11] forKey:NSFontAttributeName];
			[fontAttributes setObject:[NSColor textColor] forKey:NSForegroundColorAttributeName];
		}
		
		/* NSSize fontSize = [cellPersonName sizeWithAttributes:fontAttributes];
		[cellPersonName drawAtPoint:NSMakePoint(cellFrame.origin.x + cellFrame.size.height + 10, cellFrame.origin.y + (fontSize.height / 2)) withAttributes:fontAttributes]; */
		
		NSSize fontSize = [cellPersonTitle sizeWithAttributes:fontAttributes];
		[cellPersonTitle drawAtPoint:NSMakePoint(cellFrame.origin.x + cellFrame.size.height + 30, cellFrame.origin.y + ((cellFrame.size.height - fontSize.height) / 2)) withAttributes:fontAttributes];
}

- (void)setObjectValue:(id <NSCopying>)object
{
	// ?????
	//dict = object;
}
@end
