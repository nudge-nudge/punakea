#import "PAFileMatrixItemCell.h"

@implementation PAFileMatrixItemCell

/*- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
	
}*/

- (void)drawInteriorWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{						   
	// Draw text
	NSString *cellTitle = [NSString stringWithString:value];

	NSMutableDictionary *fontAttributes = [NSMutableDictionary dictionaryWithCapacity:3];
	[fontAttributes setObject:[NSColor textColor] forKey:NSForegroundColorAttributeName];
	[fontAttributes setObject:[NSFont systemFontOfSize:11] forKey:NSFontAttributeName];
	
	[cellTitle drawAtPoint:NSMakePoint(cellFrame.origin.x + 10, cellFrame.origin.y + 2) withAttributes:fontAttributes];
}

- (void)initTextCell:(NSString*)aText
{	
	[value release];
	value = [aText retain];
	[super initTextCell:aText];
}

- (NSString*)value
{
	return value;
}

- (NSMetadataItem*)metadataItem
{
	return metadataItem;
}

- (void)setMetadataItem:(NSMetadataItem*)item
{
	[metadataItem release];
	metadataItem = [item retain];
}

- (void)dealloc
{
	if(value) { [value release]; }
	if(metadataItem) { [metadataItem release]; }
	[super dealloc];
}
@end
