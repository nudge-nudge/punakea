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
	/*NSImage *triangle = [NSImage imageNamed:@"ExpandedTriangleWhite"];
	[triangle setFlipped:YES];
	imageRect.size = NSMakeSize(16,16);
	[triangle drawAtPoint:NSMakePoint(cellFrame.origin.x + 3, cellFrame.origin.y + 2)
				fromRect:imageRect
			   operation:NSCompositeSourceOver
			    fraction:1.0];*/

	// Add triangle - v2
	if([triangle superview] != controlView)
	{
		triangle = [[NSButton alloc] initWithFrame:NSMakeRect(cellFrame.origin.x, cellFrame.origin.y, 20, 20)];
		[triangle setTitle:@""];
		[triangle setImage:[NSImage imageNamed:@"CollapsedTriangleWhite"]];
		[triangle setAlternateImage:[NSImage imageNamed:@"ExpandedTriangleWhite"]];
		[triangle setButtonType:NSSwitchButton];
		[triangle setBezelStyle:NSDisclosureBezelStyle];
		[triangle setState:NSOffState];
		[controlView addSubview:triangle];  
		//[triangle release];
	}
					   
	// Draw text	
	NSString *cellTitle = [NSString stringWithString:key];

	NSMutableDictionary *fontAttributes = [NSMutableDictionary dictionaryWithCapacity:3];
	[fontAttributes setObject:[NSColor whiteColor] forKey:NSForegroundColorAttributeName];
	[fontAttributes setObject:[NSFont systemFontOfSize:11] forKey:NSFontAttributeName];
	
	[cellTitle drawAtPoint:NSMakePoint(cellFrame.origin.x + 20, cellFrame.origin.y + 4) withAttributes:fontAttributes];
}

- (void)initTextCell:(NSString*)aText
{
	key = aText;
	
	[super initTextCell:aText];
}

- (void)dealloc
{
	if(key) { [key release]; }
	[triangle release];
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

#pragma Accessors
- (NSString*)key
{
	return key;
}

- (bool)isExpanded
{
	return isExpanded;
}
@end
