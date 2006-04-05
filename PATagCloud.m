#import "PATagCloud.h"

@interface PATagCloud (PrivateAPI)
/**
calculates the starting point in the next line according to the height of all the tags
 @param rect the main rect in which all the stuff is drawn
 @return origin point for next tag
 */
- (NSPoint)firstPointForNextLineIn:(NSRect)rect;
- (void)createButtonsForTags;
- (float)heightForStringDrawing:(NSString*)myString font:(NSFont*)myFont width:(float) myWidth;
- (void)drawBackground;
- (void)drawTags:(NSRect)rect;
- (NSPoint)nextPointForTag:(PATag*)tag inRect:(NSRect)rect;
- (NSRect)nextRectFor:(PATag*)tag inMainRect:(NSRect)rect withAttributes:(NSDictionary*)attribs;
- (NSSize)sizeWithAttributes:(NSDictionary*)attributes forTag:(PATag*)tag;

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
bind to relatedTags ... TagCloud always displays the content of relatedTags
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
bound to relatedTags
 */
- (void)observeValueForKeyPath:(NSString *)keyPath
					  ofObject:(id)object 
                        change:(NSDictionary *)change
                       context:(void *)context
{
	if ([keyPath isEqual:@"visibleTags"]) 
	{
		[self setDisplayTags:[NSArray arrayWithArray:[controller visibleTags]]];
		[self createButtonsForTags];
		[self setNeedsDisplay:YES];
	}
}

/**
creates buttons for tags held in displayTags. created buttons can be accessed in
 tagButtonDict afterwards
 */
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
	}
}

#pragma mark drawing
- (void)drawRect:(NSRect)rect
{	
	pointForNextTagRect = NSMakePoint(0,rect.size.height);
	
	//needed for drawing in lines
	tagPosition = 0;
		
	pointForNextTagRect = [self firstPointForNextLineIn:rect];
	
	[self drawBackground];
	[self drawTags:rect];
}

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
	
	NSMutableString *oneLine = [NSMutableString string];
	
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
		
		[oneLine appendFormat:@"%@ ",[tag name]];
		tagPosition++;
	}

	return NSMakePoint(spacing,pointForNextTagRect.y-maxHeight-vPadding);
}	

- (void)drawBackground
{
	NSRect bounds = [self bounds];
	[[NSColor whiteColor] set];
	[NSBezierPath fillRect:bounds];
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
		NSPoint origin = [self nextPointForTag:(PATag*)tag inRect:(NSRect)rect];
		
		PATagButton *tagButton = [tagButtonDict objectForKey:[tag name]];
		[tagButton setFrameOrigin:origin];
		[self addSubview:tagButton];
	}
}

//TODO if this works, pass control instead of tag
- (NSPoint)nextPointForTag:(PATag*)tag inRect:(NSRect)rect
{
	//TODO externalize spacing and padding and ...
	int spacing = 10;
	
	PATagButton *button = [tagButtonDict objectForKey:[tag name]];
	NSRect frame = [button frame];
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

//deprecated
- (NSRect)nextRectFor:(PATag*)tag inMainRect:(NSRect)rect withAttributes:(NSDictionary*)attribs
{
	//TODO externalize spacing and padding and ...
	int spacing = 10;
	
	//first get the tag size for the tag to draw
	NSSize tagSize = [self sizeWithAttributes:attribs forTag:tag];
	
	int xValue = pointForNextTagRect.x + tagSize.width + spacing;
	
	//if the tag doesn't fit in this line, get first point in next line
	if (xValue > rect.size.width)
	{
		pointForNextTagRect = [self firstPointForNextLineIn:rect];
	}
		
	NSRect tagRect =  NSMakeRect(pointForNextTagRect.x,pointForNextTagRect.y,tagSize.width,tagSize.height);
	
	//then calc the point for the next tag 
	pointForNextTagRect = NSMakePoint(pointForNextTagRect.x + tagSize.width + spacing,pointForNextTagRect.y);
	
	return tagRect;
}

- (NSSize)sizeWithAttributes:(NSDictionary*)attributes forTag:(PATag*)tag
{
	return [[tag name] sizeWithAttributes:attributes];
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
}

@end
