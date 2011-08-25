// Copyright (c) 2006-2011 nudge:nudge (Johannes Hoffart & Daniel Bär). All rights reserved.
// 
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "PATagCloud.h"

NSSize const TAGCLOUD_PADDING = {10,5};
NSSize const TAGCLOUD_SPACING = {0,1};

@interface PATagCloud (PrivateAPI)
// event handling
- (void)handleTagsChange;

/**
creates buttons for tags held in dataSource. Created buttons can be accessed in
 tagButtonDict afterwards.
 */
- (void)updateButtons;

- (void)calcInitialParametersInRect:(NSRect)rect;
- (NSRect)calcFrame;

- (NNTag*)tagWithBestAbsoluteRating:(NSArray*)tagSet;

/**
draws the background
 */
- (void)drawBackground;
- (void)drawString:(NSString*)string;
- (void)drawDropHighlightInRect:(NSRect)rect;

- (void)updateViewHierarchy;
- (void)removeTagButton:(PATagButton*)tagButton;

- (void)moveTagButton:(PATagButton*)tagButton toPoint:(NSPoint)origin;
- (void)addTagButton:(PATagButton*)tagButton atPoint:(NSPoint)origin;

- (void)displayActiveButton;

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

- (void)scrollToTop;
- (void)scrollToButton:(PATagButton*)tagButton;

- (void)arrowEvent:(unichar)key;
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
- (PATagButton*)maximumButtonOnLineWithPoint:(NSPoint)point;

- (double)distanceFrom:(NSPoint)a to:(NSPoint)b;

@end

@implementation PATagCloud

#pragma mark init
- (id)initWithFrame:(NSRect)frameRect
{
	if (self = [super initWithFrame:frameRect]) {
		userDefaultsController = [NSUserDefaultsController sharedUserDefaultsController];
			
		tagButtonDict = [[NSMutableDictionary alloc] init];	
		
		dropManager = [PADropManager sharedInstance];
	}
	return self;
}

- (void)awakeFromNib
{
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	
	// register for superview bounds change
	NSScrollView *scrollView = [self enclosingScrollView];
	[scrollView setPostsBoundsChangedNotifications:YES];
	[nc addObserver:self 
		   selector:@selector(handleBoundsChange:) 
			   name:nil 
			 object:scrollView];
	
	[self registerForDraggedTypes:[dropManager handledPboardTypes]];
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	[activeButton release];
	[tagButtonDict release];
	[super dealloc];
}

#pragma mark handlers
- (void)handleBoundsChange:(NSNotification*)note
{
	[self setFrame:[self calcFrame]];
	
	if ([dataSource numberOfTagsInTagCloud:self] > 0)
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
	[self updateViewHierarchy];
	[self displayActiveButton];
	[self scrollToTop];
}

- (void)handleActiveTagChange
{
	if ([self activeButton])
	{
		[self scrollToButton:[self activeButton]];
	}
}

#pragma mark observer and important stuff
- (void)reloadData
{
	[self handleTagsChange];
}

- (void)updateButtons
{
	NSMutableDictionary *dict = [NSMutableDictionary dictionary];
	
	NNTag *currentBestTag = [dataSource currentBestTagInTagCloud:self];
	
	for (NSUInteger i=0;i<[dataSource numberOfTagsInTagCloud:self];i++)
	{
		NNTag *tag = [dataSource tagCloud:self tagForIndex:i];
		
		CGFloat tagRating = [tag relativeRatingToTag:currentBestTag];
				
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
			[button setTarget:delegate];
			[button release];
		}

		[button sizeToFit];
	}
	
	[self setTagButtonDict:dict];
}

- (NSRect)calcFrame
{
	NSSize newSize;
	
	NSRect clipViewFrame = [[self enclosingScrollView] documentVisibleRect];
	NSRect tmpFrame = NSMakeRect(0,0,NSWidth(clipViewFrame),0);
	[self calcInitialParametersInRect:tmpFrame];
	NSPoint buttonPoint = NSMakePoint(0.0,0.0);
	
	for (NSInteger i=0;i<[dataSource numberOfTagsInTagCloud:self];i++)
	{
		NNTag *tag = [dataSource tagCloud:self tagForIndex:i];
		PATagButton *tagButton = [tagButtonDict objectForKey:[tag name]];
		buttonPoint = [self nextPointForTagButton:tagButton inRect:tmpFrame];
		[tagButton setFrameOrigin:buttonPoint];
	}
		
	newSize.height = 0 - buttonPoint.y + TAGCLOUD_PADDING.height;
	
	if (newSize.height < NSHeight(clipViewFrame))
	{
		newSize.height = NSHeight(clipViewFrame);
	}
	
	newSize.width = NSWidth([[self enclosingScrollView] frame]);
	
	NSRect newFrame = NSMakeRect(0.0,0.0,newSize.width,newSize.height);
	return newFrame;
}

#pragma mark drawing
- (void)drawRect:(NSRect)rect
{	
	[self drawBackground];
	
	// draw message string if needed
	if ([displayMessage isNotEqualTo:@""])
		[self drawString:displayMessage];
	
	// Draw drop border
	if(showsDropBorder) [self drawDropHighlightInRect:rect];
	
	[super drawRect:rect];
}

- (void)drawBackground
{
	[[NSColor colorWithDeviceRed:(236.0/255.0) green:(242.0/255.0) blue:(251.0/255.0) alpha:1.0] set];
	NSRectFill([self bounds]);
}

- (void)drawDropHighlightInRect:(NSRect)rect
{
	NSSize offset = NSMakeSize(3.0, 3.0);

	[self lockFocus];
	
	NSRect drawRect = rect;
	
	drawRect.size.width -= offset.width;
	drawRect.origin.x += offset.width / 2.0;

	drawRect.size.height -= offset.height;
	drawRect.origin.y += offset.height / 2.0;

	[[NSColor colorWithDeviceRed:(185.0/255.0) green:(215.0/255.0) blue:(255.0/255.0) alpha:1.0] set];
	CGFloat lineWidth = [NSBezierPath defaultLineWidth];
	[NSBezierPath setDefaultLineWidth:3.0];
	NSBezierPath *path = [NSBezierPath bezierPathWithRoundRectInRect:drawRect radius:4.0];
	[path stroke];
	[NSBezierPath setDefaultLineWidth:lineWidth];

	[self unlockFocus];
}

- (void)drawString:(NSString*)string
{
	NSFont *font = [NSFont systemFontOfSize:20.0];
	NSColor *color = [NSColor lightGrayColor];
	NSMutableParagraphStyle *paraStyle = [[[NSParagraphStyle defaultParagraphStyle] mutableCopy] autorelease];
	[paraStyle setLineBreakMode:NSLineBreakByTruncatingTail];
	[paraStyle setAlignment:NSCenterTextAlignment];
	
	NSMutableDictionary *attrsDictionary =	[NSMutableDictionary dictionaryWithCapacity:3];
	[attrsDictionary setObject:font forKey:NSFontAttributeName];
	[attrsDictionary setObject:color forKey:NSForegroundColorAttributeName];
	[attrsDictionary setObject:paraStyle forKey:NSParagraphStyleAttributeName];
	
	NSAttributedString *attrString = [[NSAttributedString alloc] initWithString:string
																	 attributes:attrsDictionary];
	
	NSPoint stringOrigin;
	NSSize stringSize;
	NSRect rect = [[self enclosingScrollView] documentVisibleRect];
	
	stringSize = [attrString size];
	stringOrigin.x = rect.origin.x + (rect.size.width - stringSize.width)/2;
	stringOrigin.y = rect.origin.y + (rect.size.height - stringSize.height)/2;
	
	[attrString drawInRect:NSMakeRect(stringOrigin.x,stringOrigin.y,stringSize.width,stringSize.height)];
	
	[attrString release];
}

- (void)updateViewHierarchy
{	
	NSRect rect = [self bounds];
	
	[self calcInitialParametersInRect:rect];

	NSMutableArray *viewsToKeep = [NSMutableArray array];
	NSMutableArray *viewsToDelete = [NSMutableArray array];
	
	NSEnumerator *viewEnumerator = [[self subviews] objectEnumerator];
	NSControl *subview;
	
	while (subview = [viewEnumerator nextObject])
	{
		if ([dataSource tagCloud:self containsTag:[(PATagButton*)subview genericTag]])
		{
			[viewsToKeep addObject:subview];
		}
		else
		{
			[viewsToDelete addObject:subview];
		}
	}
	
	NSEnumerator *deleteViewEnumerator = [viewsToDelete objectEnumerator];
	
	while (subview = [deleteViewEnumerator nextObject])
	{
		[self removeTagButton:(PATagButton*)subview];
	}
	
	for (NSUInteger i=0;i<[dataSource numberOfTagsInTagCloud:self];i++)
	{
		NNTag *tag = [dataSource tagCloud:self tagForIndex:i];
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
	
	[self setNeedsDisplay:YES];
}

- (void)removeTagButton:(PATagButton*)tagButton
{
	[tagButton removeFromSuperview];
}

- (void)moveTagButton:(PATagButton*)tagButton toPoint:(NSPoint)origin
{
	NSRect oldFrame = [tagButton frame];
	NSRect newFrame = NSMakeRect(origin.x,origin.y,oldFrame.size.width,oldFrame.size.height);
	
	[tagButton setFrame:newFrame];
	[self setNeedsDisplayInRect:oldFrame];
}

- (void)addTagButton:(PATagButton*)tagButton atPoint:(NSPoint)origin
{
	[tagButton setFrameOrigin:origin];
	[self addSubview:tagButton];
}

- (void)displayActiveButton
{
	PATagButton *tagButton = [tagButtonDict objectForKey:[[self selectedTag] name]];
	
	[self setActiveButton:tagButton];
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
	NSRect frame = [tagButton frame];
	CGFloat width = frame.size.width;
	
	// We're going to use full pixels for CoreAnimation to produce nice results and no
	// half-pixel antialiasing.
	CGFloat xValue = ceil(pointForNextTagRect.x + width + TAGCLOUD_SPACING.width + TAGCLOUD_PADDING.width);
	
	//if the tag doesn't fit in this row, get first point in next row
	if (xValue > rect.size.width)
	{
		pointForNextTagRect = [self firstPointForNextRowIn:rect];
	}
	
	//save this value
	NSPoint newOrigin = NSMakePoint(pointForNextTagRect.x, pointForNextTagRect.y);
	
	//then calc the point for the next tag
	pointForNextTagRect = NSMakePoint(pointForNextTagRect.x + width + TAGCLOUD_SPACING.width,
									  pointForNextTagRect.y);
	
	tagPosition++;
	
	return newOrigin;
}

- (NSPoint)firstPointForNextRowIn:(NSRect)rect;
{
	//values needed for calc
	NSInteger rowWidth = 0;
	CGFloat maxHeight = 0.0;
	
	/* while there are tags, compose a row and get the maximum height,
		then keep the starting points for each one */
	for (NSUInteger i=tagPosition;i<[dataSource numberOfTagsInTagCloud:self];i++)
	{
		NNTag *tag = [dataSource tagCloud:self tagForIndex:i];
		
		//get the size for the current tag
		PATagButton *button = [tagButtonDict objectForKey:[tag name]];
		NSRect frame = [button frame];
		NSSize tagSize = frame.size;
			
		//if the tag fills the row, stop adding tags
		rowWidth += TAGCLOUD_SPACING.width + tagSize.width;
			
		if (rowWidth + TAGCLOUD_SPACING.width > rect.size.width)
		{
			break;
		}
			
		//remember the maximum height
		if (tagSize.height > maxHeight)
		{
			maxHeight = tagSize.height;
		}
	}
	
	return NSMakePoint(TAGCLOUD_SPACING.width,
					   pointForNextTagRect.y - maxHeight - TAGCLOUD_SPACING.height);
}

- (NNTag*)tagWithBestAbsoluteRating:(NSArray*)tagSet
{
	NSEnumerator *e = [tagSet objectEnumerator];
	NNTag *tag;
	NNTag *maxTag;
	
	if (tag = [e nextObject])
		maxTag = tag;
	
	while (tag = [e nextObject])
	{
		if ([tag absoluteRating] > [maxTag absoluteRating])
			maxTag = tag;
	}	
	
	return maxTag;
}

#pragma mark accessors
- (id<PATagCloudDataSource>)dataSource
{
	return dataSource;
}

- (void)setDataSource:(id<PATagCloudDataSource>)ds
{
	dataSource = ds;
}

- (id<PATagCloudDelegate>)delegate
{
	return delegate;
}

- (void)setDelegate:(id<PATagCloudDelegate>)del
{
	delegate = del;
}

- (NSMutableDictionary*)tagButtonDict
{
	return tagButtonDict;
}

- (NNTag*)selectedTag
{
	return selectedTag;
}

- (void)setSelectedTag:(NNTag*)aTag
{
	[selectedTag release];
	selectedTag = [aTag retain];
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
	[activeButton select:NO];
	[activeButton setNeedsDisplay:YES];
	
	[aTagButton select:YES];
	[aTagButton setNeedsDisplay:YES];
	
	[aTagButton retain];
	[activeButton release];
	activeButton = aTagButton;
	
	[self handleActiveTagChange];
}

- (NSString*)displayMessage
{
	return displayMessage;
}

- (void)setDisplayMessage:(NSString*)message
{
	[displayMessage release];
	[message retain];
	displayMessage = message;
}

#pragma mark functionality
- (void)selectTag:(NNTag*)tag
{
	// remember selected tag
	[self setSelectedTag:tag];
	
	// make sure all buttons are updated
	[self handleTagsChange];
	
	PATagButton *button = [tagButtonDict objectForKey:[tag name]];
	[self setActiveButton:button];
}

// work around until tagcloud supports tag renaming correctly
- (void)removeActiveTagButton
{
	NNTag *activeTag = [activeButton genericTag];
	
	if (activeTag != nil)
	{
		[activeButton removeFromSuperview];
		[tagButtonDict removeObjectForKey:[activeTag name]];
	}
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
			if ([delegate respondsToSelector:@selector(tagButtonClicked:)])
			{
				[delegate tagButtonClicked:activeButton];
			}
		}
	}
	else if (key == NSTabCharacter)
	{
		if ([delegate respondsToSelector:@selector(makeControlledViewFirstResponder)])
		{
			[delegate makeControlledViewFirstResponder];
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

#pragma mark drap & drop stuff
- (NSDragOperation)draggingEntered:(id <NSDraggingInfo>)sender
{
	// check if sender should be ignored
	if(![dropManager acceptsSender:[sender draggingSource]])
		return NSDragOperationNone;
	
	NSDragOperation dragOp =  [dropManager performedDragOperation:[sender draggingPasteboard]];
	
	if (dragOp != NSDragOperationNone)
	{
		showsDropBorder = YES;
		[self setNeedsDisplay:YES];
	}
	
	return dragOp;
}

- (NSDragOperation)draggingUpdated:(id <NSDraggingInfo>)sender
{
	// If application not key, get keyboard state for option key (Carbon)
	
	// check if sender should be ignored
	if(![dropManager acceptsSender:[sender draggingSource]])
		return NSDragOperationNone;
	
	// Make sure we are show the latest drag operation - flags may have been changed
	return [dropManager performedDragOperation:[sender draggingPasteboard]];
}

- (void)draggingExited:(id <NSDraggingInfo>)sender
{
	showsDropBorder = NO;
	[self setNeedsDisplay:YES];
}

- (void)draggingEnded:(id <NSDraggingInfo>)sender
{
	//nothin
}

- (BOOL)prepareForDragOperation:(id <NSDraggingInfo>)sender
{
    return YES;
}

- (BOOL)performDragOperation:(id <NSDraggingInfo>)sender
{
	NSArray *newObjects = [dropManager handleDrop:[sender draggingPasteboard]];
	
	if ([delegate respondsToSelector:@selector(taggableObjectsHaveBeenDropped:)])
	{
		[delegate taggableObjectsHaveBeenDropped:newObjects];
		return YES;
	}
	else
	{
		return NO;
	}
}

/**
executes some interface stuff
 */
- (void)concludeDragOperation:(id <NSDraggingInfo>)sender
{	
	showsDropBorder = NO;
	[self setNeedsDisplay:YES];
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

- (void)scrollToButton:(PATagButton*)tagButton
{
	// check if we are in the top or bottom line
	// scroll completely to the top or bottom then
	
	NSRect buttonFrame = [tagButton frame];
	NSSize viewSize = [self frame].size;
	
	CGFloat buttonLineMaxY = NSMaxY([[self maximumButtonOnLineWithPoint:buttonFrame.origin] frame]);
	CGFloat topSkip = viewSize.height - TAGCLOUD_PADDING.height;
	CGFloat bottomSkip = 0 + TAGCLOUD_PADDING.height;

	if (buttonLineMaxY >= topSkip - 1)
	{
		buttonFrame.origin.y = viewSize.height - buttonFrame.size.height;
	}
	
	// check bottom
	else if (buttonFrame.origin.y <= bottomSkip)
	{
		buttonFrame.origin.y -= TAGCLOUD_PADDING.height;
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
	CGFloat maxHeight = 0.0;
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
