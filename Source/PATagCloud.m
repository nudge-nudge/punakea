#import "PATagCloud.h"

NSSize const padding = {10,5};
int const spacing = 10;

@interface PATagCloud (PrivateAPI)
/**
creates buttons for tags held in [controller visibleTags]. created buttons can be accessed in
 tagButtonDict afterwards. called by setDisplayTags
 */
- (void)updateButtonsForTags:(NSMutableArray*)tags;

- (void)calcInitialParametersInRect:(NSRect)rect;
- (float)calcFrameHeightForTags:(NSMutableArray*)tags width:(float)width;

/**
draws the background
 */
- (void)drawBackground;

/**
adds all the tags in [controller visibleTags]
 @param rect view rect in which to draw
 */
- (void)addTags:(NSMutableArray*)tags inRect:(NSRect)rect;

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

- (void)scrollToButton:(NSButton*)tagButton;
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

- (PATagButton*)buttonNearestPoint:(NSPoint)center inButtons:(NSArray*)buttons;
- (NSMutableArray*)buttonsWithOriginOnHorizontalLineWithPoint:(NSPoint)point;

- (double)distanceFrom:(NSPoint)a to:(NSPoint)b;

@end

@implementation PATagCloud

#pragma mark init
- (id)initWithFrame:(NSRect)frameRect
{
	if (self = [super initWithFrame:frameRect]) {
		tagButtonDict = [[NSMutableDictionary alloc] init];		
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		tagCloudSettings = [[NSMutableDictionary alloc] initWithDictionary:[defaults objectForKey:@"TagCloud"]];
	}
	return self;
}

/**
bind to visibleTags
 */
- (void)awakeFromNib
{
	[controller addObserver:self
				 forKeyPath:@"visibleTags"
					options:0
					context:NULL];
	
	//TODO put together see observeValueFOrKEy
	
	// create initial tag buttons
	[self updateButtonsForTags:[controller visibleTags]];
	
	// set initial active button
	if ([[controller visibleTags] count] > 0)
	{
		[self setActiveButton:[tagButtonDict objectForKey:[[[controller visibleTags] objectAtIndex:0] name]]];
	}
	
	//adjust frameSize
}

- (void)dealloc
{
	if (activeButton)
	{
		[activeButton release];
	}
	
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
		[self updateButtonsForTags:[controller visibleTags]];
		
		if ([[controller visibleTags] count] > 0)
		{
			[self setActiveButton:[tagButtonDict objectForKey:[[[controller visibleTags] objectAtIndex:0] name]]];
		}
		
		// add the buttons
		[self addTags:[controller visibleTags] inRect:[self frame]];
		
		// scroll to the active button if not visible
		[self scrollToButton:[self activeButton]];
		
		[self setNeedsDisplay:YES];
	}
}

- (void)updateButtonsForTags:(NSMutableArray*)tags
{
	NSMutableDictionary *dict = [NSMutableDictionary dictionary];
	
	NSEnumerator *tagEnumerator = [tags objectEnumerator];
	PATag *tag;
	
	while (tag = [tagEnumerator nextObject])
	{
		float tagRating = [tag relativeRatingToTag:[controller currentBestTag]];
		PATagButton *button;
		
		// if the button is already created, use it
		if (button = [tagButtonDict objectForKey:[tag name]])
		{
			[button setRating:tagRating];
			[dict setObject:button forKey:[tag name]];
		}
		else
		{
			// create new button
			button = [[PATagButton alloc] initWithTag:tag rating:tagRating];
			[dict setObject:button forKey:[tag name]];
			[button setTarget:controller];
			[button release];
		}

		// TODO needed? - where?
		[button sizeToFit];
	}
	
	[self setTagButtonDict:dict];
}

#pragma mark drawing
// this is called, determine the needed frame
- (void)setFrame:(NSRect)frameRect
{
	NSRect clipViewFrame = [[self superview] frame];
	NSRect newRect = NSMakeRect(0,0,NSWidth(clipViewFrame),0);
	
	// enlarge frame if neccessary
	float newHeight = [self calcFrameHeightForTags:[controller visibleTags] width:NSWidth(clipViewFrame)];
	
	// don't reduce the height to less than the clipview's height
	
	if (newHeight < clipViewFrame.size.height)
	{
		newRect.size.height = clipViewFrame.size.height;
	}
	else
	{
		newRect.size.height = newHeight;
	}
	
	[super setFrame:newRect];

	// add the buttons
	[self addTags:[controller visibleTags] inRect:newRect];
	
	// scroll to the active button if not visible
	[self scrollToButton:[self activeButton]];
}

- (float)calcFrameHeightForTags:(NSMutableArray*)tags width:(float)width
{
	//TODO get minimum size somemwhere
	NSRect tmpFrame = NSMakeRect(0,0,width,0);
	[self calcInitialParametersInRect:tmpFrame];
	
	NSEnumerator *e = [tags objectEnumerator];
	PATag *tag;
	
	NSPoint buttonPoint;
	
	while (tag = [e nextObject])
	{
		PATagButton *tagButton = [tagButtonDict objectForKey:[tag name]];
		buttonPoint = [self nextPointForTagButton:tagButton inRect:tmpFrame];
		[tagButton setFrameOrigin:buttonPoint];
	}
	
	//TODO externalize
	float newHeight = 0 - buttonPoint.y + 5;
	return newHeight;
}

- (void)drawRect:(NSRect)rect
{	
	[self drawBackground];
	[super drawRect:rect];
}

- (void)drawBackground
{
	//TODO externalize
	[[NSColor colorWithDeviceRed:0.905 green:0.929 blue:0.98 alpha:1.0] set];
	NSRectFill([self bounds]);
	
	[[NSColor lightGrayColor] set];
	[NSBezierPath strokeRect:[self bounds]];
}

- (void)addTags:(NSMutableArray*)tags inRect:(NSRect)rect
{
	[self calcInitialParametersInRect:rect];

	NSMutableArray *viewsToRemove = [NSMutableArray array];
	NSMutableArray *viewsToKeep = [NSMutableArray array];
	
	NSEnumerator *viewEnumerator = [[self subviews] objectEnumerator];
	NSControl *subview;
	
	while (subview = [viewEnumerator nextObject])
	{
		if ([[controller visibleTags] containsObject:[subview fileTag]])
		{
			[viewsToKeep addObject:subview];
		}
		else
		{
			[self removeTagButton:subview];
		}
	}
	
	NSEnumerator *e = [tags objectEnumerator];
	PATag *tag;
	
	while (tag = [e nextObject])
	{
		PATagButton *tagButton = [tagButtonDict objectForKey:[tag name]];
		NSPoint newOrigin = [self nextPointForTagButton:tagButton inRect:rect];
		
		if ([viewsToKeep containsObject:tagButton])
		{
			[self moveTagButton:tagButton toPoint:newOrigin];
		}
		else
		{		
			[self addTagButton:tagButton atPoint:newOrigin];
		}
	}
}

- (void)removeTagButton:(PATagButton*)tagButton
{
	[tagButton removeFromSuperviewWithoutNeedingDisplay];
}

- (void)moveTagButton:(PATagButton*)tagButton toPoint:(NSPoint)origin
{
	NSRect oldFrame = [tagButton frame];
	NSRect newFrame = NSMakeRect(origin.x,origin.y,oldFrame.size.width,oldFrame.size.height);
	
	NSMutableDictionary *animationDict = [NSMutableDictionary dictionaryWithCapacity:3];
	[animationDict setObject:tagButton forKey:NSViewAnimationTargetKey];
	[animationDict setObject:[NSValue valueWithRect:oldFrame] forKey:NSViewAnimationStartFrameKey];
	[animationDict setObject:[NSValue valueWithRect:newFrame] forKey:NSViewAnimationEndFrameKey];
	
	NSViewAnimation *viewAnimation = [[NSViewAnimation alloc] initWithViewAnimations:[NSArray arrayWithObject:animationDict]];
	// Set some additional attributes for the animation.
    [viewAnimation setDuration:0.5];    // One and a half seconds. 
    [viewAnimation setAnimationCurve:NSAnimationEaseIn];
	
	[viewAnimation startAnimation];
	[viewAnimation release];
}

- (void)addTagButton:(PATagButton*)tagButton atPoint:(NSPoint)origin
{
	[tagButton setFrameOrigin:origin];
	[self addSubview:tagButton];
	
	// needs to be called after adding to subview, else the mouseEntered/Exited events aren't
	// send to the cells
	[tagButton setShowsBorderOnlyWhileMouseInside:YES];
}

#pragma mark calculation
- (void)calcInitialParametersInRect:(NSRect)rect
{
	//initial point, from here all other points are calculated
	pointForNextTagRect = NSMakePoint(0,rect.size.height-5);
	
	//needed for drawing in rows
	tagPosition = 0;
	
	//get the point for the very first tag
	pointForNextTagRect = [self firstPointForNextRowIn:rect];
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
	NSEnumerator *tagEnumerator = [[controller visibleTags] objectEnumerator];
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

#pragma mark accessors
- (NSMutableDictionary*)tagButtonDict
{
	return tagButtonDict;
}

- (void)setTagButtonDict:(NSMutableDictionary*)aDict
{
	[aDict retain];
	[tagButtonDict release];
	tagButtonDict = aDict;
}

- (PATagButton*)activeButton
{
	return activeButton;
}

- (void)setActiveButton:(PATagButton*)aTagButton
{
	[activeButton setHovered:NO];
	[activeButton setNeedsDisplay:YES];
	
	[aTagButton setHovered:YES];
	[aTagButton setNeedsDisplay:YES];
	
	[aTagButton retain];
	[activeButton release];
	activeButton = aTagButton;
	
	[self scrollToButton:activeButton];
}

- (BrowserViewController*)controller
{
	return controller;
}

#pragma mark event handling
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
	[self setActiveButton:nil];
	return YES;
}

- (void)keyDown:(NSEvent*)event 
{
	// get the pressed key
	unichar key = [[event charactersIgnoringModifiers] characterAtIndex:0];
	
	if (key == NSRightArrowFunctionKey || 
		key == NSLeftArrowFunctionKey || 
		key == NSUpArrowFunctionKey || 
		key == NSDownArrowFunctionKey)
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
	else if (key == NSEnterCharacter || key == '\r')
	{
		// TODO buttons should handle this?
		[activeButton performClick:NULL];
	}
	else
	{
		// forward unhandled events
		[[self nextResponder] keyDown:event];
	}
}

#pragma mark moving selection
- (void)scrollToButton:(NSButton*)tagButton
{
	// check if we are in the top or bottom line
	// scroll completely to the top or bottom then
	
	NSRect buttonFrame = [tagButton frame];
	NSSize viewSize = [self frame].size;
	
	float buttonMaxY = NSMaxY(buttonFrame);
	float topSkip = viewSize.height - padding.height;
	float bottomSkip = 0 + padding.height;

	// check top - TODO why -1?!
	if (buttonMaxY >= topSkip - 1)
	{
		buttonFrame.origin.y += padding.height;
	}
	
	// check bottom
	else if (buttonFrame.origin.y <= bottomSkip)
	{
		buttonFrame.origin.y -= padding.height;
	}
	
	[self scrollRectToVisible:buttonFrame];
}

- (void)moveSelectionRight
{
	NSRect frame = [activeButton frame];
	NSMutableArray *buttons = [self buttonsRightOf:frame.origin];
	
	NSPoint center = [self centerOfButton:activeButton];
	
	if ([buttons count] > 0)
	{
		[self setActiveButton:[self buttonNearestPoint:center inButtons:buttons]];
	}
	else
	{
		// wrap around
		NSPoint point = NSMakePoint(0,frame.origin.y);
		buttons = [self buttonsWithOriginOnHorizontalLineWithPoint:point];
		[self setActiveButton:[self buttonNearestPoint:point inButtons:buttons]];
	}
}

- (void)moveSelectionLeft
{
	NSRect frame = [activeButton frame];
	NSMutableArray *buttons = [self buttonsLeftOf:frame.origin];
		
	NSPoint center = [self centerOfButton:activeButton];
		
	if ([buttons count] > 0)
	{
		[self setActiveButton:[self buttonNearestPoint:center inButtons:buttons]];
	}
	else
	{
		// wrap around
		NSRect viewFrame = [self bounds];
		NSPoint point = NSMakePoint(viewFrame.size.width,frame.origin.y);
		buttons = [self buttonsWithOriginOnHorizontalLineWithPoint:point];
		[self setActiveButton:[self buttonNearestPoint:point inButtons:buttons]];
	}
}

- (void)moveSelectionUp
{
	NSRect frame = [activeButton frame];
	NSPoint center = [self centerOfButton:activeButton];
	NSMutableArray *buttons = [self buttonsAbove:frame.origin];

	if ([buttons count] > 0)
	{
		[self setActiveButton:[self buttonNearestPoint:center inButtons:buttons]];
	}
	else
	{
		// wrap around
		NSPoint point = NSMakePoint(center.x,0);
		NSArray *allButtons = [tagButtonDict allValues];
		[self setActiveButton:[self buttonNearestPoint:point inButtons:allButtons]];
	}
}

- (void)moveSelectionDown
{
	NSRect frame = [activeButton frame];
	NSMutableArray *buttons = [self buttonsBelow:frame.origin];
		
	NSPoint center = [self centerOfButton:activeButton];
		
	if ([buttons count] > 0)
	{
		[self setActiveButton:[self buttonNearestPoint:center inButtons:buttons]];
	}
	else
	{
		// wrap around
		NSRect viewFrame = [self bounds];
		NSPoint point = NSMakePoint(center.x,viewFrame.size.height);
		NSArray *allButtons = [tagButtonDict allValues];
		[self setActiveButton:[self buttonNearestPoint:point inButtons:allButtons]];
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

- (PATagButton*)buttonNearestPoint:(NSPoint)center inButtons:(NSArray*)buttons
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

- (NSMutableArray*)buttonsWithOriginOnHorizontalLineWithPoint:(NSPoint)point
{
	NSEnumerator *e = [tagButtonDict objectEnumerator];
	PATagButton *button;
	
	NSMutableArray *tags = [NSMutableArray array];
	
	while (button = [e nextObject])
	{
		NSRect frame = [button frame];
		
		if (frame.origin.y == point.y)
		{
			[tags addObject:button];
		}
	}
	
	return tags;
}

- (double)distanceFrom:(NSPoint)a to:(NSPoint)b
{
	return sqrt( pow(a.x - b.x,2) + pow(a.y - b.y,2) );
}

@end
