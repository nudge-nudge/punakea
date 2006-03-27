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
	NSString *cellTitle = [NSString stringWithString:key];

	NSMutableDictionary *fontAttributes = [NSMutableDictionary dictionaryWithCapacity:3];
	[fontAttributes setObject:[NSColor whiteColor] forKey:NSForegroundColorAttributeName];
	[fontAttributes setObject:[NSFont systemFontOfSize:11] forKey:NSFontAttributeName];
	
	[cellTitle drawAtPoint:NSMakePoint(cellFrame.origin.x + 20, cellFrame.origin.y + 4) withAttributes:fontAttributes];
}

- (id)initTextCell:(NSString*)aText
{
	key = aText;
	
	return [super initTextCell:aText];
}

- (void)dealloc
{
	if(key) { [key release]; }
	/*if(triangle)
	{
		[triangle removeFromSuperview];
	}*/
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
	// Todo: Send notification
}

- (void)collapse
{
	isExpanded = NO;
	// TODO: Send notification
}

#pragma mark Actions
- (void)performClick:(id)sender
{
	NSString *state = @"off";
	if ([sender isHighlighted]) { state = @"on"; }
	NSLog(@"ImageButton clicked, state: %@", state);
}

#pragma mark Accessors
- (NSString*)key
{
	return key;
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
