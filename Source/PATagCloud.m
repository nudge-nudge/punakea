#import "PATagCloud.h"

@interface PATagCloud (PrivateAPI)
/**
creates buttons for tags held in displayTags. created buttons can be accessed in
 tagButtonDict afterwards. called by setDisplayTags
 */
- (void)createButtonsForTags;

/**
draws the background
 */
- (void)drawBackground;
/**
draws all the tags in displayTags
 @param rect view rect in which to draw
 */
- (void)drawTags:(NSRect)rect;

/**
determines the oigin point for the next tag button to display;
 needs to be accessed sequentially for every tag
 
 @param tagButton button to display
 @param rect rect of main view
 @return origin point for next tagButton
 */
- (NSPoint)nextPointForTagButton:(PATagButton*)tagButton inRect:(NSRect)rect;

/**
calculates the starting point in the next row according to the height of all the tags
 @param rect the main rect in which all the stuff is drawn
 @return origin point for next tag
 */
- (NSPoint)firstPointForNextRowIn:(NSRect)rect;


- (void)moveSelectionRight;
- (void)moveSelectionLeft;
- (void)moveSelectionUp;
- (void)moveSelectionDown;
- (NSMutableArray*)buttonsAbove:(NSPoint)point;
- (NSMutableArray*)buttonsRightOf:(NSPoint)point;
- (NSMutableArray*)buttonsBelow:(NSPoint)point;
- (NSMutableArray*)buttonsLeftOf:(NSPoint)point;

- (PATagButton*)upperLeftButton;
- (NSPoint)centerOfButton:(PATagButton*)button;

- (PATagButton*)buttonNearestPoint:(NSPoint)center inButtons:(NSMutableArray*)buttons;
- (double)distanceFrom:(NSPoint)a to:(NSPoint)b;

@end

@implementation PATagCloud

#pragma mark init
- (id)initWithFrame:(NSRect)frameRect
{
	if (self = [super initWithFrame:frameRect]) {
		tagButtonDict = [[NSMutableDictionary alloc] init];
	}
	return self;
}

/**
bind to visibleTags
 */
- (void)awakeFromNib
{
	[browserViewController addObserver:self
							forKeyPath:@"visibleTags"
							   options:0
							   context:NULL];
	
	[self setDisplayTags:[NSArray arrayWithArray:[browserViewController visibleTags]]];
	
	[[self window] setInitialFirstResponder:self];
}

- (void)dealloc
{
	[activeButton release];
	[tagButtonDict release];
	[super dealloc];
}

#pragma mark observer and important stuff
/**
bound to visibleTags
 */
- (void)observeValueForKeyPath:(NSString *)keyPath
					  ofObject:(id)object 
                        change:(NSDictionary *)change
                       context:(void *)context
{
	if ([keyPath isEqual:@"visibleTags"]) 
	{
		[self setDisplayTags:[NSArray arrayWithArray:[browserViewController visibleTags]]];
		[self setNeedsDisplay:YES];
	}
}

- (void)createButtonsForTags
{
	[tagButtonDict removeAllObjects];
	
	NSEnumerator *tagEnumerator = [displayTags objectEnumerator];
	PATag *tag;
	
	while (tag = [tagEnumerator nextObject])
	{
		PATagButton *button = [[PATagButton alloc] initWithTag:tag attributes:[browserViewController viewAttributesForTag:tag]];
		[button setTarget:browserViewController];
		[button sizeToFit];
		[tagButtonDict setObject:button forKey:[tag name]];
		[button release];
	}
}

#pragma mark drawing
- (void)drawRect:(NSRect)rect
{	
	NSRect bounds = [self bounds];
	
	//initial point, from here all other points are calculated
	pointForNextTagRect = NSMakePoint(0,bounds.size.height);
	
	//needed for drawing in rows
	tagPosition = 0;

	//get the point for the very first tag
	pointForNextTagRect = [self firstPointForNextRowIn:bounds];
	
	[self drawBackground];
	[self drawTags:bounds];
	
	//select initial tag
	if (!activeButton)
	{
		[self setactiveButton:[self upperLeftButton]];
	}
}

- (void)drawTags:(NSRect)rect
{
	//first remove all drawn tags
	NSEnumerator *viewEnumerator = [[self subviews] objectEnumerator];
	NSControl *subview;
	
	
	while (subview = [viewEnumerator nextObject])
	{
		[subview removeFromSuperviewWithoutNeedingDisplay];
	}
	
	NSEnumerator *e = [displayTags objectEnumerator];
	
	PATag *tag;
	
	while (tag = [e nextObject])
	{
		PATagButton *tagButton = [tagButtonDict objectForKey:[tag name]];
		NSPoint origin = [self nextPointForTagButton:tagButton inRect:(NSRect)rect];
		[tagButton setFrameOrigin:origin];
		
		[self addSubview:tagButton];
		
		// needs to be set after adding as subview
		[[tagButton cell] setShowsBorderOnlyWhileMouseInside:YES];
	}
}

- (void)drawBackground
{
	NSRect bounds = [self bounds];
	[[NSColor whiteColor] set];
	[NSBezierPath fillRect:bounds];
	
	[[NSColor lightGrayColor] set];
	[NSBezierPath strokeRect:bounds];
}

#pragma mark calculation
- (NSPoint)firstPointForNextRowIn:(NSRect)rect;
{
	//TODO externalize
	int vPadding = 1;
	int spacing = 10;
	
	//values needed for calc
	int rowWidth = 0;
	float maxHeight = 0.0;
	
	/* while there are tags, compose a row and get the maximum height,
		then keep the starting points for each one */
	NSEnumerator *tagEnumerator = [displayTags objectEnumerator];
	PATag *tag;
	
	int i;
	for (i=0;i<tagPosition;i++)
	{
		[tagEnumerator nextObject];
	}
	
	while (tag = [tagEnumerator nextObject])
	{
		//get the size for the current tag
		PATagButton *button = [tagButtonDict objectForKey:[tag name]];
		NSRect frame = [button frame];
		NSSize tagSize = frame.size;
		
		//if the tag fills the row, stop adding tags
		rowWidth += spacing + tagSize.width;
		
		if (rowWidth + spacing > rect.size.width)
			break;
		
		//remember the maximum height
		if (tagSize.height > maxHeight)
			maxHeight = tagSize.height;
		
		tagPosition++;
	}
	
	return NSMakePoint(spacing,pointForNextTagRect.y-maxHeight-vPadding);
}	

- (NSPoint)nextPointForTagButton:(PATagButton*)tagButton inRect:(NSRect)rect
{
	//TODO externalize spacing and padding and ...
	int spacing = 10;
	
	NSRect frame = [tagButton frame];
	float width = frame.size.width;
	
	float xValue = pointForNextTagRect.x + width + spacing;
	
	//if the tag doesn't fit in this row, get first point in next row
	if (xValue > rect.size.width)
	{
		pointForNextTagRect = [self firstPointForNextRowIn:rect];
	}
	
	//save this value
	NSPoint newOrigin = NSMakePoint(pointForNextTagRect.x,pointForNextTagRect.y);
	
	//then calc the point for the next tag
	pointForNextTagRect = NSMakePoint(pointForNextTagRect.x + width + spacing,pointForNextTagRect.y);
	
	return newOrigin;
}

#pragma mark accessors
- (NSArray*)displayTags
{
	return displayTags;
}

- (void)setDisplayTags:(NSArray*)otherTags
{
	[otherTags retain];
	[displayTags release];
	displayTags = otherTags;
	
	[self createButtonsForTags];
}

- (PATagButton*)activeButton
{
	return activeButton;
}

- (void)setactiveButton:(PATagButton*)aTag
{
	[activeButton setHovered:NO];
	
	[aTag retain];
	[activeButton release];
	activeButton = aTag;
	
	[activeButton setHovered:YES];
	
	[self setNeedsDisplay:YES];
}

#pragma mark event handling
/*

TODO: ResultsView couldn't get focused any more!!

- (BOOL)acceptsFirstResponder
{
	return YES;
}

- (BOOL)becomeFirstResponder
{
	return YES;
}

- (BOOL)resignFirstResponder
{
	[self setactiveButton:nil];
	return NO;
}*/

- (void)keyDown:(NSEvent*)event 
{
	// get the pressed key
	unichar key = [[event charactersIgnoringModifiers] characterAtIndex:0];
	
	if (key == NSRightArrowFunctionKey || key == NSLeftArrowFunctionKey || key == NSUpArrowFunctionKey || key == NSDownArrowFunctionKey)
	{
		switch (key)
		{
			case NSRightArrowFunctionKey: [self moveSelectionRight];
				break;
			case NSLeftArrowFunctionKey: [self moveSelectionLeft];
				break;
			case NSUpArrowFunctionKey: [self moveSelectionUp];
				break;
			case NSDownArrowFunctionKey: [self moveSelectionDown];
				break;
		}
	} 
	else if (key == NSEnterCharacter)
	{
		[activeButton performClick:NULL];
	}
	else
	{
		// forward unhandled events
		[[self nextResponder] keyDown:event];
	}
}

#pragma mark moving selection
- (void)moveSelectionRight
{
	NSRect frame = [activeButton frame];
	NSMutableArray *buttons = [self buttonsRightOf:frame.origin];
	
	NSPoint center = [self centerOfButton:activeButton];
	
	if ([buttons count] > 0)
	{
		[self setactiveButton:[self buttonNearestPoint:center inButtons:buttons]];
	}
	else
	{
		//TODO wrap
	}
}

- (void)moveSelectionLeft
{
	NSRect frame = [activeButton frame];
	NSMutableArray *buttons = [self buttonsLeftOf:frame.origin];
		
	NSPoint center = [self centerOfButton:activeButton];
		
	if ([buttons count] > 0)
	{
		[self setactiveButton:[self buttonNearestPoint:center inButtons:buttons]];
	}
	else
	{
		//TODO wrap
	}
}

- (void)moveSelectionUp
{
	NSRect frame = [activeButton frame];
	NSMutableArray *buttons = [self buttonsAbove:frame.origin];
	
	NSPoint center = [self centerOfButton:activeButton];
		
	if ([buttons count] > 0)
	{
		[self setactiveButton:[self buttonNearestPoint:center inButtons:buttons]];
	}
	else
	{
		//TODO wrap
	}
}

- (void)moveSelectionDown
{
	NSRect frame = [activeButton frame];
	NSMutableArray *buttons = [self buttonsBelow:frame.origin];
		
	NSPoint center = [self centerOfButton:activeButton];
		
	if ([buttons count] > 0)
	{
		[self setactiveButton:[self buttonNearestPoint:center inButtons:buttons]];
	}
	else
	{
		//TODO wrap
	}
}

- (NSMutableArray*)buttonsAbove:(NSPoint)point
{
	NSEnumerator *e = [tagButtonDict objectEnumerator];
	PATagButton *button;
	
	NSMutableArray *buttons = [NSMutableArray array];
	
	while (button = [e nextObject])
	{
		NSRect buttonFrame = [button frame];
		
		if (buttonFrame.origin.y > point.y)
		{
			[buttons addObject:button];
		}
	}
	
	return buttons;
}

- (NSMutableArray*)buttonsRightOf:(NSPoint)point
{
	NSEnumerator *e = [tagButtonDict objectEnumerator];
	PATagButton *button;
	
	NSMutableArray *buttons = [NSMutableArray array];
	
	while (button = [e nextObject])
	{
		NSRect buttonFrame = [button frame];
		
		if (buttonFrame.origin.y == point.y && buttonFrame.origin.x > point.x)
		{
			[buttons addObject:button];
		}
	}
	
	return buttons;
}

- (NSMutableArray*)buttonsBelow:(NSPoint)point
{
	NSEnumerator *e = [tagButtonDict objectEnumerator];
	PATagButton *button;
	
	NSMutableArray *buttons = [NSMutableArray array];
	
	while (button = [e nextObject])
	{
		NSRect buttonFrame = [button frame];
		
		if (buttonFrame.origin.y < point.y)
		{
			[buttons addObject:button];
		}
	}
	
	return buttons;
}

- (NSMutableArray*)buttonsLeftOf:(NSPoint)point
{
	NSEnumerator *e = [tagButtonDict objectEnumerator];
	PATagButton *button;
	
	NSMutableArray *buttons = [NSMutableArray array];
	
	while (button = [e nextObject])
	{
		NSRect buttonFrame = [button frame];
		
		if (buttonFrame.origin.y == point.y && buttonFrame.origin.x < point.x)
		{
			[buttons addObject:button];
		}
	}
	
	return buttons;
}

- (NSPoint)centerOfButton:(PATagButton*)button
{
	NSRect frame = [button frame];
	NSPoint center = NSMakePoint(frame.origin.x + frame.size.width/2,frame.origin.y + frame.size.height/2);
	return center;
}

- (PATagButton*)buttonNearestPoint:(NSPoint)center inButtons:(NSMutableArray*)buttons
{
	NSEnumerator *e = [buttons objectEnumerator];
	PATagButton *button;
	
	PATagButton *result = [e nextObject];
	
	while (button = [e nextObject])
	{
		NSPoint otherCenter = [self centerOfButton:button];
		
		double oldDistance = [self distanceFrom:[self centerOfButton:result] to:center];
		double newDistance = [self distanceFrom:otherCenter to:center];
		
		if (newDistance < oldDistance)
		{
			result = button;
		}
	}
	
	return result;
}

- (PATagButton*)upperLeftButton
{
	NSEnumerator *e = [tagButtonDict objectEnumerator];
	PATagButton *button;
	
	PATagButton *result = [e nextObject];
	
	while (button = [e nextObject])
	{
		NSRect oldFrame = [result frame];
		NSPoint old = oldFrame.origin;
		
		NSRect newFrame = [button frame];
		NSPoint new = newFrame.origin;
		
		if (new.x < old.x && new.y > old.y)
		{
			result = button;
		}
	}
	
	return result;
}

- (double)distanceFrom:(NSPoint)a to:(NSPoint)b
{
	return sqrt( pow(a.x - b.x,2) + pow(a.y - b.y,2) );
}

@end
