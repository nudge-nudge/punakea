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
calculates the starting point in the next line according to the height of all the tags
 @param rect the main rect in which all the stuff is drawn
 @return origin point for next tag
 */
- (NSPoint)firstPointForNextLineIn:(NSRect)rect;

@end

@implementation PATagCloud

#pragma mark init
- (id)initWithFrame:(NSRect)frameRect
{
	if ((self = [super initWithFrame:frameRect]) != nil) {
		tagButtonDict = [[NSMutableDictionary alloc] init];
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
	
	[self setDisplayTags:[NSArray arrayWithArray:[controller visibleTags]]];
}

- (void)dealloc
{
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
		[self setDisplayTags:[NSArray arrayWithArray:[controller visibleTags]]];
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
		PATagButton *button = [[PATagButton alloc] initWithTag:tag attributes:[controller viewAttributesForTag:tag]];
		[button sizeToFit];
		[tagButtonDict setObject:button forKey:[tag name]];
		[button release];
	}
}

#pragma mark drawing
- (void)drawRect:(NSRect)rect
{	
	//initial point, from here all other points are calculated
	pointForNextTagRect = NSMakePoint(0,rect.size.height);
	
	//needed for drawing in rows
	tagPosition = 0;
	
	//get the point for the very first tag
	pointForNextTagRect = [self firstPointForNextLineIn:rect];
	
	[self drawBackground];
	[self drawTags:rect];
}

- (void)drawTags:(NSRect)rect
{
	//first remove all drawn tags
	NSEnumerator *viewEnumerator = [[self subviews] objectEnumerator];
	NSControl *subview;
	
	while (subview = [viewEnumerator nextObject])
	{
		[subview removeFromSuperview];
	}
	
	NSEnumerator *e = [displayTags objectEnumerator];
	
	PATag *tag;
	
	while (tag = [e nextObject])
	{
		PATagButton *tagButton = [tagButtonDict objectForKey:[tag name]];
		NSPoint origin = [self nextPointForTagButton:tagButton inRect:(NSRect)rect];
		[tagButton setFrameOrigin:origin];
		[self addSubview:tagButton];
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
- (NSPoint)firstPointForNextLineIn:(NSRect)rect;
{
	//TODO externalize
	int vPadding = 1;
	int spacing = 10;
	
	//values needed for calc
	int lineWidth = 0;
	float maxHeight = 0.0;
	
	/* while there are tags, compose a line and get the maximum height,
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
		
		//if the tag fills the line, stop adding tags
		lineWidth += spacing + tagSize.width;
		
		if (lineWidth + spacing > rect.size.width)
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
	
	//if the tag doesn't fit in this line, get first point in next line
	if (xValue > rect.size.width)
	{
		pointForNextTagRect = [self firstPointForNextLineIn:rect];
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

@end
