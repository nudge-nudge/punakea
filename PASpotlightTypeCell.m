#import "PASpotlightTypeCell.h"

@implementation PASpotlightTypeCell

- (void)drawInteriorWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
	NSString *cellTitle = [NSString stringWithString:text];

	NSMutableDictionary *fontAttributes = [NSMutableDictionary dictionaryWithCapacity:3];
	[fontAttributes setObject:[NSColor textColor] forKey:NSForegroundColorAttributeName];
	[fontAttributes setObject:[NSFont systemFontOfSize:11] forKey:NSFontAttributeName];
	
	[cellTitle drawAtPoint:NSMakePoint(cellFrame.origin.x + 10, 2) withAttributes:fontAttributes];
}

- (void)initTextCell:(NSString*)aText
{
	text = aText;
}

@end
