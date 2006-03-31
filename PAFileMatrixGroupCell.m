#import "PAFileMatrixGroupCell.h"

@implementation PAFileMatrixGroupCell

/*- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
	
}*/

- (void)drawInteriorWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{					   
	// Add or move triangle
	if([triangle superview] != controlView)
	{
		triangle = [[PAImageButton alloc] initWithFrame:NSMakeRect(cellFrame.origin.x, cellFrame.origin.y + 2, 16, 16)];
		[triangle setImage:[NSImage imageNamed:@"CollapsedTriangleWhite"] forState:PAOffState];
		[triangle setImage:[NSImage imageNamed:@"ExpandedTriangleWhite"] forState:PAOnState];
		[triangle setImage:[NSImage imageNamed:@"ExpandedTriangleWhite_Pressed"] forState:PAOnHighlightedState];
		[triangle setImage:[NSImage imageNamed:@"CollapsedTriangleWhite_Pressed"] forState:PAOffHighlightedState];
		[triangle setButtonType:PASwitchButton];
		[triangle setState:PAOnState];
		[triangle setTarget:self];
		[controlView addSubview:triangle];  
	} else {
		[triangle setFrame:NSMakeRect(cellFrame.origin.x, cellFrame.origin.y + 2, 16, 16)];
	}
	
	// Draw background
	NSImage *backgroundImage = [NSImage imageNamed:@"MD0-0-Middle-1"];
	[backgroundImage setFlipped:YES];
	[backgroundImage setScalesWhenResized:YES];
	
	NSRect imageRect;
	imageRect.origin = NSZeroPoint;
	imageRect.size = [backgroundImage size];
		
	[backgroundImage drawInRect:cellFrame fromRect:imageRect operation:NSCompositeSourceOver fraction:1.0];

					   
	// Draw text	
	NSString *cellTitle = [NSString stringWithString:identifier];

	NSMutableDictionary *fontAttributes = [NSMutableDictionary dictionaryWithCapacity:3];
	[fontAttributes setObject:[NSColor whiteColor] forKey:NSForegroundColorAttributeName];
	[fontAttributes setObject:[NSFont systemFontOfSize:11] forKey:NSFontAttributeName];
	
	[cellTitle drawAtPoint:NSMakePoint(cellFrame.origin.x + 20, cellFrame.origin.y + 4) withAttributes:fontAttributes];
}

- (id)initTextCell:(NSString*)aText
{
	self = [super initTextCell:aText];
	if (self) {
		identifier = [aText retain];
		isExpanded = YES;
	}	
	return self;
}

- (void)dealloc
{
	if(identifier) { [identifier release]; }
	if (triangle) {
		[triangle removeFromSuperview];
		[triangle release];
	}
	[super dealloc];
}

- (void)toggle
{
	if (isExpanded) 
	{
		[self collapse];
	} else {
		[self expand];
	}
}

- (void)expand
{
	isExpanded = YES;
	[[self controlView] expandGroupCell:self];
}

- (void)collapse
{
	isExpanded = NO;
	[[self controlView] collapseGroupCell:self];
}

#pragma mark Actions
- (void)action:(id)sender
{
	[self toggle];
}

#pragma mark Accessors
- (NSString*)identifier
{
	return identifier;
}

- (bool)isExpanded
{
	return isExpanded;
}

- (PAImageButton*)triangle
{
	return triangle;
}
@end
