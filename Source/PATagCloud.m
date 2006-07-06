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
- (PATagButton*)getTagForRow:(int)row column:(int)column;

@end

@implementation PATagCloud

#pragma mark init
- (id)initWithFrame:(NSRect)frameRect
{
	if (self = [super initWithFrame:frameRect]) {
		tagButtonDict = [[NSMutableDictionary alloc] init];
		columnCountInRow = [[NSMutableArray alloc] init];
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
	[activeTag release];
	[columnCountInRow release];
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
	rowCount = -1;
	[self setColumnCountInRow:[NSMutableArray array]];
	
	//get the point for the very first tag
	pointForNextTagRect = [self firstPointForNextRowIn:bounds];
	
	[self drawBackground];
	[self drawTags:bounds];
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
		[tagButton setRow:rowCount column:columnCount];
		
		[self addSubview:tagButton];
		
		// needs to be set after adding as subview
		[[tagButton cell] setShowsBorderOnlyWhileMouseInside:YES];
	}
	
	// remember column Count after every tag has been drawn
	NSNumber *count = [NSNumber numberWithInt:columnCount];
	[columnCountInRow addObject:count];
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
	// remeber column count in rows - after first row has been drawn
	if (rowCount >= 0)
	{
		NSNumber *count = [NSNumber numberWithInt:columnCount];
		[columnCountInRow addObject:count];
	}		
	
	//increment rowCount
	rowCount++;
	
	//reset columCount
	columnCount = -1;
	
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
	
	//increment columnCount
	columnCount++;
	
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

- (NSMutableArray*)columnCountInRow
{
	return columnCountInRow;
}

- (void)setColumnCountInRow:(NSMutableArray*)array
{
	[array retain];
	[columnCountInRow release];
	columnCountInRow = array;
}

- (PATagButton*)activeTag
{
	return activeTag;
}

- (void)setActiveTag:(PATagButton*)aTag
{
	[activeTag setHovered:NO];
	
	[aTag retain];
	[activeTag release];
	activeTag = aTag;
	
	[activeTag setHovered:YES];
	
	[self setNeedsDisplay:YES];
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
	else
	{
		// forward unhandled events
		[[self nextResponder] keyDown:event];
	}
}

#pragma mark moving selection
- (void)moveSelectionRight
{
	if (!activeTag)
	{
		[self setActiveTag:[self getTagForRow:0 column:0]];
	}
	else
	{
		int column = [activeTag column];
		int row = [activeTag row];
		
		// move right
		column++;
		
		//check if needs to wrap
		NSNumber *columnCountInCurrentRow = [columnCountInRow objectAtIndex:row];
			
		if (column > [columnCountInCurrentRow intValue])
		{
			column = 0;
		}
		
		[self setActiveTag:[self getTagForRow:row column:column]];
	}
}

- (void)moveSelectionLeft
{
	if (!activeTag)
	{
		int rowLength = [[columnCountInRow objectAtIndex:0] intValue];
		[self setActiveTag:[self getTagForRow:0 column:rowLength]];
	}
	else
	{
		int column = [activeTag column];
		int row = [activeTag row];
		
		// move left
		column--;
		
		//check if needs to wrap
		NSNumber *columnCountInCurrentRow = [columnCountInRow objectAtIndex:row];
		
		if (column < 0)
		{
			column = [columnCountInCurrentRow intValue];
		}
		
		[self setActiveTag:[self getTagForRow:row column:column]];
	}
}

//TODO check if this is best
- (void)moveSelectionUp
{
	if (!activeTag)
	{
		int rows = [columnCountInRow count]-1;
		[self setActiveTag:[self getTagForRow:rows column:0]];
	}
	else
	{
		int column = [activeTag column];
		int row = [activeTag row];
		
		NSNumber *columnCountInOldRow = [columnCountInRow objectAtIndex:row];
		
		// move up
		row--;
		
		//check if needs to wrap
		if (row < 0)
		{
			row = [columnCountInRow count]-1;
		}
		
		//calculate suitable column
		NSNumber *columnCountInNewRow = [columnCountInRow objectAtIndex:row];
		float ratio = (float) column / (float) [columnCountInOldRow intValue];
		
		// value will be truncated, this is intended
		column = ratio * (float) [columnCountInNewRow intValue];
		
		[self setActiveTag:[self getTagForRow:row column:column]];
	}
}

- (void)moveSelectionDown
{
	if (!activeTag)
	{
		[self setActiveTag:[self getTagForRow:0 column:0]];
	}
	else
	{
		int column = [activeTag column];
		int row = [activeTag row];
		
		NSNumber *columnCountInOldRow = [columnCountInRow objectAtIndex:row];
		
		// move down
		row++;
		
		//check if needs to wrap
		if (row >= [columnCountInRow count])
		{
			row = 0;
		}
		
		//calculate suitable column
		NSNumber *columnCountInNewRow = [columnCountInRow objectAtIndex:row];
		float ratio = (float) column / (float) [columnCountInOldRow intValue];
		
		// value will be truncated, this is intended
		column = ratio * (float) [columnCountInNewRow intValue];
		
		[self setActiveTag:[self getTagForRow:row column:column]];
	}
}

- (PATagButton*)getTagForRow:(int)row column:(int)column
{
	//TODO linear performance, needs optimization
	NSEnumerator *e = [tagButtonDict objectEnumerator];
	PATagButton *button;
	
	PATagButton *result;
	
	while (button = [e nextObject])
	{
		if ([button row] == row && [button column] == column)
		{
			result = button;
		}
	}
	
	return result;
}

@end
