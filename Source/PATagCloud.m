#import "PATagCloud.h"

NSSize const PADDING = {10,5};
NSSize const SPACING = {0,1};

@interface PATagCloud (PrivateAPI)
/**
creates buttons for tags held in [controller visibleTags]. created buttons can be accessed in
 tagButtonDict afterwards. called by setDisplayTags
 */
- (void)updateButtons;

- (void)calcInitialParametersInRect:(NSRect)rect;
- (NSRect)calcFrame;

/**
draws the background
 */
- (void)drawBackground;

/**
adds all the tags in [controller visibleTags]
 */
- (void)updateViewHierarchy;

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
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		userDefaultsController = [NSUserDefaultsController sharedUserDefaultsController];
		[self bind:@"eyeCandy" 
		  toObject:userDefaultsController 
	   withKeyPath:@"values.TagCloud.EyeCandy" 
		   options:nil];
		
		tagButtonDict = [[NSMutableDictionary alloc] init];	
		viewAnimation = [[NSViewAnimation alloc] init];
		
		// TODO activate this and code correctly
		//[viewAnimation setAnimationBlockingMode:NSAnimationNonblockingThreaded];
		viewAnimationCache = [[NSMutableArray alloc] init];
		
		NSFont *font = [NSFont fontWithName:@"Arial" size:20.0];
		NSColor *color = [NSColor lightGrayColor];
		NSDictionary *attrsDictionary =
			[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:font,color,nil]
										forKeys:[NSArray arrayWithObjects:NSFontAttributeName,NSForegroundColorAttributeName,nil]];
		
		noRelatedTagsMessage = [[NSAttributedString alloc] initWithString:@"no related tags" attributes:attrsDictionary]; 
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
	
	// register for superview bounds change
	NSScrollView *scrollView = [self enclosingScrollView];
	[scrollView setPostsBoundsChangedNotifications:YES];
	[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(handleBoundsChange:) 
												 name:nil 
											   object:scrollView];

	[self handleTagsChange];
}

- (void)dealloc
{
	[noRelatedTagsMessage release];
	[activeButton release];
	[viewAnimationCache release];
	[viewAnimation release];
	[tagButtonDict release];
	[super dealloc];
}

#pragma mark handlers
- (void)handleBoundsChange:(NSNotification*)note
{
	[self setFrame:[self calcFrame]];
	
	if ([[controller visibleTags] count] > 0)
	{
		[self updateViewHierarchy];
		
		if ([self activeButton])
		{
			[self scrollToButton:[self activeButton]];
		}
		else
		{
			[self scrollToTop];
		}
	}	
}

- (void)handleTagsChange
{
	[self updateButtons];
	[self setFrame:[self calcFrame]];
	[self updateViewHierarchy:YES];
	[self setActiveButton:nil];
	[self scrollToTop];
}

- (void)handleTypeAheadFindChange
{
}

- (void)handleActiveTagChange
{
	if ([self activeButton])
	{
		[self scrollToButton:[self activeButton]];
	}
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
		[self handleTagsChange];
	}
}

- (void)updateButtons
{
	NSMutableDictionary *dict = [NSMutableDictionary dictionary];
	
	NSEnumerator *tagEnumerator = [[controller visibleTags] objectEnumerator];
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
- (NSRect)calcFrame
{
	NSRect clipViewFrame = [[self superview] frame];
	NSRect tmpFrame = NSMakeRect(0,0,NSWidth(clipViewFrame),0);
	[self calcInitialParametersInRect:tmpFrame];
	
	NSEnumerator *e = [[controller visibleTags] objectEnumerator];
	PATag *tag;
	
	NSPoint buttonPoint = NSMakePoint(0.0,0.0);
	
	while (tag = [e nextObject])
	{
		PATagButton *tagButton = [tagButtonDict objectForKey:[tag name]];
		buttonPoint = [self nextPointForTagButton:tagButton inRect:tmpFrame];
		[tagButton setFrameOrigin:buttonPoint];
	}
	
	float newHeight = 0 - buttonPoint.y + PADDING.height;
	
	if (newHeight < NSHeight(clipViewFrame))
	{
		newHeight = NSHeight(clipViewFrame);
	}
	
	NSRect newFrame = NSMakeRect(0.0,0.0,NSWidth(clipViewFrame),newHeight);
	return newFrame;
}

- (void)drawRect:(NSRect)rect
{	
	[self drawBackground];
	
	if ([[controller visibleTags] count] == 0 && ![[controller relatedTags] isUpdating])
	{
		[self drawString:noRelatedTagsMessage centeredIn:rect];
	}
	
	[super drawRect:rect];
}

- (void)drawBackground
{
	//TODO externalize
	[[NSColor colorWithDeviceRed:(236.0/255.0) green:(242.0/255.0) blue:(251.0/255.0) alpha:1.0] set];
	NSRectFill([self bounds]);
}

- (void)drawString:(NSAttributedString*)string centeredIn:(NSRect)rect
{
	NSPoint stringOrigin;
	NSSize stringSize;
	
	stringSize = [string size];
	stringOrigin.x = rect.origin.x + (rect.size.width - stringSize.width)/2;
	stringOrigin.y = rect.origin.y + (rect.size.height - stringSize.height)/2;
	
	[string drawAtPoint:stringOrigin];
}

- (void)updateViewHierarchy
{
	[self updateViewHierarchy:NO];
}

- (void)updateViewHierarchy:(BOOL)animate
{	
	// clear animation cache
	if (animate && eyeCandy)
	{
		if ([viewAnimation isAnimating])
		{
			[viewAnimation stopAnimation];
		}
		[viewAnimationCache removeAllObjects];
	}
	
	NSRect rect = [self bounds];
	
	[self calcInitialParametersInRect:rect];

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
	
	NSEnumerator *e = [[controller visibleTags] objectEnumerator];
	PATag *tag;
	
	while (tag = [e nextObject])
	{
		PATagButton *tagButton = [tagButtonDict objectForKey:[tag name]];
		NSPoint newOrigin = [self nextPointForTagButton:tagButton inRect:rect];
		
		if ([viewsToKeep containsObject:tagButton])
		{
			[self moveTagButton:tagButton toPoint:newOrigin animate:animate];
		}
		else
		{		
			[self addTagButton:tagButton atPoint:newOrigin];
		}
	}
	
	if (animate && eyeCandy)
	{
		[viewAnimation setViewAnimations:viewAnimationCache];
		// Set some additional attributes for the animation.
		[viewAnimation setDuration:0.2];    // One and a half seconds. 
		[viewAnimation setAnimationCurve:NSAnimationEaseInOut];		
		[viewAnimation startAnimation];
	}
	
	[self setNeedsDisplay:YES];
}

- (void)removeTagButton:(PATagButton*)tagButton
{
	[tagButton removeFromSuperview];
}

- (void)moveTagButton:(PATagButton*)tagButton toPoint:(NSPoint)origin animate:(BOOL)animate
{
	NSRect oldFrame = [tagButton frame];
	NSRect newFrame = NSMakeRect(origin.x,origin.y,oldFrame.size.width,oldFrame.size.height);
	
	if (animate && eyeCandy)
	{
		NSMutableDictionary *animationDict = [NSMutableDictionary dictionaryWithCapacity:3];
		[animationDict setObject:tagButton forKey:NSViewAnimationTargetKey];
		[animationDict setObject:[NSValue valueWithRect:oldFrame] forKey:NSViewAnimationStartFrameKey];
		[animationDict setObject:[NSValue valueWithRect:newFrame] forKey:NSViewAnimationEndFrameKey];
		
		[viewAnimationCache addObject:animationDict];
	}
	else
	{
		[tagButton setFrame:newFrame];
		[self setNeedsDisplayInRect:oldFrame];
	}	
}

- (void)addTagButton:(PATagButton*)tagButton atPoint:(NSPoint)origin
{
	[tagButton setFrameOrigin:origin];
	[self addSubview:tagButton];
}

#pragma mark calculation
- (void)calcInitialParametersInRect:(NSRect)rect
{
	//initial point, from here all other points are calculated
	pointForNextTagRect = NSMakePoint(0,rect.size.height-5);
	
	//needed for drawing in rows
	tagPosition = -1;
	
	//get the point for the very first tag
	pointForNextTagRect = [self firstPointForNextRowIn:rect];
}

- (NSPoint)nextPointForTagButton:(PATagButton*)tagButton inRect:(NSRect)rect
{
	tagPosition++;

	NSRect frame = [tagButton frame];
	float width = frame.size.width;
	
	float xValue = pointForNextTagRect.x + width + SPACING.width;
	
	//if the tag doesn't fit in this row, get first point in next row
	if (xValue > rect.size.width)
	{
		pointForNextTagRect = [self firstPointForNextRowIn:rect];
	}
	
	//save this value
	NSPoint newOrigin = NSMakePoint(pointForNextTagRect.x,pointForNextTagRect.y);
	
	//then calc the point for the next tag
	pointForNextTagRect = NSMakePoint(pointForNextTagRect.x + width + SPACING.width,pointForNextTagRect.y);
	
	return newOrigin;
}

- (NSPoint)firstPointForNextRowIn:(NSRect)rect;
{
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
		rowWidth += SPACING.width + tagSize.width;
		
		if (rowWidth + SPACING.width > rect.size.width)
			break;
		
		//remember the maximum height
		if (tagSize.height > maxHeight)
			maxHeight = tagSize.height;
		}
	
	return NSMakePoint(SPACING.width,pointForNextTagRect.y-maxHeight-SPACING.height);
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
	[activeButton setSelected:NO];
	[activeButton setNeedsDisplay:YES];
	
	[aTagButton setSelected:YES];
	[aTagButton setNeedsDisplay:YES];
	
	[aTagButton retain];
	[activeButton release];
	activeButton = aTagButton;
	
	[self handleActiveTagChange];
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
	[self setNeedsDisplay:YES];
	return YES;
}

- (BOOL)resignFirstResponder
{
	[self setNeedsDisplay:YES];
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
		[self arrowEvent:key];
	}
	else if (key == NSEnterCharacter || key == '\r')
	{
		if ([self activeButton])
		{
			[activeButton performClick:NULL];
		}
	}
	else
	{
		// forward unhandled events
		[super keyDown:event];
	}
}

- (void)arrowEvent:(unichar)key
{
	// if no key has been pressed yet, the upper left button will be selected
	if (![self activeButton])
	{
		[self selectUpperLeftButton];
		return;
	}
	
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
#pragma mark moving selection
- (void)selectUpperLeftButton
{
	[self setActiveButton:[self upperLeftButton]];
}

- (void)scrollToTop
{
	NSPoint upperLeftCorner = NSMakePoint(0.0,[self bounds].size.height);
	[self scrollPoint:upperLeftCorner];
}

- (void)scrollToButton:(NSButton*)tagButton
{
	// check if we are in the top or bottom line
	// scroll completely to the top or bottom then
	
	NSRect buttonFrame = [tagButton frame];
	NSSize viewSize = [self frame].size;
	
	float buttonLineMaxY = NSMaxY([[self maximumButtonOnLineWithPoint:buttonFrame.origin] frame]);
	float topSkip = viewSize.height - PADDING.height;
	float bottomSkip = 0 + PADDING.height;

	// check top - TODO why -1?!
	if (buttonLineMaxY >= topSkip - 1)
	{
		buttonFrame.origin.y = viewSize.height - buttonFrame.size.height;
	}
	
	// check bottom
	else if (buttonFrame.origin.y <= bottomSkip)
	{
		buttonFrame.origin.y -= PADDING.height;
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
		
		if (new.x <= old.x && new.y >= old.y)
		{
			result = button;
		}
	}
	
	return result;
}

- (PATagButton*)maximumButtonOnLineWithPoint:(NSPoint)point
{
	NSArray *buttons = [self buttonsWithOriginOnHorizontalLineWithPoint:point];
	float maxHeight = 0.0;
	PATagButton *maxButton;
	
	NSEnumerator *e = [buttons objectEnumerator];
	PATagButton *button;
	
	while (button = [e nextObject])
	{
		if (NSMaxY([button frame]) > maxHeight)
		{
			maxHeight = NSMaxY([button frame]);
			maxButton = button;
		}
	}
	
	return maxButton;	
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
