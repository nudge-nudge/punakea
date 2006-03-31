#import "PATagCloud.h"

@interface PATagCloud (PrivateAPI)
/**
calculates the starting point in the next line according to the height of all the tags
 @param rect the main rect in which all the stuff is drawn
 @return origin point for next tag
 */
- (NSPoint)firstPointForNextLineIn:(NSRect)rect;
- (float)heightForStringDrawing:(NSString*)myString font:(NSFont*)myFont width:(float) myWidth;
- (void)drawBackground;
- (void)drawTags:(NSRect)rect;
- (NSRect)nextRectFor:(PATag*)tag inMainRect:(NSRect)rect withAttributes:(NSDictionary*)attribs;

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
		[self setNeedsDisplay:YES];
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
		NSDictionary *attributes = [tag viewAttributes];
		NSSize tagSize = [tag sizeWithAttributes:attributes];
		
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
		NSDictionary *attributes = [tag viewAttributes];
		NSRect tagRect = [self nextRectFor:tag inMainRect:rect withAttributes:attributes];
		
		PATagButton *tagButton;
		
		/* if the control isn't there yet, it needs to be created
			otherwise just set the new position */
		tagButton = [tagButtonDict objectForKey:[tag name]];
		if (tagButton) 
		{
			[tagButton setFrame:tagRect];
			[self addSubview:tagButton];
		}
		else
		{
			tagButton = [[PATagButton alloc] initWithFrame:tagRect Tag:tag];
			[tagButton setTarget:controller];
			[tagButtonDict setObject:tagButton forKey:[tag name]];
			[self addSubview:tagButton];
			[tagButton release];
		}
	}
}

- (NSRect)nextRectFor:(PATag*)tag inMainRect:(NSRect)rect withAttributes:(NSDictionary*)attribs
{
	//TODO externalize spacing and padding and ...
	int spacing = 10;
	
	//first get the tag size for the tag to draw
	NSSize tagSize = [tag sizeWithAttributes:attribs];
	
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

#pragma mark temp
- (void)mouseDown:(NSEvent *)theEvent
{
	NSLog(@"argl!!");
}

- (void)mouseUp:(NSEvent *)theEvent
{
	NSLog(@"urgl!!");
}

@end
