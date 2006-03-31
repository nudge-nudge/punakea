#import "PAFileMatrixItemCell.h"

@implementation PAFileMatrixItemCell

/*- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
	
}*/

- (void)drawInteriorWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{						   
	// Draw text
	NSString *cellTitle = [NSString stringWithString:[metadataItem valueForAttribute:(id)kMDItemDisplayName]];

	NSMutableDictionary *fontAttributes = [NSMutableDictionary dictionaryWithCapacity:3];
	[fontAttributes setObject:[NSColor textColor] forKey:NSForegroundColorAttributeName];
	[fontAttributes setObject:[NSFont systemFontOfSize:11] forKey:NSFontAttributeName];
	
	[cellTitle drawAtPoint:NSMakePoint(cellFrame.origin.x + 20, cellFrame.origin.y + 2) withAttributes:fontAttributes];
}

- (id)initTextCell:(NSString*)aText
{	
	self = [super initTextCell:aText];
	if (self) {
		identifier = [aText retain];
	}
	return self;
}

- (NSString*)identifier
{
	return identifier;
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
	if(identifier) { [identifier release]; }
	if(metadataItem) { [metadataItem release]; }
	[super dealloc];
}
@end
