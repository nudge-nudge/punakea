#import "PATagCloud.h"

@interface PATagCloud (PrivateAPI)

- (NSPoint)firstPointForNextLineIn:(NSRect)rect;
- (float)heightForStringDrawing:(NSString*)myString font:(NSFont*)myFont width:(float) myWidth;
- (void)drawBackground:(NSRect)rect;
- (void)drawTags:(NSRect)rect;
- (NSRect)nextRectFor:(PATag*)tag inMainRect:(NSRect)rect withAttributes:(NSDictionary*)attribs;

@end

@implementation PATagCloud

- (id)initWithFrame:(NSRect)frameRect
{
	if ((self = [super initWithFrame:frameRect]) != nil) {
		activeTag = [[PATag alloc] init];
		rectTags = [[NSMutableArray alloc] init];
	}
	return self;
}

- (void)awakeFromNib
{
	[relatedTagsController addObserver:self
							forKeyPath:@"arrangedObjects"
							   options:0
							   context:NULL];
}

- (void)dealloc
{
	[activeTag release];
	[rectTags release];
	[super dealloc];
}

- (PATag*)activeTag
{
	return activeTag;
}

- (void)setActiveTag:(PATag*)aTag
{
	[activeTag release];
	[aTag retain];
	activeTag = aTag;
}

- (void)observeValueForKeyPath:(NSString *)keyPath
					  ofObject:(id)object 
                        change:(NSDictionary *)change
                       context:(void *)context
{
	if ([keyPath isEqual:@"arrangedObjects"]) 
		[self setNeedsDisplay:YES];
}

#pragma mark drawing
- (void)drawRect:(NSRect)rect
{	
	pointForNextTagRect = NSMakePoint(0,rect.size.height);
	
	//if there are registered trackingRects, remove them before redrawing
	NSEnumerator *e = [rectTags objectEnumerator];
	NSTrackingRectTag rectTag;
	
	//get the tags to be displayed
	currentTags = [relatedTagsController arrangedObjects];
	
	while (rectTag = [[e nextObject] intValue])
		[self removeTrackingRect:rectTag];
	
	//TODO externalize values
	pointForNextTagRect = [self firstPointForNextLineIn:rect];
	
	[self drawBackground:rect];
	[self drawTags:rect];
}

- (NSPoint)firstPointForNextLineIn:(NSRect)rect;
{
	int padding = 10;
	
	NSEnumerator *e = [currentTags objectEnumerator];
	PATag *tag;
	
	int lineWidth = 0;
	NSMutableString *oneLine = [NSMutableString stringWithString:@""];
	
	while (tag = [e nextObject])
	{
		NSSize tagSize = [tag sizeWithAttributes:[tag viewAttributes]];
		lineWidth = padding + tagSize.width;
		[oneLine appendString:[tag name]];
		
		if (lineWidth + padding > rect.size.width)
			break;
	}
	
	float height = [self heightForStringDrawing:oneLine font:[NSFont fontWithName:@"Geneva" size:50] width:lineWidth];
		
	return NSMakePoint(padding,pointForNextTagRect.y-height);
}	

- (float)heightForStringDrawing:(NSString*)myString font:(NSFont*)myFont width:(float) myWidth
{
	//TODO kein bock mehr eh
	return 35;
	
	NSTextStorage *textStorage = [[[NSTextStorage alloc] initWithString:myString] autorelease];
	NSTextContainer *textContainer = [[[NSTextContainer alloc] initWithContainerSize: NSMakeSize(myWidth, FLT_MAX)] autorelease];
	NSLayoutManager *layoutManager = [[[NSLayoutManager alloc] init] autorelease];
	
	[layoutManager addTextContainer:textContainer];
	[textStorage addLayoutManager:layoutManager];

	[textStorage addAttribute:NSFontAttributeName value:myFont range:NSMakeRange(0, [textStorage length])];
	[textContainer setLineFragmentPadding:0.0];
	[layoutManager glyphRangeForTextContainer:textContainer];
	
	return [layoutManager usedRectForTextContainer:textContainer].size.height;
}

- (void)drawBackground:(NSRect)rect
{
	NSRect bounds = [self bounds];
	[[NSColor whiteColor] set];
	[NSBezierPath fillRect:bounds];
}

- (void)drawTags:(NSRect)rect
{
	NSEnumerator *e = [currentTags objectEnumerator];
	
	PATag *tag;
	
	while (tag = [e nextObject])
	{
		NSDictionary *attributes = [tag viewAttributes];
		NSRect tagRect = [self nextRectFor:tag inMainRect:rect withAttributes:attributes];
		[tag drawInRect:tagRect withAttributes:attributes];
		
		//add tracking - keep track of the trackingRects so that the can be removed on redraw
		NSTrackingRectTag rectTag = [self addTrackingRect:tagRect owner:self userData:tag assumeInside:NO];
		[rectTags addObject:[NSNumber numberWithInt:rectTag]];
	}
}

- (NSRect)nextRectFor:(PATag*)tag inMainRect:(NSRect)rect withAttributes:(NSDictionary*)attribs
{
	//TODO externalize spacing and padding and ...
	int height = 35;
	int spacing = 10;
	int padding = 10;
	
	//first get the tag size for the tag to draw
	NSSize tagSize = [tag sizeWithAttributes:attribs];
	
	int xValue = pointForNextTagRect.x + tagSize.width + padding;
	
	if (xValue > rect.size.width)
	{
		pointForNextTagRect = NSMakePoint(padding,pointForNextTagRect.y-height);
	}
		
	NSRect tagRect =  NSMakeRect(pointForNextTagRect.x,pointForNextTagRect.y,tagSize.width,tagSize.height);
	
	//then calc the point for the next tag 
	pointForNextTagRect = NSMakePoint(pointForNextTagRect.x + tagSize.width + spacing,pointForNextTagRect.y);
	
	return tagRect;
}

//EVENT HANDLING
- (void)mouseEntered:(NSEvent*)event
{
	NSLog(@"entered %@",[event userData]);
	[self setActiveTag:[event userData]];
	[[self activeTag] setHighlight:YES];
	[self setNeedsDisplay:YES];
}

- (void)mouseExited:(NSEvent*)event
{
	[[self activeTag] setHighlight:NO];
	[self setActiveTag:NULL];
	[self setNeedsDisplay:YES];
}

- (void)mouseUp:(NSEvent*)event
{	
	if (activeTag != NULL)
	{
		[selectedTagsController addObject:activeTag];
		[activeTag incrementClickCount];
	}
}

@end
